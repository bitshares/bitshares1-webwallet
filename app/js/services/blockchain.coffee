class Blockchain

    constructor: (@client, @network, @blockchain_api, @q, @interval) ->
        @refresh_asset_records()
        @refresh_delegates()
        console.log "blockchain constructor"
        @watch_for_updates()

    watch_for_updates: =>
        @interval (=>
            @refresh_recent_blocks()
        ), 15000

    # # # # # 
    #  Asset Records

    asset_records: {}
    symbol2records: {}

    populate_asset_record: (record) ->
        @asset_records[record.id] = record #TODO this has extra info we don't need to cache
        @symbol2records[record.symbol] = record
        return @asset_records[record.id]

    refresh_asset_records: ->
        @blockchain_api.list_registered_assets("", -1).then (result) =>
            angular.forEach result, (record) =>
                @populate_asset_record record

    get_asset_record: (id) ->
        if @asset_records[id]
            deferred = @q.defer()
            deferred.resolve(@asset_records[id])
            return deferred.promise
        else
            @blockchain_api.get_asset_record(id).then (result) =>
                record = @populate_asset_record result
                return record
                
    # Asset records
    # # # # #

    block_head_num : 0
    recent_blocks_count : 20
    recent_blocks :
        value : []
        last_block_timestamp: ""
        last_block_round : 0

    refresh_recent_blocks: ->
        @blockchain_api.get_blockcount().then (current_head_num) =>
                if current_head_num > @block_head_num
                    blocks = {}
                    begin = current_head_num - @recent_blocks_count
                    if begin < 1 then begin = 1

                    @blockchain_api.list_blocks(begin + 1, @recent_blocks_count).then (result) =>
                        @recent_blocks.value = result.reverse()
                        if @recent_blocks.value.length > 0
                            @recent_blocks.last_block_timestamp = @recent_blocks.value[0].timestamp
                        @recent_blocks.last_block_round = Math.floor((current_head_num - 1) / (@client.config.num_delegates))
                    @block_head_num = current_head_num

    ##
    # Delegates


    active_delegates: []
    inactive_delegates: []

    id_delegates: {}

    # TODO: finish this mapping, may be in some config or settings
    type_name_map :
            withdraw_op_type : "Withdraw Operation"
            deposit_op_type : "Deposit Operation"
            create_asset_op_type : "Create Asset Operation"
            update_asset_op_type : "Update Asset Operation"
            withdraw_pay_op_type : "Withdraw Pay Operation"
            register_account_op_type : "Register Account Operation"
            update_account_op_type : "Update Account Operation"
            issue_asset_op_type : "Issue Asset Operation"
            submit_proposal_op_type : "Submit Proposal Operation"
            vote_proposal_op_type : "Vote Proposal Operation"
            bid_op_type : "Bid Operation"
            ask_op_type : "Ask Operation"
            short_op_type : "Short Operation"
            cover_op_type : "Cover Operation"
            add_collateral_op_type : "Add Collateral Operation"
            remove_collateral_op_type : "Remove Collateral Operation"


    # TODO
    populate_delegate: (record) ->
        record

    refresh_delegates: ->
        @blockchain_api.list_delegates(0, -1).then (result) =>
            for i in [0 ... @client.config.num_delegates]
                @active_delegates[i] = @populate_delegate(result[i])
                @id_delegates[result[i].id] = result[i]
            for i in [@client.config.num_delegates ... result.length]
                @inactive_delegates[i - @client.config.num_delegates] = @populate_delegate(result[i])
                @id_delegates[result[i].id] = result[i]

angular.module("app").service("Blockchain", ["Client", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Blockchain])
