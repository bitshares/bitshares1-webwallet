angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, refresh, Shared) ->

  $scope.payWith=$scope.account.name

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = (pay_with) ->  # $scope.payWith is not in modal's scope FFS!!!
  	Wallet.wallet_account_register(Shared.accToReg, pay_with).then (response) ->
  		$modalInstance.close("ok")
  		refresh()
