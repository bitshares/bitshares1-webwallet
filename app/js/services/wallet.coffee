class Wallet

    accounts: {}

    balances: {}
    bonuses: {}
    
    open_orders_balances: {}

    asset_balances : {}

    transactions: {"*": []}
    transactions_loading_promise: null
    transactions_last_block: 0
    transactions_all_by_id: {}
    transactions_last_time: 0
    transactions_counter: 0

    # set in constructor
    timeout: null

    autocomplete: true

    pendingRegistrations: {}

    current_account: null
    
    #Long time
    backendTimeout: 999999

    info: {}

    main_asset: null

    interface_locale: null

    set_current_account: (account) ->
        @current_account = account
        @set_setting("current_account", account.name)
    
    check_wallet_status: ->
        deferred = @q.defer()
        @open().then =>
            @wallet_get_info().then (result) =>
                deferred.resolve()
                @get_setting('timeout').then (result) =>
                if result && result.value
                    @timeout = result.value
                    @idle._options().idleDuration = @timeout
                    @idle.watch()
                @get_setting('autocomplete').then (result) =>
                    @autocomplete = result.value if result
                @get_setting('interface_locale').then (result) =>
                    if result and result.value
                        @interface_locale = result.value
                        @translate.use(result.value)
                if not result.unlocked
                    navigate_to('unlockwallet')
            , (error) ->
                deferred.reject(error)
        , (error) ->
                deferred.reject(error)

        return deferred.promise

    refresh_balances: ->
        requests =
            refresh_bonuses: @refresh_bonuses()
            account_balances : @wallet_api.account_balance("")
            refresh_assets: @blockchain.refresh_asset_records()
            main_asset: @blockchain.get_asset(0)

        @q.all(requests).then (results) =>
            @main_asset = results.main_asset
            @balances = {}
            @asset_balances = {}
            angular.forEach results.account_balances, (name_bal_pair) =>
                name = name_bal_pair[0]
                balances = name_bal_pair[1]
                angular.forEach balances, (asset_id_amt_pair) =>
                    asset_id = asset_id_amt_pair[0]
                    asset_record = @blockchain.asset_records[asset_id]
                    symbol = asset_record.symbol
                    amount = asset_id_amt_pair[1]
                    @balances[name] = @balances[name] || {}
                    @balances[name][symbol] = @utils.newAsset(amount, symbol, asset_record.precision)
                    @asset_balances[asset_id] = @asset_balances[asset_id] || 0
                    @asset_balances[asset_id] = @asset_balances[asset_id] + amount
            angular.forEach @accounts, (acct) =>
                #if acct.is_my_account
                    #@refresh_open_order_balances(acct.name)
                    
                if acct.is_my_account and !@balances[acct.name]
                    @balances[acct.name] = {}
                    @balances[acct.name][@main_asset.symbol] = @utils.asset(0, @main_asset)

    refresh_open_order_balances: (name) ->
        if !@open_orders_balances[name]
            @open_orders_balances[name] = {}
        @open_order_balances[name]["BTSX"] = 0
        @wallet_api.account_order_list(name).then (result) =>
            angular.forEach result, (order) =>
                base = @blockchain.asset_records[order.market_index.order_price.base_asset_id]
                quote = @blockchain.asset_records[order.market_index.order_price.quote_asset_id]
                if order.type == "ask_order"
                    @open_orders_balances[name][base.symbol] = @utils.asset(order.state.balance, @blockchain.symbol2records[base.symbol])
                if order.type == "bid_order" or order.type == "short_order"
                    @open_orders_balances[name][quote.symbol] = @utils.asset(order.state.balance, @blockchain.symbol2records[quote.symbol])

    refresh_bonuses_promise: null
    
    refresh_bonuses: ->
        if @utils.too_soon("refresh_bonuses", 10 * 1000)
            return @refresh_bonuses_promise.then (response) =>
                #console.log "wallet_account_yield(): too soon #{response}"
                return response
    
        @refresh_bonuses_promise = @wallet_api.account_yield("").then (response) =>
            @blockchain.refresh_asset_records().then () =>
                #console.log "wallet_account_yield()",response
                angular.forEach response, (name_balances_pair) =>
                    name = name_balances_pair[0]
                    #console.log "refresh_bonuse #{name}"
                    angular.forEach name_balances_pair[1], (asset_id_amt_pair) =>
                        asset_id = asset_id_amt_pair[0]
                        symbol = @blockchain.asset_records[asset_id].symbol
                        amount = asset_id_amt_pair[1]
                        @bonuses[name] = @bonuses[name] || {}
                        @bonuses[name][symbol] = @utils.newAsset(amount, symbol, @blockchain.symbol2records[symbol].precision)


