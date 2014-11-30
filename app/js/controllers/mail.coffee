angular.module("app").controller "MailController", ($scope, $modal, mail, MailAPI) ->

    mail.check_inbox()
    $scope.inbox = mail.inbox
    
    $scope.compose= ->
        $modal.open
            templateUrl: "new-mail-thread-dialog.html"
            controller: "NewMailThreadController"
            resolve:
                title: -> "Compose"
                action: -> save
        
    #$scope.cancel= ->
    #    clear()
        
    save= -> 
        
    clear= ->
        
angular.module("app").controller "NewMailThreadController", ($scope, $modalInstance, Wallet, title, action) ->

    $scope.title = title
    $scope.my_accounts = []
    $scope.account_from_name = ""
    
    $scope.set_from = (f) ->
        $scope.account_from_name = f
    
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

        if $scope.account_from_name
            unless $scope.accounts[$scope.account_from_name]
                $scope.no_account = true
        else
            Wallet.get_current_or_first_account().then (account)->
                if account
                    $scope.account_from_name = account.name
                else
                    $scope.no_account = true

    $scope.ok = ->
        action()
        $modalInstance.close $scope.selected.item
    
    $scope.cancel = ->
        $modalInstance.dismiss "cancel"
