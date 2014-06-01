angular.module("app").controller "ContactController", ($scope, $location, Shared) ->
	$scope.contactName = Shared.contactName
	$scope.contactAddress = Shared.contactAddress
