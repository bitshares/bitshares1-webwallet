angular.module("app").controller "AccountTransactionsController", ($scope, $location, Shared, RpcService, Wallet) ->
  $scope.transactions = []
  $scope.name = Share.accountName

  Wallet.get_transactions(Shared.accountName).then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()
