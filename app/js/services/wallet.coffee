class Wallet

  constructor: (@q, @log, @rpc, @error_service, @interval) ->
    @log.info "---- Wallet Constructor ----"
    @wallet_name = ""
    @info =
      network_connections: 0
      balance: 0
      wallet_open: false
    @watch_for_updates()

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
      @wallet_name = response.result
      console.log "---- current wallet name: ", response.result

  get_info: ->
    @rpc.request('get_info').then (response) ->
      response.result

  watch_for_updates: =>
    @interval (=>
      @get_info().then (info) =>
        #console.log "watch_for_updates get_info:>", info
        @info.network_connections = info.network_num_connections
        @info.balance = info.wallet_balance
        @info.wallet_open = info.wallet_open
        @log.info "+++ intervalFunction", @info
    ), 5000


angular.module("app").service("Wallet", ["$q", "$log", "RpcService", "ErrorService", "$interval", Wallet])
