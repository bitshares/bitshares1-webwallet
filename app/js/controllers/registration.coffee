angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, Shared, RpcService, Blockchain, Info, Utils, md5) ->
  $scope.symbolOptions = []
  $scope.delegate_reg_fee = Info.info.delegate_reg_fee
  $scope.priority_fee = Info.info.priority_fee
  $scope.m={}
  $scope.m.payrate=50
  $scope.m.delegate=false
  
  #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
  $scope.symbol = 'XTS'
  
  
  refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->
      $scope.accounts = []

      Blockchain.refresh_asset_records().then ()->
          $scope.formated_balances = []
          angular.forEach response.result, (account) ->
            balances = (Utils.newAsset(balance[1], balance[0], Blockchain.symbol2records[balance[0]].precision) for balance in account[1])
            console.log balances
            $scope.accounts.push([account[0], balances])
            console.log $scope.accounts
          $scope.m.payfrom= $scope.accounts[0]

  refresh_accounts()

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->  # $scope.payWith is not in modal's scope FFS!!!
    payrate = if $scope.m.delegate then $scope.m.payrate else 255
    if $scope.account.private_data.gui_data.email
        gravatarMD5 = md5.createHash($scope.account.private_data.gui_data.email)
    else
        gravatarMD5 = ""
    console.log($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate)
    Wallet.wallet_account_register($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate).then (response) ->
      $modalInstance.close("ok")
      Wallet.pendingRegistrations[$scope.account.name]="pending"
      $scope.p.pendingRegistration = Wallet.pendingRegistrations[$scope.account.name]
      console.log('pending', Wallet.pendingRegistrations, 'loc', $scope.p.pendingRegistration)
