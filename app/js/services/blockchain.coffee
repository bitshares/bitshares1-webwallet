class Blockchain

    constructor: (@common, @network, @blockchain_api, @q, @interval) ->
        @refresh_asset_records()
        console.log "blockchain constructor"

    asset_records: {}

    populate_asset_record: (record) ->
        @asset_records[record.symbol] = record #TODO this has extra info we don't need to cache
        return @asset_records[record.symbol]

    refresh_asset_records: ->
        me = @
        @blockchain_api.blockchain_list_registered_assets("", -1).then (result) ->
            angular.forEach result, (record) ->
                me.populate_asset_record record

    get_asset_record: (symbol) ->
        me = @
        if @asset_records[symbol]
            deferred = @q.defer()
            deferred.resolve(@asset_records[symbol])
            return deferred.promise
        else
            @blockchain_api.blockchain_get_asset_record(symbol).then (result) ->
                record = me.populate_asset_record result
                return record
                
    


angular.module("app").service("Blockchain", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Blockchain])
