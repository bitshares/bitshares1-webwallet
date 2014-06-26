angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, refresh, Shared, RpcService) ->

  $scope.payWith=$scope.account.name
  
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

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = (pay_with) ->  # $scope.payWith is not in modal's scope FFS!!!
  	Wallet.wallet_account_register(Shared.accToReg, pay_with).then (response) ->
  		$modalInstance.close("ok")
  		refresh()
