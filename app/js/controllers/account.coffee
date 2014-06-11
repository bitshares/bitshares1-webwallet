angular.module("app").controller "AccountController", ($scope, $location, $stateParams, Growl, Wallet, RpcService) ->

    name = $location.$$url.split('/').pop()


    Wallet.get_account(name).then (acct) ->
        $scope.account = acct

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
