angular.module("app").controller "TransactionsController", ($scope, $location, $stateParams, $state, Wallet) ->
  $scope.transactions = []
  
  Wallet.get_transactions($stateParams.name).then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()

