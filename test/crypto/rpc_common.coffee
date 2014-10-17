
exports.Common =
class Common

    q = require 'q'

    constructor: (@rpc) ->

    run: (request) ->
        defer = q.defer()
        @rpc.run(request).then (response) ->
            console.log request, response
            defer.resolve(response)
        return defer.promise
