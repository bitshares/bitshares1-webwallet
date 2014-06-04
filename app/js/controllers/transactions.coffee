angular.module("app").controller "TransactionsController", ($scope, Shared, Wallet) ->
  $scope.transactions = []

  Wallet.get_transactions(Shared.accountName).then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()
