angular.module("app").controller "DirectoryController", ($scope, $location, Wallet) ->
  $scope.reg = []
  Wallet.blockchain_list_registered_accounts().then (reg) ->
    $scope.reg = reg

  $scope.addToContacts = (name, address) ->
  	Wallet.wallet_add_contact_account(name, address)
