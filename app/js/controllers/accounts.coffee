angular.module("app").controller "AccountsController", ($scope, $location, Wallet, Utils, RpcService, Growl) ->

    $scope.accounts = Wallet.receive_accounts
    $scope.balances = Wallet.balances

    $scope.create_account = (name) ->
        Wallet.create_account($scope.new_account_label) # refreshes cache for us

    $scope.formatAsset = Utils.formatAsset


    Wallet.refresh_accounts()
