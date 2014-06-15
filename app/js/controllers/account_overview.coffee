angular.module("app").controller "AccountOverviewController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->

    $scope.name = $stateParams.name

    $scope.accounts = Wallet.accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils

    $scope.formatAsset = Utils.formatAsset


    Wallet.refresh_accounts()
