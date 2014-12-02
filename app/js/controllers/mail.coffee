app = angular.module "app"

class ComposeMailState
    constructor: ->
        @compose_mail = {}
        
    clear: ->
        delete @compose_mail[el] for el of @compose_mail
        
app.service "ComposeMailState",[ComposeMailState]

app.controller "MailController", (
    mail, MailAPI, ComposeMailState, AccountObserver
    $scope
) ->
    
    mail.check_inbox()
    $scope.inbox = mail.inbox
    AccountObserver.start()
    
    $scope.$on "$destroy", ->
        AccountObserver.stop()

app.controller "ComposeMailController", (
    ComposeMailState, AccountObserver, MailAPI
    $scope, $modalInstance
) ->

    $scope.compose_mail = compose_mail = ComposeMailState.compose_mail
    $scope.my_accounts = AccountObserver.my_accounts
    AccountObserver.best_account().then (account) ->
        compose_mail.from = account.name
    
    $scope.ok = ->
        send = MailAPI.send(
            compose_mail.from
            compose_mail.to
            compose_mail.subject
            compose_mail.body
        )
        send.then(
            (result) ->
                ComposeMailState.clear()
                $modalInstance.close()
            (error) ->
                console.log 'mail_send error',error
        )
    
    $scope.cancel = ->
        ComposeMailState.clear()
        $modalInstance.dismiss "cancel"
