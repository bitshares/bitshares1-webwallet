class RpcJson

    q = require 'q'
    net = require 'net'

    constructor: (@debug, port, host) ->
        # @payload may temporarily hold a partial result (incomplete json response)
        @payload = ""
        @defer_request = []
        @defer_connection = q.defer()
        @json_rpc_request_counter = 0
        @connection = net.createConnection port, host
        @connection.on 'connect', () =>
            console.log "Connection opened #{host}:#{port}" if @debug
            @defer_connection.resolve()

        @connection.on 'data', (_payload) =>

            _payload = _payload.toString() unless typeof _payload is 'string'
            @payload += _payload

            # @payload may be holding more than one command
            payload_complete = @payload.charAt(@payload.length - 1) is '\n'
            cmds = @payload.trim().split '\n'
            if not payload_complete
                # save incomplete command for the next on 'data' event
                [..., @payload] = cmds
                # keep just the complete commands
                cmds = cmds[0...-1]
            else
                @payload = ""

            for cmd in cmds
                console.log "<<< #{cmd}" if @debug
                response = JSON.parse(cmd)
                if response.error
                    @defer_request[response.id].reject(response.error)
                else
                    @defer_request[response.id].resolve(response.result)

                delete @defer_request[response.id]

        @connection.on 'end', (response) =>
            console.log "Connection closed" if @debug
            @defer_connection = null

    request: (method, parameters) ->

        if Array.isArray method
            promise=[]
            for m in method
                promise.push @request(m)

            return q.all(promise)

        if not parameters
            command=method.split ' '
            method=command[0]
            parameters=command[1..]

        @json_rpc_request_counter += 1

        rpc_data=
            id: @json_rpc_request_counter
            method: method
            params: parameters

        @defer_request[@json_rpc_request_counter]=q.defer()
        @defer_connection.promise.then (p) =>
            data = JSON.stringify rpc_data
            console.log ">>> #{data}" if @debug
            #console.log ">>> #{data.id}: #{data.method} #{data.params.join(" ")}" if @debug
            @connection.write data

        @defer_request[@json_rpc_request_counter].promise

    kill: ->
        @connection.end()
        return

    close: ->
        if @defer_request.length is 0
            @connection.end()
        else
            setTimeout(@close, 300)

class Rpc extends RpcJson

    constructor: (debug, json_port, host, user, password) ->
        @rpc = super(debug, json_port, host)
        if user and password
            @request("login #{user} #{password}")

exports.Rpc = Rpc

