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

servicesModule.factory "myHttpInterceptor", ($q, $location, Shared) ->
    dont_report_methods = []

    responseError: (response) ->
        dont_report = false
        method = null
        error_msg = if response.data?.error?.message? then response.data.error.message else response.data

        if response.config? and response.config.url.match(/\/rpc$/)
            if error_msg.match(/No such wallet exists/)
                $location.path("/createwallet")
                dont_report = true
            if error_msg.match(/The wallet must be opened/)
                $location.path("/unlockwallet")
                dont_report = true
            method = response.config.data?.method
        else if response.message
            error_msg = response.message

        dont_report = true if response.status == 404

        unless dont_report
            error_msg = error_msg.substring(0, 512)
            stack = response.config.stack
            stack = stack.replace(/http\:.+app\.js([\d:]+)/mg, "app.js$1").replace(/^Error/,"RPC Server Error in '#{method}'") if stack
            console.log "RPC Server Error: #{error_msg} (#{response.status})\n#{response.config.stack}"
            magic_unicorn.log_message("rpc error: #{error_msg} (#{response.status})\n#{stack}") if magic_unicorn?
            Shared.addError(error_msg, stack)
        return $q.reject(response)
