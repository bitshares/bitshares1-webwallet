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
    
    help = ->
        ConsoleState.outputs.unshift(
            ">> help\n\n" + ConsoleState.commands.join("\n")
        )

    init = ->
        ConsoleState.command=""
        ConsoleState.quick_help=""
        ConsoleState.outputs = []
        if ConsoleState.commands.length == 0
            #TODO replace when CommonAPI is added
            ConsoleState.commands = [
                "clear_console",
                "[command_name]? (alias for: help [command_name])"
            ]
            RpcService.request('execute_command_line', ['help']).then (response) => 
                cmds=response.result.split("\n")
                console.log cmds.length
                for cmd in cmds
                    #TODO http://stackoverflow.com/questions/26261599/angularjs-filterviewvalue-is-not-handling-html-escaping
                    #cmd = cmd.replace(/</g, "&lt;")
                    #cmd = cmd.replace(/>/g, "&gt;")
                    ConsoleState.commands.push cmd.trim()

                help()

    $scope.select = (item) ->
        ConsoleState.quick_help = item
        ConsoleState.command = item.split(" ")[0] + " "

    $scope.submit = (cmd = ConsoleState.command.trim()) ->
        if cmd == "clear_console"
            init()
            
        if cmd in ["clear_console","help"]
            help()
            return

        if(
            cmd.indexOf("?") == cmd.length - 1 and 
            cmd.split(" ").length in [1,2]
        )
            #convert "command ?" or "command?" into "command"
            cmd = cmd.substring(0, cmd.length - 1).trim()
            ConsoleState.command=cmd + " "
            cmd = "help " + cmd
        else
            ConsoleState.command = ""

        RpcService.request('execute_command_line', [cmd]).then (response) =>
            #TODO replace when CommonAPI is added
            ConsoleState.outputs.unshift(">> " + cmd + "\n\n" + response.result)

    if ConsoleState.commands.length == 0
        init()

.factory 'ConsoleState',[() ->
    command: ""
    quick_help: ""
    outputs: []
    commands : []
]
