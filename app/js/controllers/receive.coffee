angular.module("app").controller "ReceiveController", ($scope, $location, RpcService, Shared, Growl) ->
  $scope.new_address_label = ""
  $scope.addresses = []
  $scope.pk_label = ""
  $scope.pk_value = ""
  $scope.wallet_file = ""
  $scope.wallet_password = ""

  $scope.accountClicked = (name, address)->
    Shared.accountName  = name
    Shared.accountAddress = address
    Shared.trxFor = name

  refresh_addresses = ->
    RpcService.request('wallet_list_receive_accounts').then (response) ->
      $scope.addresses.splice(0, $scope.addresses.length)
      angular.forEach response.result, (val) ->
        $scope.addresses.push({label: val.name, address: val.owner_key})

  refresh_addresses()

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
