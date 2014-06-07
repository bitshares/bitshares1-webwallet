angular.module("app").controller "ReceiveController", ($scope, $location, RpcService, Shared, Growl) ->
  $scope.new_address_label = ""
  $scope.addresses = []
  $scope.pk_label = ""
  $scope.pk_value = ""
  $scope.wallet_file = ""
  $scope.wallet_password = ""
  non0addr={}

  $scope.accountClicked = (name, address)->
    Shared.accountName  = name
    Shared.accountAddress = address
    Shared.trxFor = name


  #TODO ADD a Barrier or something to deal with race condition
  refresh_addresses = ->
    RpcService.request('wallet_account_balance').then (response) ->
      non0addr={}
      #$scope.addresses.splice(0, $scope.addresses.length)
      angular.forEach response.result, (val) ->
        non0addr[val[0]]=val[1]
        #$scope.addresses.push({name: val[0], balance: val[1]})
  refresh_addresses()


  refresh_more_addresses = ->
    RpcService.request('wallet_list_receive_accounts').then (response) ->
      $scope.addresses.splice(0, $scope.addresses.length)
      console.log response.result
      angular.forEach response.result, (val) -> 
          $scope.addresses.push({name: val.name, balance:  non0addr[val.name],  address: val.account_address, regdat: val.registration_date})
  refresh_more_addresses()
  
#if non0addr.hasOwnProperty(val.name) then non0addr[val.name] else 0

  $scope.create_address = ->
    RpcService.request('wallet_create_account', [$scope.new_address_label]).then (response) ->
      $scope.new_address_label = ""
      refresh_addresses()

  $scope.import_key = ->
    RpcService.request('wallet_import_private_key', [$scope.pk_value, $scope.pk_label]).then (response) ->
      $scope.pk_value = ""
      $scope.pk_label = ""
      Growl.notice "", "Your private key was successfully imported."
      refresh_addresses()

  $scope.import_wallet = ->
    RpcService.request('wallet_import_bitcoin', [$scope.wallet_file,$scope.wallet_password]).then (response) ->
      $scope.wallet_file = ""
      $scope.wallet_password = ""
      Growl.notice "The wallet was successfully imported."
      refresh_addresses()
