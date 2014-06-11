angular.module("app").controller "EditAccountController", ($scope, $location, Wallet, $stateParams, Growl, Shared) ->
	$scope.oldName=$stateParams.name
	$scope.newName=$stateParams.name
	$scope.paywith=$stateParams.name
	$scope.registration = false
	$scope.delegate = false
	$scope.pairs = [{key: 'github', val: 'nikakhov'}, {key: 'favorite food', val: 'steak'}]
	$scope.addKeyVal = ->
		$scope.pairs.push {"":""}

	$scope.removeKeyVal = (index) ->
		$scope.pairs.splice(index, 1)

	$scope.register = ->
		Wallet.wallet_account_register($scope.newName, $scope.paywith, {"email": $scope.email, "website": $scope.website}, $scope.delegate).then (response) ->
			Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response)})"
			console.log response

	$scope.submitNameForm = ->
		alert 'Not yet implemented'
		#Wallet.wallet_rename_account($scope.accountName, $scope.newName)
