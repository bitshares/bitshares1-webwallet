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
        ConsoleState.quick_help=""
        ConsoleState.states.push "clear_console"
        
        #Smaller displays?
        #RpcService.request("meta_help", []).then (response) ->
        #    for s in response.result
        #        ConsoleState.states.push s[0] + " "
        #        for alias in s[1].aliases
        #          ConsoleState.states.push alias + " "

        RpcService.request('execute_command_line', ['help']).then (response) => 
            #TODO replace when CommonAPI is added
            cmds=response.result.split("\n")
            for cmd in cmds
                #TODO http://stackoverflow.com/questions/26261599/angularjs-filterviewvalue-is-not-handling-html-escaping
                #cmd = cmd.replace(/</g, "&lt;")
                #cmd = cmd.replace(/>/g, "&gt;")
                ConsoleState.states.push cmd.trim()

            ConsoleState.outputs.unshift(""">> help

clear_console
help: any_command?


""" + response.result)

    if ConsoleState.states.length == 0
        init()
        
    $scope.select = (item) ->
        ConsoleState.quick_help = item
        ConsoleState.command = item.split(" ")[0] + " "

    $scope.submit = ->
        if ConsoleState.command.trim() == "clear_console"
            init()
        else
            cmd = ConsoleState.command.trim()
            if cmd.indexOf("?") == cmd.length - 1 and [1, 2].indexOf(cmd.split(" ").length) != -1
                #convert "command ?" or "command?" into "command"
                cmd = cmd.substring(0, cmd.length - 1).trim()
                ConsoleState.command=cmd + " "
                cmd = "help " + cmd
            else
                ConsoleState.command = ""

            RpcService.request('execute_command_line', [cmd]).then (response) =>  #TODO replace when CommonAPI is added
                ConsoleState.outputs.unshift(">> " + cmd + "\n\n" + response.result)

.factory 'ConsoleState',[() ->
    outputs: []
    states : []
    command: ""
    quick_help: ""
]
