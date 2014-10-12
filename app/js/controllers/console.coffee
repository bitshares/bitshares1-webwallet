angular.module("app").controller "ConsoleController", ($scope, $location, RpcService, ConsoleState) ->

    $scope.console_state=ConsoleState

    help = ->
        ConsoleState.outputs.unshift(
            ">> help\n\n" + ConsoleState.commands.join("\n")
        )

    init = ->
        ConsoleState.command=""
        ConsoleState.quick_help=""
        ConsoleState.outputs = []
        if ConsoleState.commands.length == 0
            commands = [
                "clear_console",
                "[command_name]? (alias for: help [command_name])"
            ]
            RpcService.request("meta_help", []).then (response) =>
                aliases = []
                for s in response.result
                    cmd = s[0]
                    cmd_props = s[1]
                    params = ""
                    for p in cmd_props.parameters
                        required = p.classification.indexOf("required") isnt -1
                        params += " " +
                            (if required then "<" else "[")+ p.name +
                            (if required then ">" else "]")

                    commands.push cmd + params
                    for alias in cmd_props.aliases
                        aliases.push alias + params

                ConsoleState.commands = commands
                ConsoleState.typeahead = commands.concat aliases
                help()

    $scope.select = (item) ->
        ConsoleState.quick_help = htmlUnescape(item)
        ConsoleState.command = item.split(" ")[0] + " "

    #TODO http://stackoverflow.com/questions/26261599/angularjs-filterviewvalue-is-not-handling-html-escaping
    htmlUnescape = (text) ->
        text.replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&#39;/g, "'")
            .replace(/&quot;/g, "/")

    $scope.submit = (cmd = ConsoleState.command.trim()) ->
        if cmd == "clear_console"
            init()
            
        if cmd in ["clear_console","help"]
            help()
            return

        if(
            cmd.indexOf("?") == cmd.length - 1 and 
            cmd.split(" ").length <= 2
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

    #detect tab press
    #<input ... ng-keydown='keydown($event)' 
    #$scope.keydown = (e) ->
    #    #console.log(e)
    #    if(e.which==9)
    #        e.preventDefault()
    #        e.stopImmediatePropagation()

.factory 'ConsoleState',[() ->
    command: ""
    quick_help: ""
    outputs: []
    commands : []
    typeahread: []
]
