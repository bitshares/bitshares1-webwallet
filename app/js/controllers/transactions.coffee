angular.module("app").controller "TransactionsController", ($scope, $location, RpcService, Wallet) ->
  $scope.transactions = []

  Wallet.get_transactions().then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()
