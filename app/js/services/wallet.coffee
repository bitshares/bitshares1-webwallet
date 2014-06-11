class Wallet

    contact_accounts: {}

    receive_accounts: {}

    balances: {}

    transactions:
        "asd314sadn3254": "pretend tx object"


    refresh_balances: ->
        me = @
        @wallet_api.account_balance("").then (result) ->
            angular.forEach result, (key, val) ->
                balances[key] = val

    # turn raw rpc return value into nice object
    populate_account: (val, is_receive) ->
        acct = {
            name: val.name
            active_key: val.active_key_history[val.active_key_history.length - 1][1]
            active_key_history: val.active_key_history
            registered_date: @utils.toDate(val.registration_date)
        }
        if is_receive
            @receive_accounts[acct.name] = acct
        else
            @contact_accounts[acct.name] = acct
        return acct

    refresh_accounts: ->
        me = @
        @refresh_balances()
        @wallet_api.list_receive_accounts().then (result) ->
            angular.forEach result, (val) ->
                me.populate_account(val, true)

    create_account: (name, privateData) ->
        me = @
        @wallet_api.account_create(name, privateData).then (result)->
            console.log(result)
            me.refresh_accounts()

    get_account: (name) ->
        me = @
        if @receive_accounts[name]
            deferred = @q.defer()
            deferred.resolve(@receive_accounts[name])
            return deferred.promise
        else if @contact_accounts[name]
            deferred = @q.defer()
            deferred.resolve(@contact_accounts[name])
            return deferred.promise
        else
            @wallet_api.get_account(name).then (result) ->
                acct = me.populate_account(result, true) #TODO add "has_private_key" as field on RPC return obj so we know where to put it
                return acct
    
    get_all_transactions: ->
        console.log("TODO")

    get_transactions_for: (name) ->
        console.log("TODO")

    create: (wallet_name, spending_password) ->
        @rpc.request('wallet_create', [wallet_name, spending_password]).then (response) =>
            success()

    get_balance: ->
        @rpc.request('wallet_get_balance').then (response) ->
            asset = response.result[0]
            {amount: asset[0], asset_type: asset[1]}

    get_wallet_name: ->
        @rpc.request('wallet_get_name').then (response) =>
          console.log "---- current wallet name: ", response.result
          @wallet_name = response.result

    get_info: ->
        @rpc.request('get_info').then (response) ->
          response.result

    wallet_add_contact_account: (name, address) ->
        @rpc.request('wallet_add_contact_account', [name, address]).then (response) ->
          response.result

    wallet_account_register: (account_name, pay_from_account, public_data, as_delegate) ->
        @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, as_delegate]).then (response) ->
          response.result

    wallet_rename_account: (current_name, new_name) ->
        @rpc.request('wallet_rename_account', [current_name, new_name]).then (response) ->
          response.result

    blockchain_list_delegates: ->
        @rpc.request('blockchain_list_delegates').then (response) ->
          response.result

    open: ->
        @rpc.request('wallet_open', ['default']).then (response) ->
          response.result

    wallet_account_balance: ->
        @rpc.request('wallet_account_balance').then (response) ->
          response.result

    get_block: (block_num)->
        @rpc.request('blockchain_get_block_by_number', [block_num]).then (response) ->
          response.result

    wallet_get_account: (name)->
        @rpc.request('wallet_get_account', [name]).then (response) ->
          response.result

    wallet_remove_contact_account: (name)->
        @rpc.request('wallet_remove_contact_account', [name]).then (response) ->
          response.result

    blockchain_get_config: ->
        @rpc.request('blockchain_get_config').then (response) ->
          response.result

    wallet_set_delegate_trust_level: (delName, trust)->
        @rpc.request('wallet_set_delegate_trust_level', [delName, trust]).then (response) ->
          response.result

    wallet_list_contact_accounts: ->
        @rpc.request('wallet_list_contact_accounts').then (response) ->
          response.result

    execute_command_line: (command)->
        @rpc.request('execute_command_line', [command]).then (response) ->
          response.result=">> " + command + "\n\n" + response.result
      

    blockchain_list_registered_accounts: ->
        @rpc.request('blockchain_list_registered_accounts').then (response) ->
          reg = []
          console.log response.result
          angular.forEach response.result, (val, key) =>
            reg.push
              name: val.name
              owner_key: val.owner_key
          reg

    watch_for_updates: =>
        @interval (=>
          @get_info().then (data) =>
            #console.log "watch_for_updates get_info:>", data
            if data.blockchain_head_block_num > 0
              @get_block(data.blockchain_head_block_num).then (block) =>
                @info.network_connections = data.network_num_connections
                @info.wallet_open = data.wallet_open
                @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0
                @info.last_block_time = block.blockchain_head_block_time
                @info.last_block_num = data.blockchain_head_block_num
            else
              @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0
          , =>
            @info.network_connections = 0
            @info.wallet_open = false
            @info.wallet_unlocked = false
            @info.last_block_num = 0
        ), 2500

    get_transactions: (account)=>
    # TODO: search for all deposit_op_type with asset_id 0 and sum them to get amount
    # TODO: cache transactions
    # TODO: sort transactions, show the most recent ones on top
        @rpc.request("wallet_account_transaction_history", [account]).then (response) =>
            console.log "--- transactions = ", response.result
            transactions = []
            angular.forEach response.result, (val, key) =>
              blktrx=val.block_num + "." + val.trx_num
              console.log blktrx
              transactions.push
                block_num: ((if (blktrx is "-1.-1") then "Pending" else blktrx))
                #trx_num: Number(key) + 1
                time: new Date(val.received_time*1000)
                amount: val.amount.amount
                from: val.from_account
                to: val.to_account
                memo: val.memo_message
                id: val.trx_id.substring 0, 8
                fee: val.fees
                vote: "N/A"
            transactions


    constructor: (@q, @log, @rpc, @blockchain, @utils, @wallet_api, @interval) ->
        @log.info "---- Wallet Constructor ----"
        @wallet_name = ""
        @info =
            network_connections: 0
            balance: 0
            wallet_open: false
            last_block_num: 0
            last_block_time: null
        @watch_for_updates()


angular.module("app").service("Wallet", ["$q", "$log", "RpcService", "Blockchain", "Utils", "WalletAPI", "$interval", Wallet])
