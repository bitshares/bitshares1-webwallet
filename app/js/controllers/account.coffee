angular.module("app").controller "AccountController", ($scope, $location, Shared) ->
	$scope.accountName=Shared.accountName
	$scope.accountAddress=Shared.accountAddress