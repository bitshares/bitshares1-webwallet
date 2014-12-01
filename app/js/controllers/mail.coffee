app = angular.module "app"

app.config ($stateProvider) ->
    sp = $stateProvider
    
    sp.state "mail",
        url: "/mail"
        templateUrl: "mail.html"
        controller: "MailController"

    sp.state "mail.compose",
        url: "/compose"
        onEnter: ($state, $modal) ->
            modal = $modal.open
                templateUrl: "mail-compose-dialog.html"
                controller: "ComposeMailController"
                resolve:
                    title: -> ""
                    
            modal.result.then (result) ->
                console.log result
                
            modal.result.finally () ->
                $state.transitionTo "mail"
                
app.controller "MailController", ($scope, $modal, mail, MailAPI) ->
    
    mail.check_inbox()
    $scope.inbox = mail.inbox
    Email = window.bts.mail.Email
        
app.controller "ComposeMailController", ($scope, $modalInstance, Wallet, title) ->

    $scope.title = title
    $scope.my_accounts = []
    $scope.compose_mail = {}
    
    $scope.my_accounts = []
    refresh_accounts_promise = Wallet.refresh_accounts()
    refresh_accounts_promise.then ->
        $scope.accounts = Wallet.accounts
        $scope.my_accounts.splice(0, $scope.my_accounts.length)
        for k,a of Wallet.accounts
            $scope.my_accounts.push a if a.is_my_account

        angular.forEach Wallet.accounts, (acct, name) ->
            if acct.is_my_account
                $scope.accounts[name] = acct

        if $scope.compose_mail.from
            unless $scope.accounts[$scope.compose_mail.from]
                $scope.no_account = true
        else
            Wallet.get_current_or_first_account().then (account)->
                if account
                    $scope.compose_mail.from = account.name
                else
                    $scope.no_account = true

    $scope.ok = ->
        $modalInstance.close $scope.compose_mail
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
