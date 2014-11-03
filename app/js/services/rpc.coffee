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
        #console.log "+++ RpcService <#{http_params.data.method}>"
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

            ###console.log("RpcService <#{http_params.data.method}> response:", response, "params:", params) unless method in [
                "wallet_open","wallet_lock","wallet_unlock","wallet_create","batch",
                "wallet_get_info","wallet_get_setting","wallet_account_balance",
                "wallet_set_setting","wallet_account_transaction_history ",
                "wallet_market_order_list","wallet_get_account","wallet_account_yield",
                "wallet_get_transaction_fee","wallet_list_accounts",
                "wallet_account_vote_summary",
                "get_info","get_config",
                "blockchain_list_assets","blockchain_get_asset",
                "blockchain_list_delegates","blockchain_get_account",
                "blockchain_get_security_state","blockchain_get_info",
                "blockchain_market_list_asks","wallet_account_transaction_history",
                "blockchain_market_list_covers","blockchain_market_list_bids",
                "blockchain_market_status","blockchain_market_order_history",
                "blockchain_get_feeds_for_asset","blockchain_market_get_asset_collateral",
                "blockchain_market_list_shorts","blockchain_market_price_history"
            ]###
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

    # temp enable for debugging
#    polling: (method) ->
#        method in [
#            "wallet_open","wallet_lock","wallet_unlock","wallet_create","batch",
#            "wallet_get_info","wallet_get_setting","wallet_account_balance",
#            "wallet_set_setting","wallet_account_transaction_history ",
#            "wallet_market_order_list","wallet_get_account","wallet_account_yield",
#            "wallet_get_transaction_fee","wallet_list_accounts",
#            "wallet_account_vote_summary",
#            "get_info","get_config",
#            "blockchain_list_assets","blockchain_get_asset",
#            "blockchain_list_delegates","blockchain_get_account",
#            "blockchain_get_security_state","blockchain_get_info",
#            "blockchain_market_list_asks","wallet_account_transaction_history",
#            "blockchain_market_list_covers","blockchain_market_list_bids",
#            "blockchain_market_status","blockchain_market_order_history",
#            "blockchain_get_feeds_for_asset","blockchain_market_get_asset_collateral",
#            "blockchain_market_list_shorts","blockchain_market_price_history"
#        ]
