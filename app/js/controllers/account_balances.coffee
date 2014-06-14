angular.module("app").controller "AccountBalancesController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->

    $scope.accounts = Wallet.receive_accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils

    $scope.formatAsset = Utils.formatAsset


    Wallet.refresh_accounts()
