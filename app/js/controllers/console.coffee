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

    init = ->
        ConsoleState.outputs = []
        ConsoleState.states = []
        ConsoleState.command=""
        ConsoleState.states.push "clear"
        RpcService.request("meta_help", []).then (response) ->
            for s in response.result
                ConsoleState.states.push s[0] + " "
                for alias in s[1].aliases
                  ConsoleState.states.push alias + " "

        RpcService.request('execute_command_line', ['help']).then (response) => 
            #TODO replace when CommonAPI is added
            ConsoleState.outputs.unshift(">> help\n\n" + "clear (console)\n" + response.result)

    if ConsoleState.states.length == 0
        init()

    $scope.submit = ->
        if ConsoleState.command == "clear"
            init()
        else
            RpcService.request('execute_command_line', [ConsoleState.command]).then (response) =>  #TODO replace when CommonAPI is added
                ConsoleState.outputs.unshift(">> " + ConsoleState.command + "\n\n" + response.result)
                ConsoleState.command=""

.factory 'ConsoleState',[() ->
    outputs: []
    states : []
    command: ""
]
