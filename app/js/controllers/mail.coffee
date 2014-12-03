app = angular.module "app"

class ComposeMailState
    constructor: ->
        @compose_mail = {}
        
    clear: ->
        delete @compose_mail[el] for el of @compose_mail
        
app.service "ComposeMailState",[ComposeMailState]

app.controller "MailController", (
    mail, MailAPI, ComposeMailState
    AccountObserver, MailInboxObserver
    $scope
) ->
    AccountObserver.start()
    MailInboxObserver.start()
    $scope.inbox = MailInboxObserver.inbox
    
    $scope.$on "$destroy", ->
        AccountObserver.stop()
        MailInboxObserver.stop()

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
                $modalInstance.close()
                ComposeMailState.clear()
            (error) ->
                console.log 'mail_send error',error
        )
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
        ComposeMailState.clear()