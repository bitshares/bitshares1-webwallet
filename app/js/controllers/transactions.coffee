angular.module("app").controller "TransactionsController", ($scope, $location, $stateParams, $state, Wallet, Utils, Info) ->

    $scope.name = $stateParams.name || "*"
    $scope.transactions = Wallet.transactions
    $scope.account_transactions = Wallet.transactions[$scope.name]
    $scope.utils = Utils
  
    Wallet.refresh_transactions($stateParams.name)

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        Wallet.refresh_transactions_on_new_block()

    $scope.$watchCollection "transactions", () ->
        $scope.account_transactions = Wallet.transactions[$scope.name]

    $scope.$watch watch_for, on_update, true
