angular.module("app").controller "AccountBalancesController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->
    

    $scope.accounts = Wallet.accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils

    $scope.formatAsset = Utils.formatAsset

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.balances = Wallet.balances
