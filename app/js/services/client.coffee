class Client

    constructor: (@common, @network, @blockchain, @q, @interval) =>
        @interval (@refresh_status, undefined, 2500)

    init: ->
        console.log "starting client"

    status:
        network_connection: 0
        alert_level: 0
        last_block_num: 0
        last_block_time: null

    refresh_status: =>
        console.log("refreshing client status")
        CommonAPI.get_info().then (data) =>
            console.log(data)


angular.module("app").service("Client", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Client])
