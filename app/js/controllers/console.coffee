angular.module("app").controller "ConsoleController", ($scope, $location, RpcService) ->
    $scope.outputs=[]
	#  here for testing typeahead. remove later
    $scope.states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Dakota', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
	
    $scope.command = ""

    $scope.submit = ->
        RpcService.request('execute_command_line', [$scope.command]).then (response) =>  #TODO replace when CommonAPI is added
            $scope.outputs.unshift(">> " + $scope.command + "\n\n" + response.result)
            $scope.command=""

