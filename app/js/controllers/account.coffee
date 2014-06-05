angular.module("app").controller "AccountController", ($scope, $location, Shared, RpcService) ->
	$scope.accountName=Shared.accountName
	$scope.accountAddress=Shared.accountAddress

	getbalance = ->
    	RpcService.request('wallet_get_balance', ["XTS", Shared.accountName]).then (response) ->
	      $scope.accountBalance = response.result[0][0]
	      $scope.accountUnit = response.result[0][1]


	getbalance()