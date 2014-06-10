angular.module("app").controller "AccountController", ($scope, $location, Shared, Growl, Wallet, RpcService) ->
	$scope.accountName=Shared.accountName
	$scope.accountAddress=Shared.accountAddress

	###
	getbalance = ->
    	RpcService.request('wallet_get_balance', ["XTS", Shared.accountName]).then (response) ->
	      $scope.accountBalance = response.result[0][0]
	      $scope.accountUnit = response.result[0][1]
	getbalance()
	###
	$scope.import_key = ->
		console.log([$scope.pk_value, $scope.accountName])
		RpcService.request('wallet_import_private_key', [$scope.pk_value, $scope.accountName]).then (response) ->
			$scope.pk_value = ""
			Growl.notice "", "Your private key was successfully imported."
			#refresh_addresses()

	$scope.register = ->
		Wallet.wallet_account_register($scope.accountName, $scope.accountName)