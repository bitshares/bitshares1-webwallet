class Blockchain

    constructor: (@common, @network, @blockchain_api, @q, @interval) ->
        console.log "blockchain constructor"

    asset_records: {
        XTS:
            symbol: "XTS"
            precision: 0.000001
    }


    get_asset_record: ->
        @blockchain_api.wallet_list_registered_assets
    


angular.module("app").service("Blockchain", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Blockchain])
