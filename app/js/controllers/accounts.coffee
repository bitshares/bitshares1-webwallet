angular.module("app").controller "AccountsController", ($scope, $location, Wallet, Utils, RpcService, Growl) ->

    $scope.accounts = Wallet.accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils

    $scope.formatAsset = Utils.formatAsset


    Wallet.refresh_accounts()
