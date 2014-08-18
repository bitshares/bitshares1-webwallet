angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, WalletAPI, Shared, RpcService, Blockchain, Info, Utils, md5) ->
  $scope.symbolOptions = []
  
  $scope.m={}
  $scope.m.payrate=50
  $scope.m.delegate=false
  console.log($scope.account)
  $scope.$watch ->
      Wallet.info.transaction_fee
  , ->
    Blockchain.get_asset(0).then (v)->
      $scope.delegate_reg_fee = Utils.formatAsset(Utils.asset( Info.info.delegate_reg_fee, v) )
      $scope.transaction_fee = Utils.formatAsset(Utils.asset(Wallet.info.transaction_fee.amount, v))
  
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

  Wallet.get_accounts().then ->
    refresh_accounts()

  #TODO watch accounts

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->  # $scope.payWith is not in modal's scope FFS!!!
    payrate = if $scope.m.delegate then $scope.m.payrate else 255
    if $scope.account.private_data?.gui_data?.website
        website= $scope.account.private_data.gui_data.website
    else
        website= ""
    Wallet.wallet_account_register($scope.account.name, $scope.m.payfrom[0], {'gui_data':{'website': website}}, payrate).then (response) ->
      $modalInstance.close("ok")
      $scope.p.pendingRegistration = Wallet.pendingRegistrations[$scope.account.name] = "pending"
