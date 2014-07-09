# This should be auto-generated. Right now it is manual but it should map exactly to common_api.json

class CommonAPI

    constructor: (@q, @log, @rpc) ->
        return

    get_info: ->
        @rpc.request('get_info').then (response) ->
            response.result
 
    get_config: ->
        @rpc.request('get_config').then (response) ->
            response.result


angular.module("app").service("CommonAPI", ["$q", "$log", "RpcService", CommonAPI])
