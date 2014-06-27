angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, Shared, RpcService) ->
  $scope.symbolOptions = []
  console.log('Wallet.balances')
  console.log(Wallet.balances)
  $scope.m={}
  $scope.m.payrate=50
  $scope.m.delegate=false
  
  #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
  $scope.symbol = 'XTS'
  
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->
      console.log('response.result')
      console.log(response.result)
      $scope.accounts = []
      $scope.accounts.splice(0, $scope.accounts.length)

      angular.forEach response.result, (val) ->
        $scope.accounts.push(val);
        $scope.m.payfrom= $scope.accounts[0]
      console.log('$scope.accounts')
      console.log($scope.accounts)


  refresh_accounts()

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->  # $scope.payWith is not in modal's scope FFS!!!
    console.log($scope.m.payfrom[0])
    payrate = if $scope.m.delegate then $scope.m.payrate else 255
    console.log($scope.account.name, $scope.m.payfrom[0], {'gravatarID': $scope.gravatarMD5}, payrate)
    Wallet.wallet_account_register($scope.account.name, $scope.m.payfrom[0], {'gravatarID': $scope.gravatarMD5}, payrate).then (response) ->
      $modalInstance.close("ok")
      #refresh()
