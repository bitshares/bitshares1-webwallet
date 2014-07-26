angular.module("app").controller "ConsoleController", ($scope, $location, RpcService, ConsoleState) ->
   
    $scope.console_state=ConsoleState
    
    if ConsoleState.states.length == 0
        RpcService.request("meta_help", []).then (response) ->
            for s in response.result
                # filter bitcoin apis
                if !((s[0].indexOf "bitcoin") == 0)
                    ConsoleState.states.push s[0] + " "
    
    if ConsoleState.outputs.length == 0
        RpcService.request('execute_command_line', ['help']).then (response) => 
            #TODO replace when CommonAPI is added
            ConsoleState.outputs.unshift(">> help\n\n" + response.result)

    $scope.submit = ->
        RpcService.request('execute_command_line', [ConsoleState.command]).then (response) =>  #TODO replace when CommonAPI is added
            ConsoleState.outputs.unshift(">> " + ConsoleState.command + "\n\n" + response.result)
            ConsoleState.command=""
            
.factory 'ConsoleState',[() ->
    outputs: []
    states : []
    command: ""
]
