app = angular.module "app"

class ComposeMailState
    constructor: ->
        @email = {}
        
    clear: ->
        delete @email[el] for el of @email
app.service "ComposeMailState",[ComposeMailState]

app.controller "MailController", (
    MailAPI
    AccountObserver, MailService
    $stateParams, $scope, $state, $timeout
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
        
    $scope.mail_delete_queue = {}
    $scope.mail_delete_queue_add = (id) ->
        process_delete()
        $scope.mail_delete_queue[id] = true
    
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
    $scope.email = folder.mail_idx[id]
    $scope.close = ->
        $modalInstance.dismiss "cancel"
    
app.controller "ComposeMailController", (
    ComposeMailState, AccountObserver, MailService, MailAPI
    $scope, $modalInstance
) ->
    $scope.email = email = ComposeMailState.email
    $scope.my_accounts = AccountObserver.my_accounts
    AccountObserver.best_account().then (account) ->
        email.sender = account.name
    
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
            (error) ->
                console.log 'mail_send error',error
        )
        MailService.refresh()
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
        ComposeMailState.clear()