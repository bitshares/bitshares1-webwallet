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
    
    $scope.box = {}
    $scope.box.inbox = MailService.inbox
    $scope.box.processing = MailService.processing
    $scope.box.archive = MailService.archive
    $scope.current_box = $scope.box[$scope.box_name]
    
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
    $scope.email = MailService.inbox_ids[id]
         
    $scope.close = ->
        $modalInstance.dismiss "cancel"
    
app.controller "ComposeMailController", (
    ComposeMailState, AccountObserver, MailAPI
    $scope, $modalInstance
) ->
    $scope.email = email = ComposeMailState.email
    $scope.my_accounts = AccountObserver.my_accounts
    console.log 'email.sender',email.sender
    AccountObserver.best_account().then (account) ->
        console.log 'email.sender',email.sender
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
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
        ComposeMailState.clear()