class TradeData
    constructor: ->
        @timestamp = null
        @quantity = null
        @price = null
        @cost = 0.0
        @cancelable = false
        @id = null

class MarketService

    TradeData: TradeData

    market:
        name: ''
        quantity_symbol: ''
        quantity_asset: null
        base_symbol: ''
        base_asset: null
        url: ''

    asks: []
    bids: []
    shorts: []
    trades: []

    id_sequence: 0

    constructor: (@q, @interval, @wallet, @blockchain) ->
        #console.log "MarketService constructor: ", @

    init: (market_name) ->
        market = @market
        market.name = market_name
        market_symbols = market.name.split('/')
        market.quantity_symbol = market_symbols[0]
        market.base_symbol = market_symbols[1]
        market.url = "#{market.quantity_symbol}:#{market.base_symbol}"
        @blockchain.refresh_asset_records().then =>
            @q.all([@blockchain.get_asset(market.quantity_symbol), @blockchain.get_asset(market.base_symbol)]).then (results) ->
                market.quantity_asset = results[0]
                market.base_asset = results[1]
            #console.log "---- market: ", market

    remove_array_element_by_id = (array, id) ->
        for index, value of array
            if value.id == id
                array.splice(index, 1)
                break

    add_bid: (bid) ->
        @id_sequence += 1
        bid.id = @id_sequence
        bid.cancelable = true
        @bids.push bid

    cancel_bid: (id) ->
        remove_array_element_by_id(@bids,id)

    add_ask: (ask) ->
        @id_sequence += 1
        ask.id = @id_sequence
        ask.cancelable = true
        @asks.push ask

    cancel_ask: (id) ->
        remove_array_element_by_id(@asks,id)

    pull_data: ->
        #console.log "--- pull_data ---"
        if @asks.length > 0
            e = @asks.pop()
            e.timestamp = new Date()
            @trades.push e
        if @bids.length > 0
            e = @bids.pop()
            e.timestamp = new Date()
            @trades.push e

    watch_for_updates: =>
        @interval (=>
            if !@is_refreshing
                @pull_data()
        ), 4000


angular.module("app").service("MarketService", ["$q", "$interval", "Wallet", "Blockchain",  MarketService])
