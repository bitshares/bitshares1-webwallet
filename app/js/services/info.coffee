class Info
    info : {}

    symbol : ""

    is_refreshing : false

    get : () ->
        if Object.keys(@info).length > 0
            deferred = @q.defer()
            deferred.resolve(@info)
            return deferred.promise
        else
            @refresh_info().then ()=>
                @info

    refresh_info : () ->
        @is_refreshing = true
        @q.all([@common_api.get_info(), @wallet.wallet_get_info()]).then (results) =>
            data = results[0]
            #console.log "watch_for_updates get_info:>", results
            @info.transaction_scanning = results[1].transaction_scanning
            @info.network_connections = data.network_num_connections
            @info.wallet_open = data.wallet_open
            @info.wallet_unlocked = data.wallet_unlocked
            @info.last_block_time = data.blockchain_head_block_timestamp
            @info.last_block_num = data.blockchain_head_block_num
            @info.blockchain_head_block_age = data.blockchain_head_block_age
            @info.income_per_block = data.blockchain_delegate_pay_rate
            @info.share_supply = data.blockchain_share_supply
            @blockchain.get_asset(0).then (v)=>
                @info.blockchain_delegate_pay_rate = @utils.formatAsset(@utils.asset(data.blockchain_delegate_pay_rate, v))
            @info.wallet_scan_progress = data.scan_progress
            if(!@info.client_version)
              @info.client_version=data.client_version

            @blockchain_api.get_security_state().then (data) =>
                @info.alert_level = data.alert_level

            @common_api.get_config().then (data) =>
                @info.delegate_reg_fee = data.delegate_reg_fee
                @info.asset_reg_fee = data.asset_reg_fee
                @info.transaction_fee = data.transaction_fee
                @is_refreshing = false
                @symbol = data.symbol
        , =>
            @is_refreshing = false
            @info.network_connections = 0
            @info.wallet_open = false
            @info.wallet_unlocked = false
            @info.last_block_num = 0
            @info.transaction_scanning = false

    watch_for_updates: =>
        @interval (=>
            if !@is_refreshing
                @refresh_info()
        ), 2500

    constructor: (@q, @log, @location, @growl, @common_api, @blockchain, @blockchain_api, @wallet, @interval, @utils) ->

angular.module("app").service("Info", ["$q", "$log", "$location", "Growl", "CommonAPI", "Blockchain", "BlockchainAPI", "Wallet", "$interval", "Utils", Info])
