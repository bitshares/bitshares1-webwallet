class Wallet

    accounts: {}
    contacts: {}
    approvals: {}

    balances: {}
    bonuses: {}
    
    asset_balances : {}

    transactions: {"*": []}
    transactions_loading_promise: null
    check_vote_proportion_promise: null
    refresh_accounts_promise: null
    refresh_accounts_request: off
    transactions_last_block: 0
    transactions_all_by_id: {}
    transactions_last_time: 0
    transactions_counter: 0

    # set in constructor
    timeout: null

    default_vote: 'vote_all'

    pendingRegistrations: {}

    current_account: null
    
    #Long time
    backendTimeout: 999999

    info: {}

    main_asset: null

    interface_locale: null

    interface_theme = 'default'

    reset_gui_state:->
        # Information may show after locking the wallet then using the 
        # back button.  Additionally, clear memory.
        clear=(map)-> delete map[k] for k in Object.keys map
        clear @accounts
        clear @contacts
        clear @approvals
        clear @balances
        clear @bonuses
        clear @asset_balances
        clear @transactions
        @transactions["*"]=[]
        clear @transactions_all_by_id
        clear @pendingRegistrations
    
    observer_config:->
        name: "WalletEachBlockObserver"
        frequency: "each_block"
        update: (data, deferred) =>
            @refresh_accounts() if @refresh_accounts_request
            deferred.resolve(true)
        #notify: (data) ->

    set_current_account: (account) ->
        @current_account = account
        @set_setting("current_account", account.name)
    
    check_wallet_status: ->
        deferred = @q.defer()
        @open().then =>
            @wallet_get_info().then (result) =>
                navigate_to('unlockwallet') unless result.unlocked
                deferred.resolve()
                @get_setting('timeout').then (result) =>
                    if result && result.value
                        @timeout = result.value
                        @idle._options().idleDuration = @timeout
                        @idle.watch()
                @get_setting('default_vote').then (result) =>
                    @default_vote = result.value if result?.value
                @get_setting('interface_locale').then (result) =>
                    if result and result.value
                        @interface_locale = result.value
                        moment.locale(result.value)
                        @translate.use(result.value)
                @get_setting('interface_theme').then (result) =>
                    if result and result.value
                        @interface_theme = result.value
            , (error) ->
                deferred.reject(error)
        , (error) ->
                deferred.reject(error)

        return deferred.promise

    refresh_balances_promise: null

    refresh_balances: ->
        return @refresh_balances_promise if @refresh_balances_promise
        deffered = @q.defer()
        @refresh_balances_promise = deffered.promise

        @blockchain.refresh_asset_records().then =>
            @main_asset = @blockchain.asset_records[0]
            requests =
                refresh_bonuses: @refresh_bonuses()
                account_balances : @wallet_api.account_balance("")
            @q.all(requests).then (results) =>
                for name_bal_pair in results.account_balances
                    name = name_bal_pair[0]
                    balances = name_bal_pair[1]
                    for asset_id_amt_pair in balances
                        asset_id = asset_id_amt_pair[0]
                        asset_record = @blockchain.asset_records[asset_id]
                        if asset_record
                            symbol = asset_record.symbol
                            amount = asset_id_amt_pair[1]
                            @balances[name] = @balances[name] || {}
                            @balances[name][symbol] = @utils.newAsset(amount, symbol, asset_record.precision)
                            @asset_balances[asset_id] = @asset_balances[asset_id] || 0
                            @asset_balances[asset_id] = @asset_balances[asset_id] + amount
                for acct in @accounts
                    if !@balances[acct.name]
                        @balances[acct.name] = {}
                        @balances[acct.name][@main_asset.symbol] = @utils.asset(0, @main_asset)
                deffered.resolve(@balances)
                @refresh_balances_promise = null
            , (error) ->
                deffered.reject(error)
                @refresh_balances_promise = null

        return @refresh_balances_promise

    refresh_bonuses_promise: null
    
    refresh_bonuses: ->
        if @utils.too_soon("refresh_bonuses", 10 * 1000)
            return @refresh_bonuses_promise.then (response) =>
                #console.log "wallet_account_yield(): too soon #{response}"
                return response
    
        @refresh_bonuses_promise = @wallet_api.account_yield("").then (response) =>
            for name_balances_pair in response
                name = name_balances_pair[0]
                for asset_id_amt_pair in name_balances_pair[1]
                    asset_id = asset_id_amt_pair[0]
                    symbol = @blockchain.asset_records[asset_id].symbol
                    amount = asset_id_amt_pair[1]
                    @bonuses[name] = @bonuses[name] || {}
                    @bonuses[name][symbol] = @utils.newAsset(amount, symbol, @blockchain.symbol2records[symbol].precision)


    # turn raw rpc return value into nice object
    populate_account: (val) ->
        acct = val
        acct.active_key = val.active_key_history[val.active_key_history.length - 1][1]
        acct.registered = val.registration_date and val.registration_date != "1970-01-01T00:00:00"
        acct.is_my_account = true
        acct.is_address_book_contact = true
        @accounts[acct.name] = acct
        @contacts[acct.name] = acct
        return acct

    populate_approvals: (val) ->
        @approvals[val.name] = val
        return true

    refresh_account: (name) ->
        deferred = @q.defer()
        @wallet_api.get_account(name).then (result) => # TODO no such acct?
            @populate_account(result)
            @refresh_balances().then =>
                deferred.resolve(@accounts[name])
            , (error) ->
                deferred.reject(error)
        , (error) ->
                deferred.reject(error)
        return deferred.promise

    refresh_accounts: () ->
        @refresh_accounts_request = on
        if @refresh_accounts_promise
            return @refresh_accounts_promise 

        deferred = @q.defer()
        @refresh_accounts_promise = deferred.promise

        first_account = null
        @q.all([
            @wallet_api.list_accounts()
            @wallet_api.list_approvals()
            ])
        .then (results) =>
            for appr in results[1]
                @populate_approvals appr
            for val in results[0]
                account = @populate_account(val)
                first_account = account unless first_account
            if first_account and !@current_account
                @wallet_api.get_setting("current_account").then (setting) =>
                    if setting?.value
                        @current_account = @accounts[setting.value]
                        @current_account = first_account unless @current_account
                    else
                        @current_account = first_account
            @refresh_balances()
            deferred.resolve()
            @refresh_accounts_promise = null
            @refresh_accounts_request = off
        @refresh_accounts_promise

    check_vote_proportion: (account_names) ->
        return @check_vote_proportion_promise if @check_vote_proportion_promise
        deferred = @q.defer()
        @check_vote_proportion_promise = deferred.promise
        @RpcService.request("batch", ["wallet_check_vote_proportion", account_names]).then (response) ->
            deferred.resolve(response)
        @check_vote_proportion_promise
        
    get_setting: (name) ->
        @wallet_api.get_setting(name)

    set_setting: (name, value) ->
        @wallet_api.set_setting(name, value).then (result) =>
            result

    create_account: (name, error_handler) ->
        @wallet_api.account_create(name, error_handler).then (result) =>
            @refresh_accounts()
            result

    account_update_private_data: (name, privateData) ->
        @wallet_api.set_custom_data("account_record_type", name, privateData).then (result) =>
            @refresh_accounts()

    refresh_contact_data: (contact_name_or_address) ->
        promise = @blockchain_api.get_account(contact_name_or_address)
        promise.then (val) =>
            if val
                account = val
                account.active_key = val.active_key_history[val.active_key_history.length - 1][1]
                account.registered = val.registration_date and val.registration_date != "1970-01-01T00:00:00"
                account.is_my_account = false
                account.is_address_book_contact = true
                @contacts[account.name] = account
        return promise

    refresh_contacts: ->
        #delete @contacts[k] for k, v of @contacts when not v.is_my_account
        if Object.keys(@contacts).length > 0
            deferred = @q.defer()
            deferred.resolve(true)
            return deferred.promise
        else
            @wallet_api.list_contacts().then (result) =>
                for acct in result
                    @refresh_contact_data(acct.data)

    get_accounts: () ->
        if Object.keys(@accounts).length > 0
            deferred = @q.defer()
            deferred.resolve(@accounts)
            return deferred.promise
        else
            @refresh_accounts().then =>
                return @accounts

    get_account: (name, error_handler) ->
        @refresh_balances()
        deferred = @q.defer()
        if @accounts[name]
            #console.log "wallet_get_account found",name
            deferred.resolve(@accounts[name])
        else
            @wallet_api.get_account(name, error_handler).then (result) =>
                if result
                    acct = @populate_account(result)
                    deferred.resolve(acct)
                else
                    deferred.reject("not found")
            ,
            (error) =>
