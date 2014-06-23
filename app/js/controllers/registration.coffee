angular.module("app").controller "RegistrationController", ($scope, $modalInstance, Wallet, refresh) ->

	#alert($scope.account)
  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->
  	Wallet.wallet_account_register($scope.name, $scope.address).then (response) ->
  		$modalInstance.close("ok")
  		refresh()
