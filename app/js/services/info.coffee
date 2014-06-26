class Info
    watch_for_updates: =>
        @interval (=>
            @common_api.get_info().then (data) =>
                #console.log "watch_for_updates get_info:>", data
                if data.blockchain_head_block_num > 0
                    @info.network_connections = data.network_num_connections
                    @info.wallet_open = data.wallet_open
                    @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0
                    @info.last_block_time = data.blockchain_head_block_time
                    @info.last_block_num = data.blockchain_head_block_num
                    @info.last_block_time_rel = data.blockchain_head_block_time_rel
                else
                    @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0

                @blockchain_api.get_security_state().then (data) =>
                    @info.alert_level = data.alert_level
            , =>
                @info.network_connections = 0
                @info.wallet_open = false
                @info.wallet_unlocked = false
                @info.last_block_num = 0
        ), 2500

                  #if @info.wallet_open

    constructor: (@q, @log, @location, @growl, @common_api, @blockchain, @blockchain_api, @interval) ->
        @info =
            network_connections: 0
            balance: 0
            wallet_open: false
            last_block_num: 0
            last_block_time: null
            alert_level: null
        @watch_for_updates()

angular.module("app").service("Info", ["$q", "$log", "$location", "Growl", "CommonAPI", "Blockchain", "BlockchainAPI", "$interval", Info])
