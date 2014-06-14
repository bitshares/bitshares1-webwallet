angular.module("app").controller "AccountController", ($scope, $location, $stateParams, Growl, Wallet, Utils, RpcService) ->

    name = $stateParams.name
    #$scope.accounts = Wallet.receive_accounts
    #$scope.account.balances = Wallet.balances[name]
    #$scope.utils = Utils

    #Wallet.refresh_accounts()

    Wallet.get_account(name).then (acct) ->
        $scope.account = acct
        $scope.balances = Wallet.balances[name]

    $scope.import_key = ->
        console.log([$scope.pk_value, $scope.account.name])
        RpcService.request('wallet_import_private_key', [$scope.pk_value, $scope.account.name]).then (response) ->
            $scope.pk_value = ""
            Growl.notice "", "Your private key was successfully imported."

    $scope.register = ->
        Wallet.wallet_account_register($scope.account.name, $scope.account.name)


    $scope.import_wallet = ->
        RpcService.request('wallet_import_bitcoin', [$scope.wallet_file,$scope.wallet_password,$scope.account.name]).then (response) ->
            $scope.wallet_file = ""
            $scope.wallet_password = ""
            Growl.notice "The wallet was successfully imported."
            refresh_addresses()

    $scope.send = ->
        RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.account.name, $scope.payto, $scope.memo]).then (response) ->
            $scope.payto = ""
            $scope.amount = ""
            $scope.memo = ""
            Growl.notice "", "Transaction broadcasted (#{response.result})"   
