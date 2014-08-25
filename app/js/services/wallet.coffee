class Wallet

    accounts: {}

    balances: {}

    asset_balances : {}

    transactions: { ":all:by:id:" : {}, ":last:block:": 0 }

    # set in constructor
    timeout: null

    pendingRegistrations: {}

    current_account: null
    
    #Long time
    backendTimeout: 999999

    info: {}
    
    check_wallet_status : ()->
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
                balances = name_bal_pair[1][0]
                angular.forEach balances, (symbol_amt_pair) =>
                    symbol = symbol_amt_pair[0]
                    amount = symbol_amt_pair[1]
                    @balances[name] = @balances[name] || {}
                    @balances[name][symbol] = @utils.newAsset(amount, symbol, @blockchain.symbol2records[symbol].precision)
                    asset_id = @blockchain.symbol2records[symbol].id
                    @asset_balances[asset_id] = @asset_balances[asset_id] || 0
                    @asset_balances[asset_id] = @asset_balances[asset_id] + amount
            angular.forEach @accounts, (acct) =>
                if acct.is_my_account and !@balances[acct.name]
                    @balances[acct.name] = {}
                    @balances[acct.name][results.main_asset.symbol] = @utils.asset(0, results.main_asset)

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
        @refresh_transactions()
        angular.forEach @accounts, (account, name) =>
            if account.is_my_account
                @refresh_transactions(name)

    refresh_transactions: (account_name) ->
        account_name_key = account_name || "*"
        all_by_id = @transactions[":all:by:id:"]
        last_block = @transactions[":last:block:"]
        @transactions[account_name_key] = [] unless account_name_key in @transactions
        account_transactions = @transactions[account_name_key]
        @blockchain.refresh_asset_records().then () =>
            @wallet_account_transaction_history(account_name, "", 0, last_block, -1).then (result) =>
                #console.log "------ refresh_transactions ------>", account_name, result

                angular.forEach result, (val, key) =>

                    @transactions[":last:block:"] = val.block_num
                    if val.trx_id in all_by_id
                        transaction = all_by_id[val.trx_id]
                    else
                        ledger_entries = []
                        angular.forEach val.ledger_entries, (entry) =>
                            running_balances = []
                            angular.forEach entry.running_balances, (item) =>
                                asset = @utils.asset(item[1].amount, @blockchain.asset_records[item[1].asset_id])
                                running_balances.push asset
                            ledger_entries.push
                                from: entry.from_account
                                to: entry.to_account
                                amount: entry.amount.amount
                                amount_asset : @utils.asset(entry.amount.amount, @blockchain.asset_records[entry.amount.asset_id])
                                memo: entry.memo
                                running_balances: running_balances

                        time = @utils.toDate(val.received_time)
                        transaction =
                            is_virtual: val.is_virtual
                            is_confirmed: val.is_confirmed
                            block_num: val.block_num
                            error: val.error
                            trx_num: val.trx_num
                            time: time
                            pretty_time: time.toLocaleString "en-us"
                            ledger_entries: ledger_entries
                            id: val.trx_id
                            fee: @utils.asset(val.fee.amount, @blockchain.asset_records[val.fee.asset_id])
                            vote: "N/A"
                            accounts: {account_name_key: true}
                        all_by_id[val.trx_id] = transaction

                    unless account_name_key in transaction.accounts
                            transaction.accounts[account_name_key] = true
                            account_transactions.unshift transaction

                #console.log "------ account_transactions ------>", account_transactions

        return account_transactions


    refresh_transactions_on_new_block: () ->
        @refresh_transactions()
#        @refresh_transactions().then =>
#            if @transactions["*"].length > 0
#                #@growl.notice "", "You just received a new transaction!"
#                angular.forEach @accounts, (account, name) =>
#                    if account.is_my_account
#                        @refresh_transactions(name)

    # TODO: search for all deposit_op_type with asset_id 0 and sum them to get amount
    # TODO: sort transactions, show the most recent ones on top
    get_transactions: (account_name) ->
        account_name_key = account_name || "*"
        if @transactions[account_name_key]
            deferred = @q.defer()
            deferred.resolve(@transactions[account_name_key])
            return deferred.promise
        else
            @blockchain.get_asset(0).then (main_asset) ->
                @wallet_account_transaction_history(account_name).then (result) =>
                    @transactions[account_name_key] = []
                    angular.forEach result, (val, key) =>
                        blktrx=val.block_num + "." + val.trx_num
                        @transactions[account_name_key].push
                            block_num: ((if (blktrx is "0.0") then "Pending" else blktrx))
                            #trx_num: Number(key) + 1
                            time: new Date(val.received_time*1000)
                            amount: val.amount
                            from: val.from_account
                            to: val.to_account
                            memo: val.memo_message
                            id: val.trx_id.substring 0, 8
                            fee: @utils.asset(val.fees, main_asset)
                            vote: "N/A"
                    @transactions[account_name_key]

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

    wallet_account_transaction_history: (account_name) ->
        @wallet_api.account_transaction_history(account_name, "", 0, 0, -1)

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
        else if @accounts.length > 0
            deferred.resolve(get_first_account())
        else @refresh_accounts().then =>
            deferred.resolve(get_first_account())
        return deferred.promise

    constructor: (@q, @log, @location, @growl, @rpc, @blockchain, @utils, @wallet_api, @blockchain_api, @interval, @idle) ->
        @wallet_name = ""
        @timeout = @idle._options().idleDuration

angular.module("app").service("Wallet", ["$q", "$log", "$location", "Growl", "RpcService", "Blockchain", "Utils", "WalletAPI", "BlockchainAPI", "$interval", "$idle", Wallet])
