class Wallet

  constructor: (@q, @log, @rpc, @error_service, @interval) ->
    @log.info "---- Wallet Constructor ----"
    @wallet_name = ""
    @info =
      network_connections: 0
      balance: 0
      wallet_open: false
      last_block_num: 0
      last_block_time: null
    @watch_for_updates()

  convertDate = (t) ->
    dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
    match = t.match(dateRE)
    return 0 unless match
    nums = []
    i = 1
    while i < match.length
      nums.push parseInt(match[i], 10)
      i++
    new Date(Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5]))

  create: (wallet_password, spending_password) ->
    @rpc.request('wallet_create', ['default', wallet_password]).then (response) =>
      if response.result == true
        return true
      else
        error = "Cannot create wallet, the wallet may already exist"
        @error_service.set error
        @q.reject(error)

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

  get_block: (block_num)->
    @rpc.request('blockchain_get_block_by_number', [block_num]).then (response) ->
      response.result

  watch_for_updates: =>
    @interval (=>
      @get_info().then (data) =>
        #console.log "watch_for_updates get_info:>", data
        @get_block(data.blockchain_block_num).then (block) =>
          @info.network_connections = data.network_num_connections
          @info.balance = data.wallet_balance
          @info.wallet_open = data.wallet_open
          @info.wallet_unlocked = !!data.wallet_unlocked_until
          @info.last_block_time = convertDate(block.timestamp)
          @info.last_block_num = data.blockchain_block_num
      , =>
        @info.network_connections = 0
        @info.balance = 0
        @info.wallet_open = false
        @info.wallet_unlocked = false
        @info.last_block_time = null
        @info.last_block_num = 0
    ), 2500


angular.module("app").service("Wallet", ["$q", "$log", "RpcService", "ErrorService", "$interval", Wallet])
