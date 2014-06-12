angular.module("app").controller "TransactionsController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->

    $scope.transactions = []
    $scope.utils = Utils
  
    Wallet.get_transactions($stateParams.name).then (trs) ->
        $scope.transactions = trs

