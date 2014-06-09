angular.module("app").controller "ConsoleController", ($scope, $location, Wallet) ->
	$scope.outputs=[]
	$scope.submit = ->
		Wallet.execute_command_line($scope.command).then (output) ->
			$scope.outputs.unshift(output)
