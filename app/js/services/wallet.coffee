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

    # set in constructor
    timeout: null

    autocomplete: true

    pendingRegistrations: {}

    current_account: null
    
    #Long time
    backendTimeout: 999999

    info: {}

    set_current_account: (account) ->
        @current_account = account
        @set_setting("current_account", account.name)
    
    check_wallet_status: ->
      @wallet_get_info().then (result) =>
        if result.open
            if not result.unlocked
                @location.path("/unlockwallet")
            else
                @get_setting('timeout').then (result) =>
                    if result && result.value
                        @timeout=result.value
                        @idle._options().idleDuration=@timeout
                        @idle.watch()
                @get_setting('autocomplete').then (result) =>
                    @autocomplete=result.value if result
        else
            @open().then =>
                #redirection
                @check_if_locked()

    refresh_balances: ->
        requests =
            account_balances : @wallet_api.account_balance("")
            refresh_assets: @blockchain.refresh_asset_records()
            main_asset: @blockchain.get_asset(0)
        @q.all(requests).then (results) =>
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
                if acct.is_my_account
                    #@refresh_open_order_balances(acct.name)
                    @refresh_bonuses(acct.name)
                if acct.is_my_account and !@balances[acct.name]
                    @balances[acct.name] = {}
                    @balances[acct.name][results.main_asset.symbol] = @utils.asset(0, results.main_asset)

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

    refresh_bonuses: (name) ->
        @rpc.request('wallet_account_yield', []).then (response) =>
            angular.forEach response.result, (name_balances_pair) =>
                name = name_balances_pair[0]
                angular.forEach name_balances_pair[1], (asset_id_amt_pair) =>
                    asset_id = asset_id_amt_pair[0]
                    symbol = @blockchain.asset_records[asset_id].symbol
                    amount = asset_id_amt_pair[1]
                    @bonuses[name] = @bonuses[name] || {}
                    @bonuses[name][symbol] = @utils.newAsset(amount, symbol, @blockchain.symbol2records[symbol].precision)


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
        @accounts[acct.name] = acct
        return acct

    refresh_account: (name) ->
        @wallet_api.get_account(name).then (result) => # TODO no such acct?
            @populate_account(result)
            @refresh_balances()

    refresh_accounts: ->
        @accounts = {}
        @wallet_api.list_accounts().then (result) =>
            angular.forEach result, (val) =>
                @populate_account(val)
            @refresh_balances()

    get_setting: (name) ->
        @wallet_api.get_setting(name).then (result) =>
            result

    set_setting: (name, value) ->
        @wallet_api.set_setting(name, value).then (result) =>
            result

    create_account: (name, privateData) ->
        @wallet_api.account_create(name, privateData).then (result) =>
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
        if @accounts[name]
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
                    acct = @populate_account(result)
                    return acct

    approve_account: (name, approve) ->
        @wallet_api.account_set_approval(name, approve)
    
    refresh_transactions_on_update: () ->
        #@refresh_transactions()
#        .then ->
#            promises = []
#            angular.forEach @accounts, (account, name) =>
#                if account.is_my_account
#                    promises.push @refresh_transactions(name)

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
                    @transactions_last_block = val.block_num
                    continue if @transactions_all_by_id[val.trx_id]

                    #console.log "------ refresh_transactions ------>", val.block_num, val

                    involved_accounts = {}
                    ledger_entries = []
                    angular.forEach val.ledger_entries, (entry) =>
                        involved_accounts[entry.from_account] = true if @accounts[entry.from_account]
                        involved_accounts[entry.to_account] = true if @accounts[entry.to_account]
                        running_balances = {}
                        for acct in entry.running_balances
                            account_name = acct[0]
                            balances = acct[1]
                            continue unless involved_accounts[account_name]
                            #console.log "------ running_balances item ------>",account_name, balances
                            for item in balances
                                asset = @utils.asset(item[1].amount, @blockchain.asset_records[item[1].asset_id])
                                running_balances[account_name] ||= []
                                running_balances[account_name].push asset

                        ledger_entries.push
                            from: entry.from_account
                            to: entry.to_account
                            amount: entry.amount.amount
                            amount_asset : @utils.asset(entry.amount.amount, @blockchain.asset_records[entry.amount.asset_id])
                            memo: entry.memo
                            running_balances: running_balances

                    time = @utils.toDate(val.timestamp)
                    transaction =
                        is_virtual: val.is_virtual
                        is_confirmed: val.is_confirmed
                        is_market: val.is_market
                        is_market_cancel: val.is_market_cancel
                        block_num: val.block_num
                        error: val.error
                        trx_num: val.trx_num
                        time: time
                        pretty_time: time.toLocaleString "en-us"
                        ledger_entries: ledger_entries
                        id: val.trx_id
                        fee: @utils.asset(val.fee.amount, @blockchain.asset_records[val.fee.asset_id])
                        vote: "N/A"

                    @transactions_all_by_id[val.trx_id] = transaction

                    @transactions["*"].unshift transaction
                    angular.forEach involved_accounts, (val, account) =>
                        @transactions[account] ||= []
                        @transactions[account].unshift transaction

                @transactions_loading_promise = null
                deffered.resolve(@transactions)

                #console.log "------ account_transactions finished ------>"

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
    
    wallet_get_info: ->
        @rpc.request('wallet_get_info').then (response) =>
            @info.transaction_fee = response.result.transaction_fee
            response.result

    wallet_add_contact_account: (name, address) ->
        @rpc.request('wallet_add_contact_account', [name, address]).then (response) =>
          response.result

    wallet_account_register: (account_name, pay_from_account, public_data, pay_rate) ->
        pay_rate = if pay_rate == undefined then 255 else pay_rate
        @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, pay_rate]).then (response) =>
          response.result

    wallet_rename_account: (current_name, new_name) ->
        @rpc.request('wallet_rename_account', [current_name, new_name]).then (response) =>
          @refresh_accounts().then =>
              @refresh_transactions()
          response.result

#    wallet_account_transaction_history: (account_name) ->
#        @wallet_api.account_transaction_history(account_name, "", 0, 0, -1)

    wallet_unlock: (password)->
        @rpc.request('wallet_unlock', [@backendTimeout, password]).then (response) =>
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

    get_current_or_first_account: ->
        get_first_account = =>
            for k,v of @accounts
                if v.is_my_account
                    return v
            return null

        deferred = @q.defer()
        if @current_account
            deferred.resolve(@current_account)
            return deferred.promise

        @get_setting("current_account").then (setting) =>
            if setting?.value
                @get_account(setting.value).then (account) ->
                    deferred.resolve(account)
            else
                if @accounts.length > 0
                    deferred.resolve(get_first_account())
                else @refresh_accounts().then =>
                    deferred.resolve(get_first_account())
        return deferred.promise

    constructor: (@q, @log, @location, @growl, @rpc, @blockchain, @utils, @wallet_api, @blockchain_api, @interval, @idle) ->
        @wallet_name = ""
        @timeout = @idle._options().idleDuration

angular.module("app").service("Wallet", ["$q", "$log", "$location", "Growl", "RpcService", "Blockchain", "Utils", "WalletAPI", "BlockchainAPI", "$interval", "$idle", Wallet])
