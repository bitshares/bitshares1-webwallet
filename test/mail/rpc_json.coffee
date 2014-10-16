exports.RpcJson =
class RpcJson

    q = require 'q'
    net = require 'net'

    constructor: (@debug = off, port = 3000, host = "localhost") ->
        @payload = ""
        @defer_request = []
        @defer_connection = q.defer()
        @json_rpc_request_counter = 0
        @connection = net.createConnection port, host
        @connection.on 'connect', () =>
            console.log "Connection opened" if @debug
            @defer_connection.resolve()

        @connection.on 'data', (payload) =>
            @payload += payload.toString()
            if @payload.charAt(@payload.length - 1) == '\n'
                payload = @payload.trim()
                @payload = ""
                for str in payload.split '\n'
                    console.log "<<< #{str}" if @debug
                    response = JSON.parse(str)
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
            @connection.write data

        @defer_request[@json_rpc_request_counter].promise

    end: =>
        @connection.end()
        return