#                @blockchain_api.get_account(name, error_handler).then (result) =>
#                    acct = if result then @populate_account(result) else null
#                    deferred.resolve(acct)
                deferred.reject(error)
        return deferred.promise

    approve_account: (name, approve) ->
        @wallet_api.approve(name, approve)

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
        t.expiration_pretty_time = @utils.toDate(val.expiration_timestamp).toLocaleString()
        t.pretty_time = time.toLocaleString()
        t.fee = @utils.asset(val.fee.amount, @blockchain.asset_records[val.fee.asset_id])
        t.vote = "N/A"
        if t.status != "rebroadcasted"
            t.status = if not val.is_confirmed and not val.is_virtual then "pending" else "-"

    update_ledger_entries: (t, val) ->
        if t.ledger_entries then t.ledger_entries.splice(0, t.ledger_entries.length) else t.ledger_entries = []
        involved_accounts = {}
        used_balance_symbols = {}
        for entry in val.ledger_entries
            involved_accounts[entry.from_account] = true
            involved_accounts[entry.to_account] = true
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
            t.ledger_entries.push
                from: entry.from_account
                to: entry.to_account
                amount: entry.amount.amount
                amount_asset : @utils.asset(entry.amount.amount, @blockchain.asset_records[entry.amount.asset_id])
                memo: entry.memo
                running_balances: running_balances
        return involved_accounts

    process_transaction: (val) ->
        #console.log "------ process_transaction ------>", val
        existing_transaction = @transactions_all_by_id[val.trx_id]
        if existing_transaction and existing_transaction.id
            @update_transaction(existing_transaction, val)
            @update_ledger_entries(existing_transaction, val)
            existing_transaction.time.setMilliseconds(existing_transaction.num)
            return

        transaction = { id: val.trx_id }
        @update_transaction(transaction, val)
        involved_accounts = @update_ledger_entries(transaction, val)
        if val.timestamp == @transactions_last_time
            @transactions_counter += 1
        else
            @transactions_counter = 0
        @transactions_last_time = val.timestamp
        transaction.time.setMilliseconds(@transactions_counter)
        transaction.num = @transactions_counter

        @transactions_all_by_id[val.trx_id] = transaction

        @transactions["*"].unshift transaction
        for account, val  of involved_accounts
            @transactions[account] ||= []
            @transactions[account].unshift transaction

    refresh_transactions: () ->
        return @transactions_loading_promise if @transactions_loading_promise
        #console.log "------ refresh_transactions ------>"
        deffered = @q.defer()

        @transactions_loading_promise = deffered.promise

        refresh_asset_records_promise = @blockchain.refresh_asset_records()
        refresh_asset_records_promise.catch (error) =>
            @transactions_loading_promise = null
            deffered.reject(error)

        refresh_asset_records_promise.then =>
            go_back_to_block = if @transactions_last_block > 20 then @transactions_last_block else 0
            #console.log "------ wallet_account_transaction_history '' '' 0 #{go_back_to_block} -1"
            @wallet_api.account_transaction_history("", "", 0, go_back_to_block, -1).then (result) =>
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
                    # each_block observer will reset transactions_loading_promise
                    @transactions_loading_promise = null
                    deffered.resolve(@transactions)
            , (error) =>
                @transactions_loading_promise = null
                deffered.reject(error)


        @transactions_loading_promise

    create: (wallet_name, new_passphrase, brain_key) ->
        @rpc.request('wallet_create', [wallet_name, new_passphrase, brain_key, new_passphrase])

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

    wallet_account_register: (account_name, pay_from_account, public_data, pay_rate, account_type) ->
        pay_rate = if pay_rate == undefined then 255 else pay_rate
        @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, pay_rate, account_type]).then (response) =>
          response.result

    wallet_rename_account: (current_name, new_name) ->
        @rpc.request('wallet_rename_account', [current_name, new_name]).then (response) =>
          @refresh_accounts().then =>
              @refresh_transactions()
          response.result

    wallet_unlock: (password, error_handler)->
        @rpc.request('wallet_unlock', [@backendTimeout, password], error_handler).then (response) =>
          response.result

    check_if_locked: ->
        @rpc.request('wallet_get_info').then (response) =>
            if not response.result.unlocked
                @location.path("/unlockwallet")

    open:(name = "default") ->
        @rpc.request('wallet_open', [name]).then (response) =>
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
          for key, val of response.result
            reg.push
              name: val.name
              owner_key: val.owner_key
          reg

    get_first_account: ->
        for k,v of @accounts
            #if v.is_my_account
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

    constructor: (@q, @log, @location, @translate, @growl, @rpc, @blockchain, @utils, @wallet_api, @blockchain_api, @RpcService, @interval, @idle) ->
        @wallet_name = ""
        @timeout = @idle._options().idleDuration

angular.module("app").service("Wallet", ["$q", "$log", "$location", "$translate", "Growl", "RpcService", "Blockchain", "Utils", "WalletAPI", "BlockchainAPI", "RpcService", "$interval", "$idle", Wallet])
