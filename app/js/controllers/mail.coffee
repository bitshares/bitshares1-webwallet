app = angular.module "app"

class ComposeMailState
    constructor: ->
        @email = {}
        
    clear: ->
        delete @email[el] for el of @email
app.service "ComposeMailState",[ComposeMailState]

app.controller "MailController", (
    MailAPI, AccountObserver, MailService
    $stateParams, $scope, $state, $timeout, $location
) ->
    $scope.box_name = $stateParams.box
    unless $scope.box_name
        $state.go "mail",
            box: "inbox"
            
    MailService.start()
    AccountObserver.start()
    $scope.mailbox = MailService.mailbox
    $scope.mailbox.get($scope.box_name).active = true
    
    $scope.$on "$destroy", ->
        process_delete()
        MailService.stop()
        AccountObserver.stop()
        
    $scope.go = (ref, params) ->
        $state.go ref, params
        
    $scope.refresh = ->
        MailService.refresh()
        
    $scope.$watch ->
        MailService.refreshing
    , (unlocked)->
        $scope.refresh_in_progress = MailService.refreshing
    
    $scope.resend_in_progress = {}
    $scope.resend = (mail)->
        mail.error = ""
        $scope.resend_in_progress[mail.id] = on
        MailAPI.retry_send(mail.id).then(
            (result) ->
                # mail service will re-try
                mail.failure_reason = undefined
                
            (error) ->
                delete $scope.resend_in_progress[mail.id]
                mail.error = error.data.error.message
        )
        # give the user time to see the refresh
        $timeout ()->
            MailService.refresh()
            delete $scope.resend_in_progress[mail.id]
        , 1000
        
    $scope.mail_cancel = (mail) ->
        MailAPI.cancel_message(mail.id).then(
            (result) ->
                MailService.refresh()
            (error) ->
                mail.error = error.data.error.message
        )
    
    $scope.mail_delete_queue = {}
    $scope.mail_delete_queue_add = (id) ->
        $scope.mail_delete_queue[id] = on
    $scope.mail_delete_queue_undo = (id) ->
        delete $scope.mail_delete_queue[id]
    
    process_delete = ->
        for id in Object.keys $scope.mail_delete_queue
            MailService.remove_message(id).then(
                (result) ->
                    delete $scope.mail_delete_queue[id]
                (error) ->
                    $scope.mail_delete_error = error
            )
    
app.controller "ShowMailController", (
    MailService
    $stateParams, $scope, $modalInstance
) ->
    id = $stateParams.id
    folder = MailService.mailbox.get($stateParams.box)
    $scope.mail = folder.mail_idx[id]
    $scope.close = ->
        $modalInstance.dismiss "cancel"
    
app.controller "ComposeMailController", (
    ComposeMailState, AccountObserver, MailService, MailAPI, BlockchainAPI
    $scope, $modalInstance
) ->
    $scope.email = email = ComposeMailState.email
    $scope.my_mail_accounts = AccountObserver.my_mail_accounts
    AccountObserver.best_account().then (account) ->
        email.sender = account.name
    
    $scope.$watch ->
        $scope.email.recipient
    , ()->
        BlockchainAPI.get_account($scope.email.recipient).then (result) ->
            $scope.found = if result then on else off
            $scope.receives_mail = if result?.public_data?.mail_servers then on else off
            
    $scope.ok = ->
        send = MailAPI.send(
            email.sender
            email.recipient
            email.subject
            email.body
        )
        send.then(
            (result) ->
                $modalInstance.close()
                ComposeMailState.clear()
                MailService.refresh()
            (error) ->
                text = error.data.error.message
                msg = text.split('\n')
                text = msg[1] if msg.length > 1
                email.error = text
        )
        
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
        ComposeMailState.clear()