angular.module("app").controller "ConsoleController", ($scope, $location, RpcService) ->
    $scope.outputs=[]
    $scope.states = []

    RpcService.request("meta_help", []).then (response) ->
        for s in response.result
            # filter bitcoin apis
            if !((s[0].indexOf "bitcoin") == 0)
                $scope.states.push s[0]

    $scope.command = ""

    $scope.submit = ->
        RpcService.request('execute_command_line', [$scope.command]).then (response) =>  #TODO replace when CommonAPI is added
            $scope.outputs.unshift(">> " + $scope.command + "\n\n" + response.result)
            $scope.command=""

