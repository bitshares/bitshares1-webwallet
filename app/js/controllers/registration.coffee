angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, WalletAPI, Shared, RpcService, Blockchain, Info, Utils, md5) ->
  $scope.symbolOptions = []
  
  $scope.m={}
  $scope.m.payrate=50
  $scope.m.delegate=false

  Blockchain.get_asset(0).then (v)->
    $scope.delegate_reg_fee = Utils.formatAsset(Utils.asset( Info.info.delegate_reg_fee, v) )
    $scope.priority_fee = Utils.formatAsset(Utils.asset(Info.info.priority_fee, v))
  
  #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
  $scope.symbol = Info.symbol

  
  
  refresh_accounts = ->
    $scope.accounts = {}
    angular.forEach Wallet.balances, (balances, name) ->
        bals = []
        angular.forEach balances, (asset, symbol) ->
            if asset.amount
                bals.push asset
        if bals.length
            $scope.accounts[name]=[name, bals]
    $scope.m.payfrom= if $scope.accounts[$scope.account.name] then $scope.accounts[$scope.account.name] else $scope.accounts[Object.keys($scope.accounts)[0]]

  WalletAPI.set_priority_fee().then (result) ->
    asset_type = Blockchain.asset_records[result.asset_id]
    $scope.priority_fee = Utils.asset(result.amount, asset_type)

  Wallet.get_accounts().then ->
    refresh_accounts()

  #TODO watch accounts

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->  # $scope.payWith is not in modal's scope FFS!!!
    payrate = if $scope.m.delegate then $scope.m.payrate else 255
    if $scope.account.private_data?.gui_data?.email
        gravatarMD5 = md5.createHash($scope.account.private_data.gui_data.email)
    else
        gravatarMD5 = ""
    console.log($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate)
    Wallet.wallet_account_register($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate).then (response) ->
      $modalInstance.close("ok")
      $scope.p.pendingRegistration = Wallet.pendingRegistrations[$scope.account.name] = "pending"
