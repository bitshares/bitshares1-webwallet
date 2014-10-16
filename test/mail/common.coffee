
exports.Common =
class Common
    
    constructor: (@rpc) ->

    run: (request) ->
        @rpc.request(request).then (response) ->
            console.log request, response

    mkdefault: (wallet, timeout, password) ->
        @run [
            "wallet_create #{wallet} #{password}"
            "open #{wallet}"
            "unlock #{timeout} #{password}"
        ]
