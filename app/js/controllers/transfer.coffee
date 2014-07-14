angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Wallet, Growl, Shared, Utils, Blockchain) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = []
  $scope.accounts = []
  
  refresh_accounts = ->
    $scope.symbolOptions = []
    symbols = {}
    $scope.accounts = []

    angular.forEach Wallet.balances, (balances, name) ->
      result = name + " | "
      bals = []
      angular.forEach balances, (asset, symbol) ->
          bals.push asset
          symbols[symbol] = true
      $scope.accounts.push([name, bals])

    $scope.payfrom= $scope.accounts[0]
    angular.forEach symbols, (v, symbol) ->
          $scope.symbolOptions.push symbol
    $scope.symbol = "XTS"

  Wallet.get_accounts().then ->
    refresh_accounts()

  $scope.send = ->
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom[0], $scope.payto, $scope.memo]).then (response) ->
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      Growl.notice "", "Transaction broadcasted (#{response.result})"

  $scope.utils = Utils

  Blockchain.get_config().then (config) ->
        $scope.memo_size_max = config.memo_size_max


