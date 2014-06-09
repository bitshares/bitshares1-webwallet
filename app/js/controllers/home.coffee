angular.module("app").controller "HomeController", ($scope, $modal, Shared, $log, RpcService, Wallet, Growl) ->
  $scope.transactions = []
  $scope.balance_amount = 0.0
  $scope.balance_asset_type = ''

  watch_for = ->
    Wallet.info

  on_update = (info) ->
    $scope.balance_amount = info.balance if info.wallet_open

  $scope.$watch(watch_for, on_update, true)


  Wallet.wallet_account_balance().then (balance)->
    console.log('bal')
    console.log(balance)


  Wallet.get_balance().then (balance)->
    $scope.balance_amount = balance.amount
    $scope.balance_asset_type = balance.asset_type
    Wallet.get_transactions().then (trs) ->
      $scope.transactions = trs

  # Merge: this duplicates the code in transactions.coffee
  $scope.viewAccount = (name)->
    Shared.accountName  = name
    Shared.accountAddress = "TODO:  Look the address up somewhere"
    Shared.trxFor = name

  $scope.viewContact = (name)->
    Shared.contactName  = name
    Shared.contactAddress = "TODO:  Look the address up somewhere"
    Shared.trxFor = name