#    account_yield: []
#
#    #empty account_name = all
#    wallet_account_yield: (account_name = "") ->
#        if @utils.too_soon("wallet_account_yield #{account_name}", 10 * 1000)
#            return @account_yield[account_name].then (result) =>
#                console.log "wallet_account_yield(#{account_name}): too soon #{result}"
#                return result
#
#        @account_yield[account_name] = @wallet_api.account_yield(account_name).then (result) =>
#            console.log "wallet_account_yield(#{account_name})", result
#            result

    count_my_accounts: ->
        accounts = 0
        angular.forEach @accounts, (acct, name) ->
            if acct.is_my_account
                accounts += 1
        return accounts

    count_my_delegates: ->
        delegates = 0
        angular.forEach @accounts, (acct, name) ->
            if acct.is_my_account and acct.delegate_info != null
                delegates += 1
        return delegates

    # turn raw rpc return value into nice object
    populate_account: (val) ->
        acct = val
        acct["active_key"] = val.active_key_history[val.active_key_history.length - 1][1]
        #console.log "populate_account",acct.name
        @accounts[acct.name] = acct
        return acct

    refresh_account: (name) ->
        @wallet_api.get_account(name).then (result) => # TODO no such acct?
            @populate_account(result)
            @refresh_balances()

    refresh_accounts: (prevent_rapid_refresh = false) ->
        if prevent_rapid_refresh and @utils.too_soon('refresh_accounts', 10 * 1000)
            deferred = @q.defer()
            deferred.resolve()
            return deferred.promise

        #console.log "refresh_accounts clearing cache"
        @accounts = {}
        @wallet_api.list_accounts().then (result) =>
            angular.forEach result, (val) =>
                @populate_account(val)
            @refresh_balances()

    get_setting: (name) ->
        @wallet_api.get_setting(name)

    set_setting: (name, value) ->
        @wallet_api.set_setting(name, value).then (result) =>
            result

    create_account: (name, privateData, error_handler) ->
        @wallet_api.account_create(name, privateData, error_handler).then (result) =>
            @refresh_accounts()
            result

    account_update_private_data: (name, privateData) ->
        @wallet_api.account_update_private_data(name, privateData).then (result) =>
            @refresh_accounts()

    get_accounts: () ->
        if Object.keys(@accounts).length > 0
            deferred = @q.defer()
            deferred.resolve(@accounts)
            return deferred.promise
        else
            @refresh_accounts().then =>
                return @accounts

    get_account: (name) ->
        @refresh_balances()
        #console.log "wallet_get_account start",name
        if @accounts[name]
            #console.log "wallet_get_account found",name
            deferred = @q.defer()
            deferred.resolve(@accounts[name])
            return deferred.promise
        else
            @wallet_api.get_account(name).then (result) =>
                acct = @populate_account(result)
                return acct
            ,
            (error) =>
                @blockchain_api.get_account(name).then (result) =>
                    acct = if result then @populate_account(result) else null
                    return acct

    approve_account: (name, approve) ->
        @wallet_api.account_set_approval(name, approve)

    update_transaction: (t, val) ->
        time = @utils.toDate(val.timestamp)
        t.is_virtual = val.is_virtual
        t.is_confirmed = val.is_confirmed
        t.is_market = val.is_market
        t.is_market_cancel = val.is_market_cancel
        t.block_num = val.block_num
        t.error = val.error
        t.trx_num = val.trx_num
        t.time = time
        t.expiration_pretty_time = @utils.toDate(val.expiration_timestamp).toLocaleString(undefined, {timeZone:"UTC"})
        t.pretty_time = time.toLocaleString(undefined, {timeZone:"UTC"})
        t.fee = @utils.asset(val.fee.amount, @blockchain.asset_records[val.fee.asset_id])
        t.vote = "N/A"
        if t.status != "rebroadcasted"
            t.status = if not val.is_confirmed and not val.is_virtual then "pending" else "-"

    process_transaction: (val) ->
        existing_transaction = @transactions_all_by_id[val.trx_id]
        if existing_transaction and existing_transaction.id
            @update_transaction(existing_transaction, val)
            existing_transaction.time.setMilliseconds(existing_transaction.num)
            return
        involved_accounts = {}
        ledger_entries = []
        used_balance_symbols = {}
        angular.forEach val.ledger_entries, (entry) =>
            involved_accounts[entry.from_account] = true if @accounts[entry.from_account]
            involved_accounts[entry.to_account] = true if @accounts[entry.to_account]
            running_balances = {}
            for acct in entry.running_balances
                account_name = acct[0]
                balances = acct[1]
                continue unless involved_accounts[account_name]
                #console.log "------ running_balances item ------>",account_name, balances
                running_balances[account_name] = []
                for item in balances
                    asset_record = @blockchain.asset_records[item[1].asset_id]
                    asset = @utils.asset(item[1].amount, asset_record)
                    running_balances[account_name].push asset unless used_balance_symbols[asset.symbol]
                    used_balance_symbols[asset.symbol] = true

            ledger_entries.push
                from: entry.from_account
                to: entry.to_account
                amount: entry.amount.amount
                amount_asset : @utils.asset(entry.amount.amount, @blockchain.asset_records[entry.amount.asset_id])
                memo: entry.memo
                running_balances: running_balances

        transaction = { id: val.trx_id }
        transaction.ledger_entries = ledger_entries
        @update_transaction(transaction, val)
        if val.timestamp == @transactions_last_time
            @transactions_counter += 1
        else
            @transactions_counter = 0
        @transactions_last_time = val.timestamp
        #console.log "------ process_transaction ------>", val.trx_id, val.block_num , val.timestamp, @transactions_last_time,@transactions_counter
        transaction.time.setMilliseconds(@transactions_counter)
        transaction.num = @transactions_counter

        @transactions_all_by_id[val.trx_id] = transaction

        @transactions["*"].unshift transaction
        angular.forEach involved_accounts, (val, account) =>
            @transactions[account] ||= []
            @transactions[account].unshift transaction

    refresh_transactions: ->
        return @transactions_loading_promise if @transactions_loading_promise
        deffered = @q.defer()

        @transactions_loading_promise = deffered.promise

        refresh_asset_records_promise = @blockchain.refresh_asset_records()
        refresh_asset_records_promise.catch (error) =>
            @transactions_loading_promise = null
            deffered.reject(error)

        refresh_asset_records_promise.then =>

            account_transaction_history_promise = @wallet_api.account_transaction_history("", "", 0, @transactions_last_block, -1)
            account_transaction_history_promise.catch (error) =>
                @transactions_loading_promise = null
                deffered.reject(error)

            account_transaction_history_promise.then (result) =>
                for val in result
                    #console.log "------ account_transaction ------>", val
                    @transactions_last_block = val.block_num
                    @process_transaction(val) if val.is_confirmed

                # pending transactions
                pending_transactions_promise = @wallet_api.account_transaction_history("", "", 0, 0, 0)
                pending_transactions_promise.then (result) =>
                    for val in result
                        @process_transaction(val) if not val.is_confirmed and not val.is_virtual
                pending_transactions_promise.finally =>
                    @transactions_loading_promise = null
                    deffered.resolve(@transactions)

        return @transactions_loading_promise


    refresh_transactions_on_new_block: () ->
        @refresh_transactions()
