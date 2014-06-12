class Blockchain

    constructor: (@common, @network, @blockchain_api, @q, @interval) ->
        @refresh_asset_records()
        console.log "blockchain constructor"

    ##  
    #  Asset Records

    asset_records: {}

    populate_asset_record: (record) ->
        @asset_records[record.id] = record #TODO this has extra info we don't need to cache
        return @asset_records[record.id]

    refresh_asset_records: ->
        @blockchain_api.blockchain_list_registered_assets("", -1).then (result) =>
            angular.forEach result, (record) =>
                @populate_asset_record record

    get_asset_record: (id) ->
        if @asset_records[id]
            deferred = @q.defer()
            deferred.resolve(@asset_records[id])
            return deferred.promise
        else
            @blockchain_api.blockchain_get_asset_record(id).then (result) =>
                record = @populate_asset_record result
                return record
                
    # Asset records
    # #

    ##
    # Delegates


    active_delegates: []
    inactive_delegats: []

    populate_delegate: (record) ->
        console.log "todo"

    refresh_delegates: ->
        console.log "todo"
    

angular.module("app").service("Blockchain", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Blockchain])
