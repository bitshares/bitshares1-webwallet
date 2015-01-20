angular.module("app").controller "AccountBalancesController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->
    $scope.accounts = Wallet.accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils

    $scope.formatAsset = Utils.formatAsset

    Wallet.refresh_accounts(true).then ->
        $scope.accounts = Wallet.accounts
        $scope.balances = Wallet.balances

    $scope.go_to_account = (name) ->
        console.log "------ go_to_account ------>", name
        $state.go("account.transactions", {name: name})
