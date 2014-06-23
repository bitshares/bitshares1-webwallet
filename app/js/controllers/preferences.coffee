angular.module("app").controller "PreferencesController", ($scope, $location, Wallet, Shared, Growl) ->
	$scope.timeout = Shared.timeout

	$scope.updatePreferences = ->
		Wallet.set_setting('timeout', $scope.timeout).then (r) ->
			console.log('t sumbitted')
			Shared.timeout=$scope.timeout
			Growl.notice "", "Preferences Updated"