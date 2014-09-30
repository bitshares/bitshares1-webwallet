servicesModule = angular.module("app.services")
servicesModule.factory "RpcService", ($http) ->
    request: (method, params) ->
        reqparams = {method: method, params: params || []}
        http_params =
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
            console.log("rpc.coffee",method,params,response) if not (method in
                #filter out re-occuring rpc calls
                ["wallet_get_info","wallet_get_setting","wallet_account_balance",
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
                ]
            )
            response.data or response
