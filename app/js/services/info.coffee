class Info
    info : {}

    get : () ->
        if Object.keys(@info).length > 0
            deferred = @q.defer()
            deferred.resolve(@info)
            return deferred.promise
        else
            @refresh_info().then ()=>
                @info

    refresh_info : () ->
        @common_api.get_info().then (data) =>
                #console.log "watch_for_updates get_info:>", data
                if data.blockchain_head_block_num > 0
                    @info.network_connections = data.network_num_connections
                    @info.wallet_open = data.wallet_open
                    @info.wallet_unlocked = data.wallet_unlocked
                    @info.last_block_time = data.blockchain_head_block_timestamp
                    @info.last_block_num = data.blockchain_head_block_num
                    @info.blockchain_head_block_age = data.blockchain_head_block_age
                    @info.income_per_block = data.blockchain_delegate_pay_rate
                    @info.share_supply = data.blockchain_share_supply
                else
                    @info.wallet_unlocked = data.wallet_unlocked

                @blockchain_api.get_security_state().then (data) =>
                    @info.alert_level = data.alert_level
            , =>
                @info.network_connections = 0
                @info.wallet_open = false
                @info.wallet_unlocked = false
                @info.last_block_num = 0

    watch_for_updates: =>
        @interval (=>
            @refresh_info()
        ), 2500

    constructor: (@q, @log, @location, @growl, @common_api, @blockchain, @blockchain_api, @interval) ->
        @watch_for_updates()

angular.module("app").service("Info", ["$q", "$log", "$location", "Growl", "CommonAPI", "Blockchain", "BlockchainAPI", "$interval", Info])
