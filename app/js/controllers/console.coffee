angular.module("app").controller "ConsoleController", ($scope, $location, RpcService, ConsoleState) ->
   
    $scope.console_state=ConsoleState

    #detect tab press
    ###
    $scope.keydown = (e) ->
        console.log(e)
        if(e.which==9)
            $scope.console_state.command='bl'
            e.preventDefault()
            e.stopImmediatePropagation()
    ###

    if ConsoleState.states.length == 0
        RpcService.request("meta_help", []).then (response) ->
            for s in response.result
                ConsoleState.states.push s[0] + " "
                for alias in s[1].aliases
                  ConsoleState.states.push alias + " "
    
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
