angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Growl, Shared) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = ['XTS', '...']
  $scope.accounts = []

  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->
      console.log response.result
      $scope.accounts.splice(0, $scope.accounts.length)
      angular.forEach response.result, (val) ->
        $scope.accounts.push(val[0] + " | " + val[1].join('; '));
  refresh_accounts()

  $scope.send = ->
  	# $scope.memo was removed
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom, $scope.payto, $scope.memo]).then (response) ->
      #$state.go("transactions")
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      Growl.notice "", "Transaction broadcasted (#{response.result})"
