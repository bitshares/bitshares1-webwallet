angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Growl, Shared) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = []
  $scope.accounts = []
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->

      # empty values
      symbols={}
      $scope.symbolOptions = []
      $scope.accounts = []
      $scope.accounts.splice(0, $scope.accounts.length)

      console.log response.result

      angular.forEach response.result, (val) ->
        $scope.accounts.push(val[0] + " | " + val[1].join('; '));
        angular.forEach val[1], (amt) ->
          symbols[amt[0]]=amt[0]
      console.log symbols
      angular.forEach symbols, (smb) ->
        $scope.symbolOptions.push(smb)
      $scope.symbol= $scope.symbolOptions[0]
      $scope.payfrom= $scope.accounts[0]
  refresh_accounts()

  $scope.send = ->
  	# $scope.memo was removed
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom.split(" ")[0], $scope.payto, $scope.memo]).then (response) ->
      #$state.go("transactions")
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      Growl.notice "", "Transaction broadcasted (#{response.result})"
