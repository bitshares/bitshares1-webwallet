angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Wallet, Growl, Shared, Utils, Blockchain) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = []
  $scope.accounts = []
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->
      $scope.symbolOptions = []
      symbols = {}
      $scope.accounts = []

      Blockchain.refresh_asset_records().then ()->
          angular.forEach response.result, (account) ->
            result = account[0] + " | "
            balances = (Utils.newAsset(balance[1], balance[0], Blockchain.symbol2records[balance[0]].precision) for balance in account[1][0])
            $scope.accounts.push([account[0], balances])

            angular.forEach account[1], (asset) ->
                symbols[asset[0]] = true
          $scope.payfrom= $scope.accounts[0]
          angular.forEach symbols, (v, symbol) ->
                $scope.symbolOptions.push symbol
          $scope.symbol = "XTS"

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


