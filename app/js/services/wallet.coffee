class Wallet

    accounts: {}

    balances: {}

    transactions: []

    trust_levels: {}

    refresh_balances: ->
        @wallet_api.account_balance("").then (result) =>
            angular.forEach result, (name_bal_pair) =>
                name = name_bal_pair[0]
                balances = name_bal_pair[1]
                angular.forEach balances, (symbol_amt_pair) =>
                    symbol = symbol_amt_pair[0]
                    amount = symbol_amt_pair[1]
                    @blockchain.get_asset_record(symbol).then (asset_record) =>
                        @balances[name][symbol] = @utils.newAsset(amount, symbol, asset_record.precision)

    # turn raw rpc return value into nice object
    populate_account: (val, is_mine) ->
        if not @balances[val.name]
            @balances[val.name] =
                "XTS": @utils.newAsset(0, "XTS", 1000000) #TODO move to utils/config
        @trust_levels[val.name] = val.trust_level
        acct = {
            name: val.name
            active_key: val.active_key_history[val.active_key_history.length - 1][1]
            active_key_history: val.active_key_history
            registered_date: val.registration_date
            is_my_accout: is_mine
        }
        @accounts[acct.name] = acct
        return acct

    refresh_account: (name) ->
        @wallet_api.get_account(name).then (result) => # TODO no such acct?
            @populate_account(result)

    refresh_accounts: ->
        @wallet_api.list_receive_accounts().then (result) =>
            angular.forEach result, (val) =>
                @populate_account(val, true)
            @refresh_balances()
        @wallet_api.list_contact_accounts().then (result) =>
            angular.forEach result, (val) =>
                @populate_account(val, false)
            @refresh_balances()


    create_account: (name, privateData) ->
        @wallet_api.account_create(name, privateData).then (result) =>
            console.log(result)
            @refresh_accounts()

    get_account: (name) ->
        @refresh_balances()
        if @accounts[name]
            deferred = @q.defer()
            deferred.resolve(@accounts[name])
            return deferred.promise
        else
            @wallet_api.get_account(name).then (result) =>
                acct = @populate_account(result)
                return acct

    set_trust: (name, trust_level) ->
        @trust_levels[name] = trust_level
        @wallet_api.set_delegate_trust_level(name, trust_level).then () =>
            @refresh_account(name)
        return



    refresh_transactions: (name) ->
        console.log name

    # TODO: search for all deposit_op_type with asset_id 0 and sum them to get amount
    # TODO: cache transactions
    # TODO: sort transactions, show the most recent ones on top
    get_transactions: (account_name) ->
        @wallet_api.account_transaction_history(account_name).then (result) =>
            console.log "--- transactions = ", result
            transactions = []
            angular.forEach result, (val, key) =>
                blktrx=val.block_num + "." + val.trx_num
                console.log blktrx
                console.log val.amount
                transactions.push
                    block_num: ((if (blktrx is "-1.-1") then "Pending" else blktrx))
                    #trx_num: Number(key) + 1
                    time: new Date(val.received_time*1000)
                    amount: @utils.newAsset(val.amount.amount, "XTS", 1000000) #TODO
                    from: val.from_account
                    to: val.to_account
                    memo: val.memo_message
                    id: val.trx_id.substring 0, 8
                    fee: @utils.newAsset(val.fees, "XTS", 1000000) #TODO
                    vote: "N/A"
            transactions

           



    create: (wallet_name, spending_password) ->
        @rpc.request('wallet_create', [wallet_name, spending_password])

    get_balance: ->
        @rpc.request('wallet_get_balance').then (response) ->
            asset = response.result[0]
            {amount: asset[0], asset_type: asset[1]}

    get_wallet_name: ->
        @rpc.request('wallet_get_name').then (response) =>
          console.log "---- current wallet name: ", response.result
          @wallet_name = response.result

    get_info: ->
        @rpc.request('get_info').then (response) =>
          response.result

    wallet_add_contact_account: (name, address) ->
        @rpc.request('wallet_add_contact_account', [name, address]).then (response) =>
          response.result

    wallet_account_register: (account_name, pay_from_account, public_data, as_delegate) ->
        @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, as_delegate]).then (response) =>
          response.result

    wallet_rename_account: (current_name, new_name) ->
        @rpc.request('wallet_rename_account', [current_name, new_name]).then (response) =>
          response.result

    blockchain_list_delegates: ->
        @rpc.request('blockchain_list_delegates').then (response) =>
          response.result

    blockchain_get_security_state: ->
        @rpc.request('blockchain_get_security_state').then (response) =>
          response.result


    open: ->
        @rpc.request('wallet_open', ['default']).then (response) =>
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
              @info.network_connections = data.network_num_connections
              @info.wallet_open = data.wallet_open
              @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0
              @info.last_block_time = data.blockchain_head_block_time
              @info.last_block_num = data.blockchain_head_block_num
              @info.last_block_time_rel = data.blockchain_head_block_time_rel
            else
              @info.wallet_unlocked = data.wallet_unlocked_seconds_remaining > 0
          , =>
            @info.network_connections = 0
            @info.wallet_open = false
            @info.wallet_unlocked = false
            @info.last_block_num = 0
          @blockchain_get_security_state().then (data) =>
            @info.alert_level = data.alert_level
        ), 2500

    constructor: (@q, @log, @growl, @rpc, @blockchain, @utils, @wallet_api, @interval) ->
        @log.info "---- Wallet Constructor ----"
        @wallet_name = ""
        @info =
            network_connections: 0
            balance: 0
            wallet_open: false
            last_block_num: 0
            last_block_time: null
            alert_level: null
        @watch_for_updates()


angular.module("app").service("Wallet", ["$q", "$log", "Growl", "RpcService", "Blockchain", "Utils", "WalletAPI", "$interval", Wallet])