#        @refresh_transactions().then =>
#            if @transactions["*"].length > 0
#                #@growl.notice "", "You just received a new transaction!"
#                angular.forEach @accounts, (account, name) =>
#                    if account.is_my_account
#                        @refresh_transactions(name)
#
#    # TODO: search for all deposit_op_type with asset_id 0 and sum them to get amount
#    # TODO: sort transactions, show the most recent ones on top
#    get_transactions: (account_name) ->
#        account_name_key = account_name || "*"
#        if @transactions[account_name_key]
#            deferred = @q.defer()
#            deferred.resolve(@transactions[account_name_key])
#            return deferred.promise
#        else
#            @blockchain.get_asset(0).then (main_asset) ->
#                @wallet_account_transaction_history(account_name).then (result) =>
#                    @transactions[account_name_key] = []
#                    angular.forEach result, (val, key) =>
#                        blktrx=val.block_num + "." + val.trx_num
#                        @transactions[account_name_key].push
#                            block_num: ((if (blktrx is "0.0") then "Pending" else blktrx))
#                            #trx_num: Number(key) + 1
#                            time: new Date(val.received_time*1000)
#                            amount: val.amount
#                            from: val.from_account
#                            to: val.to_account
#                            memo: val.memo_message
#                            id: val.trx_id.substring 0, 8
#                            fee: @utils.asset(val.fees, main_asset)
#                            vote: "N/A"
#                    @transactions[account_name_key]

    create: (wallet_name, spending_password) ->
        @rpc.request('wallet_create', [wallet_name, spending_password])

    get_balance: ->
        @rpc.request('wallet_get_balance').then (response) ->
            asset = response.result[0]
            {amount: asset[0], asset_type: asset[1]}

    get_wallet_name: ->
        @rpc.request('wallet_get_name').then (response) =>
          @wallet_name = response.result
    
    wallet_get_info: (error_handler = null) ->
        @rpc.request('wallet_get_info', [], error_handler).then (response) =>
            @info.transaction_fee = response.result.transaction_fee if response.result
            response.result

    wallet_add_contact_account: (name, address) ->
        @rpc.request('wallet_add_contact_account', [name, address]).then (response) =>
          response.result

    wallet_account_register: (account_name, pay_from_account, public_data, pay_rate, account_type) ->
        pay_rate = if pay_rate == undefined then 255 else pay_rate
        @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, pay_rate, account_type]).then (response) =>
          response.result

    wallet_rename_account: (current_name, new_name) ->
        @rpc.request('wallet_rename_account', [current_name, new_name]).then (response) =>
          @refresh_accounts().then =>
              @refresh_transactions()
          response.result

