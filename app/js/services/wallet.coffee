class Wallet

  constructor: (@q, @log, @rpc, @interval) ->
    @log.info "---- Wallet Constructor ----"
    @wallet_name = ""
    @info =
      network_connections: 0
      balance: 0
      wallet_open: false
      last_block_num: 0
      last_block_time: null
    @watch_for_updates()

  toDate: (t) ->
    dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
    match = t.match(dateRE)
    return 0 unless match
    nums = []
    i = 1
    while i < match.length
      nums.push parseInt(match[i], 10)
      i++
    new Date(Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5]))

  create: (wallet_name, spending_password) ->
    @rpc.request('wallet_create', [wallet_name, spending_password]).then (response) =>
      #success()

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
  
  open: ->
    @rpc.request('wallet_open', ['default']).then (response) ->
      response.result

  get_block: (block_num)->
    @rpc.request('blockchain_get_block_by_number', [block_num]).then (response) ->
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
          @get_block(data.blockchain_head_block_num).then (block) =>
            @info.network_connections = data.network_num_connections
            @info.balance = data.wallet_balance[0][0]
            @info.wallet_open = data.wallet_open
            @info.wallet_unlocked = !!data.wallet_unlocked_until
            @info.last_block_time = @toDate(block.timestamp)
            @info.last_block_num = data.blockchain_head_block_num
      , =>
        @info.network_connections = 0
        @info.balance = 0
        @info.wallet_open = false
        @info.wallet_unlocked = false
        @info.last_block_time = null
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


angular.module("app").service("Wallet", ["$q", "$log", "RpcService", "$interval", Wallet])
