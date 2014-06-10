class Client

    constructor: (@common, @network, @blockchain, @q, @interval) ->
        console.log "Client constructor"
        @interval @refresh_status, 3000

    init: ->
        console.log "starting client"

    status:
        network_connection: 0
        alert_level: 0
        last_block_num: 0
        last_block_time: null

    # This will repopulate "real-time" info
    refresh_status: =>
        console.log("refreshing client status")
        @common.get_info().then (data) =>
            @status.alert_level = 1



angular.module("app").service("Client", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Client])
