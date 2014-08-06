class TradeData
    constructor: ->
        @timestamp = null
        @quantity = null
        @price = null
        @cost = 0.0
        @cancelable = false
        @id = null

class Market
    constructor: ->
        @name = ''
        @quantity_symbol = ''
        @quantity_asset = null
        @base_symbol = ''
        @base_asset = null
        @inverted = false
        @url = ''
        @inverted_url = ''
        @bid_depth = 0.0
        @ask_depth = 0.0
        @avg_price_24h = 0.0

    get_inverted_clone: ->
        m = new Market()
        m.name = "#{@base_symbol}/#{@quantity_symbol}"
        m.quantity_symbol = @base_symbol
        m.quantity_asset = @base_asset
        m.base_symbol = @quantity_symbol
        m.base_asset = @quantity_asset
        m.inverted = null
        m.url = @inverted_url
        m.inverted_url = @url
        m.bid_depth = @bid_depth
        m.ask_depth = @ask_depth
        m.avg_price_24h = @avg_price_24h
        return m

class MarketHelper

    remove_array_element_by_id: (array, id) ->
        for index, value of array
            if value.id == id
                array.splice(index, 1)
                break

    read_market_data: (market, data) ->
        market.bid_depth = data.bid_depth
        market.ask_depth = data.ask_depth
        market.avg_price_24h = data.avg_price_24h

class MarketService

    TradeData: TradeData

    helper: new MarketHelper()

    market: new Market()

    asks: []
    bids: []
    shorts: []
    trades: []

    id_sequence: 0
    is_refreshing: false

    constructor: (@q, @interval, @wallet, @blockchain, @blockchain_api) ->
        #console.log "MarketService constructor: ", @

    init: (market_name) ->
        market = @market
        market.name = market_name
        market_symbols = market.name.split('/')
        market.quantity_symbol = market_symbols[0]
        market.base_symbol = market_symbols[1]
        market.url = "#{market.quantity_symbol}-#{market.base_symbol}"
        market.inverted_url = "#{market.base_symbol}-#{market.quantity_symbol}"
        @blockchain.refresh_asset_records().then =>
            @q.all([@blockchain.get_asset(market.quantity_symbol), @blockchain.get_asset(market.base_symbol)]).then (results) ->
                market.quantity_asset = results[0]
                market.base_asset = results[1]
            #console.log "---- market: ", market
            @blockchain_api.market_status(market.quantity_symbol, market.base_symbol).then (result) =>
                market.inverted = false
                @helper.read_market_data(market, result)
                console.log "market_status--->", result
            , =>
                @blockchain_api.market_status(market.base_symbol, market.quantity_symbol).then (result) =>
                    market.inverted = true
                    @helper.read_market_data(market, result)
                    console.log "market_status reverse --->", result

    add_bid: (bid, cancelable) ->
        @id_sequence += 1
        bid.id = @id_sequence
        bid.cancelable = cancelable
        @bids.push bid

    cancel_bid: (id) ->
        helper.remove_array_element_by_id(@bids,id)

    add_ask: (ask, cancelable) ->
        @id_sequence += 1
        ask.id = @id_sequence
        ask.cancelable = cancelable
        @asks.push ask

    add_order: (order, type, qa, ba, flip) ->
        td = new TradeData()
        td.quantity = order.state.balance / ba.precision
        td.price = order.market_index.order_price.ratio * (ba.precision / qa.precision)
        td.cost = td.quantity * td.price
        if flip
            @add_ask(td, false)
        else
            @add_bid(td, false)

    cancel_ask: (id) ->
        helper.remove_array_element_by_id(@asks,id)

    pull_data: ->
        return if @is_refreshing
        @is_refreshing = true
        #console.log "market: ", @market
        #console.log "inverted: ", @market.get_inverted_clone()
        @asks.splice(0, @asks.length)
        @bids.splice(0, @bids.length)

        market = if @market.inverted then @market.get_inverted_clone() else @market
        console.log "--- pull_data --- market: #{market.name}, inverted: #{@market.inverted}", market
        bids_call = if @market.inverted
            @blockchain_api.market_list_bids(market.base_symbol, market.quantity_symbol, 10)
        else
            @blockchain_api.market_list_asks(market.quantity_symbol, market.base_symbol, 10)

        promise = bids_call.then (results) =>
            for r in results
                console.log "---- r: ", r
                @add_order(r, 'ask', market.quantity_asset, market.base_asset, @market.inverted)

#                td.
#                o = {}
#                o.quantity = {}
#                o.quantity.amount = order.state.balance
#                o.quantity.precision = base_asset.precision
#                o.price = {}
#                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
#                o.price.precision = quote_asset.precision
#                o.cost = {}
#                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
#                o.cost.precision = quote_asset.precision
#                orders.push o
            #$scope.sell_orders = orders
        promise.finally => @is_refreshing = false

    watch_for_updates: =>
        @pull_data()
#        @interval (=>
#            @pull_data() if !@is_refreshing
#        ), 5000


angular.module("app").service("MarketService", ["$q", "$interval", "Wallet", "Blockchain",  "BlockchainAPI",  MarketService])
