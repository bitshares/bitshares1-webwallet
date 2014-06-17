angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Wallet, Growl, Shared) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = []
  $scope.accounts = []
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->

      $scope.symbolOptions = []
      $scope.accounts = []
      $scope.accounts.splice(0, $scope.accounts.length)

      angular.forEach response.result, (val) ->
        $scope.accounts.push(val[0] + " | " + val[1].join('; '));
        angular.forEach val[1], (asset) ->
            $scope.symbolOptions.push(asset[0])
        $scope.symbol= $scope.symbolOptions[0]
        $scope.payfrom= $scope.accounts[0]
  refresh_accounts()

  $scope.send = ->
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom.split(" ")[0], $scope.payto, $scope.memo]).then (response) ->
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      Growl.notice "", "Transaction broadcasted (#{response.result})"
