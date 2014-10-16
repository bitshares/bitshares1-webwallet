
exports.Common =
class Common

    q = require 'q'

    constructor: (@rpc) ->

    run: (request) ->
        defer = q.defer()
        @rpc.request(request).then (response) ->
            console.log request, response
            defer.resolve(response)
        return defer.promise

    mkdefault: (wallet, timeout, password) ->
        @run [
            "wallet_create #{wallet} #{password}"
            "open #{wallet}"
            "unlock #{timeout} #{password}"
        ]
