angular.module("app").controller "HomeController", ($scope, $modal, $log, RpcService, Wallet) ->
  $scope.transactions = []
  $scope.balance_amount = 0.0
  $scope.balance_asset_type = ''

  watch_for = ->
    Wallet.info

  on_update = (info) ->
    $scope.balance_amount = info.balance if info.wallet_open

  $scope.$watch(watch_for, on_update, true)

  Wallet.get_balance().then (balance)->
    $scope.balance_amount = balance.amount
    $scope.balance_asset_type = balance.asset_type
    Wallet.get_transactions().then (trs) ->
      $scope.transactions = trs
