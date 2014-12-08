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
    $stateParams, $scope, $state
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
        MailService.stop()
        AccountObserver.stop()
        
    $scope.go = (ref, params) ->
        $state.go ref, params
    
app.controller "ShowMailController", (
    MailService
    $stateParams, $scope, $modalInstance
) ->
    id = $stateParams.id
    folder = MailService.mailbox.get($stateParams.box)
    $scope.email = folder.mail_idx[id]
    console.log folder, id,$scope.email
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
        MailService.notify_send()
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
        ComposeMailState.clear()