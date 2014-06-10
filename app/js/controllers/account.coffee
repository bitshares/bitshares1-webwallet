angular.module("app").controller "AccountController", ($scope, $location, Shared, Growl, Wallet, RpcService) ->
    accountName = $location.$$url.split('/').pop()
    console.log(accountName)
    #$scope.accountName=Shared.accountName
    $scope.account = Wallet.accounts["testname"]
    console.log($scope)

    
    $scope.import_key = ->
        console.log([$scope.pk_value, $scope.accountName])
        RpcService.request('wallet_import_private_key', [$scope.pk_value, $scope.accountName]).then (response) ->
            $scope.pk_value = ""
            Growl.notice "", "Your private key was successfully imported."

    $scope.register = ->
        Wallet.wallet_account_register($scope.accountName, $scope.accountName)


    $scope.import_wallet = ->
        RpcService.request('wallet_import_bitcoin', [$scope.wallet_file,$scope.wallet_password,$scope.accountName]).then (response) ->
            $scope.wallet_file = ""
            $scope.wallet_password = ""
            Growl.notice "The wallet was successfully imported."
            refresh_addresses()
