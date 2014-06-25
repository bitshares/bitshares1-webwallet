angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Wallet, Growl, Shared, Utils) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = []
  $scope.accounts = []
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->

      $scope.symbolOptions = []
      symbols = {}
      $scope.accounts = []
      $scope.accounts.splice(0, $scope.accounts.length)

      angular.forEach response.result, (val) ->
        $scope.accounts.push(val);
        angular.forEach val[1], (asset) ->
            symbols[asset[0]] = true
        $scope.payfrom= $scope.accounts[0]
      angular.forEach symbols, (v, symbol) ->
            $scope.symbolOptions.push symbol
      $scope.symbol = $scope.symbolOptions[0]

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


