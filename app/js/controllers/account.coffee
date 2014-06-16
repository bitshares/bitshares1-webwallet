angular.module("app").controller "AccountController", ($scope, $location, $stateParams, Growl, Wallet, Utils, RpcService) ->

    name = $stateParams.name
    #$scope.accounts = Wallet.receive_accounts
    #$scope.account.balances = Wallet.balances[name]
    #$scope.utils = Utils

    #Wallet.refresh_accounts()
    $scope.trust_level=Wallet.trust_levels[name]
    $scope.wallet_info = {file : "", password : ""}
    
    $scope.private_key = {value : ""}
    
    refresh_account = ->
        Wallet.get_account(name).then (acct) ->
            $scope.account = acct
            $scope.balances = Wallet.balances[name]
    refresh_account()

    $scope.import_key = ->
        RpcService.request('wallet_import_private_key', [$scope.private_key.value, $scope.account.name]).then (response) ->
            $scope.private_key.value = ""
            Growl.notice "", "Your private key was successfully imported."
            refresh_account()

    $scope.register = ->
        Wallet.wallet_account_register($scope.account.name, $scope.account.name)


    $scope.import_wallet = ->
        RpcService.request('wallet_import_bitcoin', [$scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name]).then (response) ->
            $scope.wallet_info.file = ""
            $scope.wallet_info.password = ""
            Growl.notice "The wallet was successfully imported."
            refresh_account()

    $scope.send = ->
        RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.account.name, $scope.payto, $scope.memo]).then (response) ->
            $scope.payto = ""
            $scope.amount = ""
            $scope.memo = ""
            Growl.notice "", "Transaction broadcasted (#{response.result})"

    $scope.toggleVoteUp = ->
        if name not of Wallet.trust_levels or Wallet.trust_levels[name] < 1
            Wallet.set_trust(name, 1)
        else
            Wallet.set_trust(name, 0)
    
    $scope.toggleVoteDown = ->
        if name not of Wallet.trust_levels or Wallet.trust_levels[name] > -1
            Wallet.set_trust(name, -1)
        else
            Wallet.set_trust(name, 0)
