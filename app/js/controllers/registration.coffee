angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, refresh, Shared) ->

  $scope.payWith=$scope.account.name

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->
  	Wallet.wallet_account_register(Shared.accToReg, $scope.payWith).then (response) ->
  		$modalInstance.close("ok")
  		refresh()
