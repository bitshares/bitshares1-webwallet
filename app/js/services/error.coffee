servicesModule = angular.module("app.services", [])

servicesModule.config ($httpProvider, $provide) ->
    $httpProvider.interceptors.push('myHttpInterceptor')

    $provide.decorator "$exceptionHandler", ["$delegate", "Shared", (delegate, Shared) ->
        (exception, cause) ->
            stack = exception.stack.replace(/randomuser\:[\w\d]+\@[\d\.]+\:\d+/gm, "localhost").replace(/(\r\n|\n|\r)/gm,"\n ○ ")
            if magic_unicorn?
                magic_unicorn.log_message "js error: #{exception.message}\n#{stack}"
            else
                Shared.addError(exception.message, stack)
                delegate(exception, cause)
    ]

processRpcError = (response, Shared) ->
    dont_report = false
    method = null
    error_msg = if response.data?.error?.message? then response.data.error.message else response.data

    if response.config? and response.config.url.match(/\/rpc$/)
        if error_msg.match(/No such wallet exists/) or error_msg.match(/wallet does not exist/)
            navigate_to("createwallet") unless window.location.hash == "#/createwallet"
            dont_report = true
        if error_msg.match(/The wallet must be opened/) or error_msg.match(/spending key must be unlocked before executing this command/)
            navigate_to("unlockwallet") unless window.location.hash == "#/unlockwallet" or window.location.hash == "#/createwallet"
            dont_report = true
        method = response.config.data?.method
    else if response.message
        error_msg = response.message

    unless dont_report
        error_msg = error_msg.substring(0, 512)
        stack = if response.config?.stack then response.config?.stack else ""
        stack = stack.replace(/http\:.+app\.js([\d:]+)/mg, "app.js$1").replace(/^Error/,"RPC Server Error in '#{method}'") if stack
        console.log "RPC Server Error: #{error_msg} (#{response.status})\n#{response.config?.stack}"
        magic_unicorn.log_message("rpc error: #{error_msg} (#{response.status})\n#{stack}") if magic_unicorn?
        Shared.addError(error_msg, stack, response.data?.error?.detail)


servicesModule.factory "myHttpInterceptor", ($q, Shared) ->
    response: (response) ->
        return response until window.rpc_calls_performance_data
        method = response.config.data?.method
        return response unless method
        duration = Date.now() - response.config.time
        method_data = window.rpc_calls_performance_data[method]
        unless method_data
            window.rpc_calls_performance_data[method] = method_data = { duration: 0.0, calls: 0,  stack: response.config.stack}
        method_data.duration += duration
        ++method_data.calls
        #console.log "------ response method ------>", method, duration
        return response

    responseError: (response) ->
        if response.status == 401 or response.status == 404
            response.repeat = true
            return response
        return '' if response.status == 403
        if response.config?.error_handler
            res = response.config.error_handler(response)
            processRpcError(response, Shared) unless res
            return $q.reject(response)
        processRpcError(response, Shared)
        return $q.reject(response)
