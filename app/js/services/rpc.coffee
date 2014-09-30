servicesModule = angular.module("app.services")
servicesModule.factory "RpcService", ($http) ->
    request: (method, params, error_handler = null) ->
        reqparams = {method: method, params: params || []}
        http_params =
            stack: getStackTrace()
            error_handler: error_handler
            method: "POST",
            cache: false,
            url: '/rpc'
            data:
                jsonrpc: "2.0"
                id: 1
        angular.extend(http_params.data, reqparams)
        #console.log "RpcService <#{http_params.data.method}>, stack: #{getStackTrace()}"
        $http(http_params).then (response) ->
            #console.log "RpcService <#{http_params.data.method}> response:", response
            response.data or response
