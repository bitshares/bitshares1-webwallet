class Blockchain

    constructor: (@common, @network, @blockchain, @q, @interval) ->
        console.log "blockchain constructor"

    asset_records: {
        XTS:
            symbol: "XTS"
            precision: 0.000001
    }

    init: ->
        console.log "starting client"

    refresh_blockchain: =>
        console.log("refreshing client status")
        @common.get_info().then (data) =>
            @status.alert_level = 1


angular.module("app").service("Blockchain", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Blockchain])
