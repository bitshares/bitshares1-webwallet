angular.module("app").controller "AccountTransactionsController", ($scope, $location, Shared, RpcService, Wallet) ->
  $scope.transactions = []

  Wallet.get_transactions(Shared.accountName).then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()
