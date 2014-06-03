angular.module("app").controller "NewContactController", ($scope, $modalInstance, RpcService, refresh) ->

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  $scope.ok = ->
  	RpcService.request('wallet_add_contact_account', [$scope.name, $scope.address]).then (response) ->
  		$modalInstance.close("ok")
  		refresh()
