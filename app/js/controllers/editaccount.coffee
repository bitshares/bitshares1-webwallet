angular.module("app").controller "EditAccountController", ($scope, $location, Shared) ->
	$scope.accountName=Shared.accountName
	$scope.paywith=Shared.accountName
	$scope.register = false
	$scope.delegate = false