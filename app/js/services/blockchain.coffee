class Blockchain

    constructor: (@client, @network, @rpc, @blockchain_api, @utils, @q, @interval) ->

    # # # # #
    #  Blockchain Config
    config : {}

    get_info : () ->
        if Object.keys(@config).length > 0
            deferred = @q.defer()
            deferred.resolve(@config)
            return deferred.promise
        else
            @rpc.request("blockchain_get_info", []).then (result) =>
                @config = result.result
                @config.page_count = 20
                return @config

    list_accounts: (start_name, limit) ->
        @rpc.request('blockchain_list_accounts', [start_name, limit]).then (response) ->
            reg = []
            angular.forEach response.result, (val, key) =>
                reg.push
                    name: val.name
                    owner_key: val.owner_key
                    public_data: val.public_data
                    registration_date: val.registration_date
            reg

    # # # # # 
    #  Asset Records

    asset_records: {}
    symbol2records: {}

    populate_asset_record: (record) ->
        @asset_records[record.id] = record #TODO this has extra info we don't need to cache
        @symbol2records[record.symbol] = record
        return @asset_records[record.id]

    refresh_asset_records: ->
        @blockchain_api.list_assets("", -1).then (result) =>
            angular.forEach result, (record) =>
                @populate_asset_record record

    get_asset: (id) ->
        return @symbol2records[id] if !$.isNumeric(id)
        if @asset_records[id]
            deferred = @q.defer()
            deferred.resolve(@asset_records[id])
            return deferred.promise
        else
            @blockchain_api.get_asset(id).then (result) =>
                record = @populate_asset_record result
                return record

    get_markets: ->
        markets = []
        markets_hash = {}
        angular.forEach @asset_records, (asset1) =>
            angular.forEach @asset_records, (asset2) =>
                asset1_symbol = if asset1.issuer_account_id == -2 then "Bit" + asset1.symbol else asset1.symbol
                asset2_symbol = if asset2.issuer_account_id == -2 then "Bit" + asset2.symbol else asset2.symbol
                if asset1.id > asset2.id
                    value = asset1_symbol + ":" + asset2_symbol
                    markets_hash[value] = value
                else if asset2.id > asset1.id
                    value = asset2_symbol + ":" + asset1_symbol
                    markets_hash[value] = value
        angular.forEach markets_hash, (key, value) ->
            markets.push value
        #console.log markets
        markets


    # Asset records
    # # # # #

    block_head_num : 0
    recent_blocks_count : 20
    recent_blocks :
        value : []
        last_block_timestamp: ""
        last_block_round : 0

    get_blocks_with_missed: (first_block, blocks_to_fetch) ->
        @blockchain_api.get_block_count().then (head_block) =>
            if first_block > head_block
                def = @q.defer()
                def.resolve([])
                return def.promise
            if first_block + blocks_to_fetch > head_block
                blocks_to_fetch = head_block - first_block
            requests =
                blocks: @blockchain_api.list_blocks(first_block, blocks_to_fetch)
                signers: @rpc.request("batch", ["blockchain_get_block_signee", [i] for i in [first_block...first_block+blocks_to_fetch]])
                missed: @rpc.request("batch", ["blockchain_list_missing_block_delegates", [i] for i in [first_block...first_block+blocks_to_fetch]])
                config: @get_info()
            @q.all(requests).then (results) =>
                blocks = results.blocks
                missed = results.missed.result
                signers = results.signers.result
                config = results.config

                merged = []
                for i in [0...blocks.length]
                    blocks[i].delegate_name = signers[i]
                    blocks[i].timestamp = @utils.toDate(blocks[i].timestamp)
                    blocks[i].latency = blocks[i].latency/1000000
                    for j in [0...missed[i].length]
                        timestamp = new Date(+blocks[i].timestamp - ((missed[i].length - j)) * (1000 * config.block_interval))
                        merged.push
                            block_num: -2
                            timestamp: timestamp
                            delegate_name: missed[i][j]
                    merged.push blocks[i]
                return merged

    get_last_block_round: ->
        if @recent_blocks.last_block_round
            deferred = @q.defer()
            deferred.resolve(@recent_blocks.last_block_round)
            return deferred.promise
        else
            @q.all({ head_num: @blockchain_api.get_block_count(), config: @get_info() }).then (results) =>
                console.log results
                @recent_blocks.last_block_round = Math.floor((results.head_num - 1) / (results.config.page_count))
                @block_head_num = results.head_num
                return @recent_blocks.last_block_round

    ##
    # Delegates


    active_delegates: []
    inactive_delegates: []
    all_delegates: {}

    id_delegates: {}
    delegate_active_hash_map: {}
    delegate_inactive_hash_map: {}
    avg_act_del_pay_rate=0

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
    populate_delegate: (record, active) ->
        record.active = active
        @all_delegates[record.name] = record
        record

    refresh_delegates: ->
        # TODO: delegates paginator is needed
        @avg_act_del_pay_rate=0
        @q.all({dels: @blockchain_api.list_delegates(0, 1000), config: @get_info()}).then (results) =>
            for i in [0 ... results.config.delegate_num]
                @active_delegates[i] = @populate_delegate(results.dels[i], true)
                @id_delegates[results.dels[i].id] = results.dels[i]
                @delegate_active_hash_map[@active_delegates[i].name]=true
                @avg_act_del_pay_rate+=@active_delegates[i].delegate_info.pay_rate
            @avg_act_del_pay_rate=@avg_act_del_pay_rate/results.config.delegate_num
            for i in [results.config.delegate_num ... results.dels.length]
                @inactive_delegates[i - results.config.delegate_num] = @populate_delegate(results.dels[i], false)
                @id_delegates[results.dels[i].id] = results.dels[i]
                @delegate_inactive_hash_map[@inactive_delegates[i-results.config.delegate_num].name]=true
                
    price_history: (quote_symbol, base_symbol, start_time, duration, granularity) ->
        #@blockchain_api.market_price_history(quote_symbol, base_symbol, start_time, duration, granularity).then (result) ->
        #    console.log 'price_history -----', result
        json = '''
        [[
        "20200101T175300",{
          "highest_bid": {
            "ratio": "0.045",
            "quote_asset_id": 1,
            "base_asset_id": 0
          },
          "lowest_ask": {
            "ratio": "0.0656",
            "quote_asset_id": 1,
            "base_asset_id": 0
          },
          "volume": 1
        }
        ],
        "20200101T175400",{
          "highest_bid": {
            "ratio": "0.045",
            "quote_asset_id": 1,
            "base_asset_id": 0
          },
          "lowest_ask": {
            "ratio": "0.0656",
            "quote_asset_id": 1,
            "base_asset_id": 0
          },
          "volume": 1
        }
        ]
        '''
        deferred = @q.defer()
        deferred.resolve(JSON.parse(json))
        return deferred.promise


angular.module("app").service("Blockchain", ["Client", "NetworkAPI", "RpcService", "BlockchainAPI", "Utils", "$q", "$interval", Blockchain])
