class Info
    info : {}

    symbol : ""

    is_refreshing : false

    expected_client_version: "0.5.1"

    FULL_SYNC_SECS: 600

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
        @q.all([@common_api.get_info(), @wallet.wallet_get_info(), @blockchain_api.get_info()]).then (results) =>
            data = results[0]
            @info.transaction_scanning = results[1].transaction_scanning
            @info.network_connections = data.network_num_connections
            @info.wallet_open = data.wallet_open
            @info.wallet_unlocked = data.wallet_unlocked
            @info.last_block_time = data.blockchain_head_block_timestamp
            @info.genesis_timestamp = results[2].genesis_timestamp
            @info.seconds_behind = if @info.last_block_time then (Date.now() - @utils.toDate(@info.last_block_time).getTime()) / 1000 else 0
            @info.seconds_from_genesis = if @info.genesis_timestamp then (Date.now() - @utils.toDate(@info.genesis_timestamp).getTime()) / 1000 else 0
            @info.last_block_num = data.blockchain_head_block_num
            if @info.seconds_from_genesis and @info.seconds_from_genesis > 0 and @info.seconds_behind > 0
                @info.percent_synced = Math.round((1.0 - @info.seconds_behind / @info.seconds_from_genesis) * 100.0)
            else
                @info.percent_synced = 0
            @info.blockchain_head_block_age = data.blockchain_head_block_age
            @info.share_supply = data.blockchain_share_supply
            @info.wallet_scan_progress = results[1].scan_progress
            if(!@info.client_version)
              @info.client_version=data.client_version

            @info.delegate_participation = data.blockchain_average_delegate_participation
            @info.alert_level = "grey"
            if @info.delegate_participation
                if @info.delegate_participation > 80
                    @info.alert_level = "green"
                else if @info.delegate_participation > 60
                    @info.alert_level = "yellow"
                else
                     @info.alert_level = "red"

            @common_api.get_config().then (data) =>
                @info.address_prefix = data.address_prefix
                @info.blockchain_name = data.name
                @info.delegate_reg_fee = data.delegate_reg_fee
                @info.asset_reg_fee = data.asset_reg_fee
                @info.transaction_fee = data.transaction_fee
                if @wallet.main_asset
                    @info.income_per_block = data.max_delegate_pay_issued_per_block
                    @info.blockchain_delegate_pay_rate = @utils.formatAsset(@utils.asset(data.max_delegate_pay_issued_per_block, @wallet.main_asset))
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
