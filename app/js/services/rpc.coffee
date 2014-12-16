servicesModule = angular.module("app.services")
servicesModule.factory "RpcService", ($http, $timeout, $q) ->
    request: (method, params, error_handler = null) ->
        reqparams = {method: method, params: params || []}
        http_params =
            stack: getStackTrace()
            error_handler: error_handler
            time: Date.now()
            method: "POST",
            cache: false,
            url: '/rpc'
            data:
                jsonrpc: "2.0"
                id: 1
        angular.extend(http_params.data, reqparams)
        #console.log "+++ RpcService <#{http_params.data.method}>" if http_params.data.method.indexOf("mail_") is 0
        defered = $q.defer()
        $http(http_params).then (response) ->
            #console.log("RpcService <#{http_params.data.method}>")
            if response.repeat
                #console.log "------ RpcService: repeating the call #{http_params.data.method} ------>", http_params.repeat_counter
                $timeout ->
                    $http(http_params).then (response1) ->
                        defered.resolve(response1.data)
                , 500
            else
                defered.resolve(response.data)
            return defered.promise

            #response.data or response

    start_profiler: ->
        window.rpc_calls_performance_data = {}

    stop_profiler: ->
        console.log "------ stop_profiler ------>", window.rpc_calls_performance_data
        results = []
        for k,v of window.rpc_calls_performance_data
            #console.log "------ profiler output ------>", k, v.duration, v.calls, v.duration/v.calls
            results.push [k, v.duration, v.calls, (v.duration/v.calls).toFixed(), v.stack]
        results.sort (a,b)-> b[1] - a[1]
        console.log "------ profiler output ------>"
        console.log(a[0],a[1],a[2],a[3]) for a in results
        window.rpc_calls_performance_data = null
