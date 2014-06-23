angular.module("app").controller "TransactionsController", ($scope, $location, $stateParams, $state, Wallet, Utils) ->

    $scope.name = $stateParams.name || "*"
    $scope.transactions = Wallet.transactions
    $scope.account_transactions = Wallet.transactions[$scope.name]
    $scope.utils = Utils
  
    Wallet.refresh_transactions($stateParams.name)

    $scope.$watchCollection "transactions", () ->
        $scope.account_transactions = Wallet.transactions[$scope.name]
