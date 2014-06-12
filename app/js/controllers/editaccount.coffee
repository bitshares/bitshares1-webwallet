angular.module("app").controller "EditAccountController", ($scope, $location, Wallet, $stateParams, Growl, Shared) ->
	$scope.currentName=$stateParams.name
	$scope.newName=$stateParams.name
	$scope.paywith=$stateParams.name
	#$scope.noregistration = true
	$scope.delegate = false
	$scope.pairs = []
	$scope.addKeyVal = ->
		$scope.pairs.push {"":""}

	$scope.removeKeyVal = (index) ->
		$scope.pairs.splice(index, 1)

	$scope.register = ->
		Wallet.wallet_account_register($scope.currentName, $scope.paywith, {"email": $scope.email, "website": $scope.website}, $scope.delegate).then (response) ->
			Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response)})"
			console.log response

	$scope.submitNameForm = ->
		newName=$scope.newName
		Wallet.wallet_account_rename($scope.currentName, newName).then ->
			Growl.notice "", "Account renamed"
			$location.path("accounts/"+newName+"/edit")