#    wallet_account_transaction_history: (account_name) ->
#        @wallet_api.account_transaction_history(account_name, "", 0, 0, -1)

    wallet_unlock: (password, error_handler)->
        @rpc.request('wallet_unlock', [@backendTimeout, password], error_handler).then (response) =>
          response.result

    check_if_locked: ->
        @rpc.request('wallet_get_info').then (response) =>
            if not response.result.unlocked
                @location.path("/unlockwallet")

    open: ->
        @rpc.request('wallet_open', ['default']).then (response) =>
          response.result
    
    get_block: (block_num)->
        @rpc.request('blockchain_get_block', [block_num]).then (response) ->
          response.result

    wallet_lock: ->
        @rpc.request('wallet_lock').then (response) ->
          response.result

    blockchain_list_accounts: (first_account_name, limit) ->
        limit = if limit then limit else 9999
        @rpc.request('blockchain_list_accounts', [first_account_name, limit]).then (response) ->
          reg = []
          angular.forEach response.result, (val, key) =>
            reg.push
              name: val.name
              owner_key: val.owner_key
          reg

    get_first_account: ->
        for k,v of @accounts
            if v.is_my_account
                return v
        return null

    get_current_or_first_account: ->
        deferred = @q.defer()
        if @current_account
            deferred.resolve(@current_account)
            return deferred.promise

        promise = @wallet_api.get_setting("current_account")
        promise.then (setting) =>
            if setting?.value
                @get_account(setting.value).then (account) ->
                    deferred.resolve(account)
            else
                if @accounts.length > 0
                    deferred.resolve(@get_first_account())
                else @refresh_accounts().then =>
                    deferred.resolve(@get_first_account())
        promise.catch (error) ->
            deferred.reject(error)

        return deferred.promise

    constructor: (@q, @log, @location, @translate, @growl, @rpc, @blockchain, @utils, @wallet_api, @blockchain_api, @interval, @idle) ->
        @wallet_name = ""
        @timeout = @idle._options().idleDuration

angular.module("app").service("Wallet", ["$q", "$log", "$location", "$translate", "Growl", "RpcService", "Blockchain", "Utils", "WalletAPI", "BlockchainAPI", "$interval", "$idle", Wallet])
