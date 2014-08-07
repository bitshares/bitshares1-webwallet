class TradeData
    constructor: ->
        @type = null
        @id = null
        @timestamp = null
        @quantity = null
        @price = null
        @cost = 0.0
        @status = null # possible values: canceled, unconfirmed, confirmed, placed
    invert: ->
        td = new TradeData()
        td.type = @type
        td.id = @id
        td.status = @status
        td.timestamp = @timestamp
        td.quantity = @cost
        td.cost = @quantity
        #td.price = if @price and @price > 0.0 then 1.0 / @price else 0.0
        td.price = @price
        return td

class Market
    constructor: ->
        @name = ''
        @quantity_symbol = ''
        @quantity_asset = null
        @base_symbol = ''
        @base_asset = null
        @inverted = true
        @url = ''
        @inverted_url = ''
        @price_symbol = ''
        @bid_depth = 0.0
        @ask_depth = 0.0
        @avg_price_24h = 0.0
    invert: ->
        m = new Market()
        m.name = "#{@base_symbol}:#{@quantity_symbol}"
        m.quantity_symbol = @base_symbol
        m.quantity_asset = @base_asset
        m.base_symbol = @quantity_symbol
        m.base_asset = @quantity_asset
        m.inverted = null
        m.url = @inverted_url
        m.inverted_url = @url
        m.price_symbol = "#{@quantity_symbol}/#{@base_symbol}"
        m.bid_depth = @bid_depth
        m.ask_depth = @ask_depth
        m.avg_price_24h = @avg_price_24h
        return m

class MarketHelper

    get_array_element_by_id: (array, id) ->
        for index, value of array
            return value if value.id == id
        return null

    remove_array_element_by_id: (array, id) ->
        for index, value of array
            if value.id == id
                array.splice(index, 1)
                break

    read_market_data: (market, data) ->
        market.bid_depth = data.bid_depth
        market.ask_depth = data.ask_depth
        market.avg_price_24h = data.avg_price_24h

    order_to_trade_data: (order, qa, ba, inverted) ->
        td = new TradeData()
        td.type = if inverted then @invert_order_type(order.type) else order_type
        td.id = order.market_index.owner
        td.quantity = order.state.balance / ba.precision
        price = order.market_index.order_price.ratio * (ba.precision / qa.precision)
        td.price = if inverted then price else 1.0 / price
        td.cost = td.quantity * td.price
        return td

    trade_history_to_order: (t, assets) ->
        ba = assets[t.ask_price.base_asset_id]
        qa = assets[t.ask_price.quote_asset_id]
        o = {type: t.bid_type}
        o.price = t.ask_price.ratio * (ba.precision / qa.precision)
        o.paid = t.ask_paid.amount / ba.precision
        o.received = t.ask_received.amount / qa.precision
        return o

    list_to_hash: (list) ->
        hash = {}
        for i, v of list
            v.index = i
            hash[v.id] = v
        return hash

    update_orders: (list1, list2) ->
        hash1 = @list_to_hash(list1)
        hash2 = @list_to_hash(list2)
        for i2, v2 of list2
            v1 = hash1[v2.id]
            if v1
                v1.status = v2.status if v2.status
            else
                list1.push v2
        for i1, v1 of list1
            if !hash2[v1.id] and v1.status != "unconfirmed"
                list1.splice(v1.index, 1)

    invert_order_type: (type) ->
        return "ask_order" if type == "bid_order"
        return "bid_order" if type == "ask_order"
        return type


class MarketService

    TradeData: TradeData

    helper: new MarketHelper()

    market: new Market()

    asks: []
    bids: []
    shorts: []
    orders: []
    trades: []

    id_sequence: 0
    is_refreshing: false

    constructor: (@q, @interval, @wallet, @wallet_api, @blockchain, @blockchain_api) ->
        #console.log "MarketService constructor: ", @

    init: (market_name) ->
        market = @market
        market.name = market_name
        market_symbols = market.name.split(':')
        market.quantity_symbol = market_symbols[0]
        market.base_symbol = market_symbols[1]
        market.url = "#{market.quantity_symbol}:#{market.base_symbol}"
        market.inverted_url = "#{market.base_symbol}:#{market.quantity_symbol}"
        market.price_symbol = "#{market.base_symbol}/#{market.quantity_symbol}"
        market.assets_by_id = {}
        @blockchain.refresh_asset_records().then =>
            @q.all([@blockchain.get_asset(market.quantity_symbol), @blockchain.get_asset(market.base_symbol)]).then (results) ->
                market.quantity_asset = results[0]
                market.base_asset = results[1]
                market.assets_by_id[market.quantity_asset.id] = market.quantity_asset
                market.assets_by_id[market.base_asset.id] = market.base_asset
            #console.log "---- market: ", market
            @blockchain_api.market_status(market.quantity_symbol, market.base_symbol).then (result) =>
                market.inverted = true
                @helper.read_market_data(market, result)
                console.log "market_status inverted --->", result
            , =>
                @blockchain_api.market_status(market.base_symbol, market.quantity_symbol).then (result) =>
                    market.inverted = false
                    @helper.read_market_data(market, result)
                    console.log "market_status direct --->", result

    add_unconfirmed_order: (order) ->
        @id_sequence += 1
        order.id = @id_sequence
        order.status = "unconfirmed"
        @orders.unshift order

    cancel_order: (id) ->
        order = @helper.get_array_element_by_id(@orders, id)
        if order and order.status == "unconfirmed"
            @helper.remove_array_element_by_id(@orders, id)
            return
        order.status = "canceled" if order
        @wallet_api.market_cancel_order(id).then (result) =>
            console.log "---- order canceled: ", result
            #@helper.remove_array_element_by_id(@orders, id)

    confirm_order: (id, account) ->
        console.log "------", id, @orders
        order = @helper.get_array_element_by_id(@orders, id)
        order.status = "confirmed"
        if order.type == "bid_order" then @post_bid(order, account) else @post_ask(order, account)

    post_bid: (bid, account) ->
        call = if !@market.inverted
            console.log "---- adding bid regular ----", bid
            @wallet_api.market_submit_bid(account.name, bid.quantity, @market.base_symbol, bid.price, @market.quantity_symbol)
        else
            ibid = bid.invert()
            console.log "---- adding bid inverted ----", bid, ibid
            @wallet_api.market_submit_ask(account.name, ibid.quantity, @market.base_symbol, ibid.price, @market.quantity_symbol)
        call.then (result) =>
            console.log "---- add_bid added ----", result
            bid.status = "placed"
            #@bids.push bid

    post_ask: (ask, account) ->
        call = if !@market.inverted
            console.log "---- adding ask regular ----", ask
            @wallet_api.market_submit_ask(account.name, ask.quantity, @market.base_symbol, ask.price, @market.quantity_symbol)
        else
            iask = ask.invert()
            console.log "---- adding ask inverted ----", ask, iask
            @wallet_api.market_submit_bid(account.name, iask.quantity, @market.base_symbol, iask.price, @market.quantity_symbol)
        call.then (result) =>
            console.log "---- add_ask added ----", result
            ask.status = "placed"
            #@asks.push ask

    pull_bids: (market, inverted) ->
        #@bids.splice(0, @bids.length)
        bids = []
        call = if !inverted
            @blockchain_api.market_list_bids(market.base_symbol, market.quantity_symbol, 10)
        else
            @blockchain_api.market_list_asks(market.base_symbol, market.quantity_symbol, 10)
        call.then (results) =>
            for r in results
                #console.log "---- bid: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                bids.push td
            @helper.update_orders(@bids, bids)

    pull_asks: (market, inverted) ->
        #@asks.splice(0, @asks.length)
        asks = []
        call = if !inverted
            @blockchain_api.market_list_asks(market.base_symbol, market.quantity_symbol, 10)
        else
            @blockchain_api.market_list_bids(market.base_symbol, market.quantity_symbol, 10)
        call.then (results) =>
            for r in results
                #console.log "---- ask: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                asks.push td
            @helper.update_orders(@asks, asks)

    pull_orders: (market, inverted) ->
        orders = []
        @wallet_api.market_order_list(market.base_symbol, market.quantity_symbol, 100).then (results) =>
            #console.log "market_order_list --> ", results
            for r in results
                #console.log "---- order: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                #td.status = "posted"
                orders.push td
            @helper.update_orders(@orders, orders)

    pull_history: (market, inverted) ->
        @trades.splice(0, @trades.length)
        @blockchain_api.market_order_history(market.quantity_symbol, market.base_symbol, 0, 100).then (results) =>
            console.log "==== market_order_history ===> ", market.quantity_asset, market.base_asset
            @trades.push @helper.trade_history_to_order(r, market.assets_by_id) for r in results


    pull_data: ->
        return if @is_refreshing
        @is_refreshing = true
        #console.log "market: ", @market
        #console.log "inverted: ", @market.get_inverted_clone()
        market = if @market.inverted then @market.invert() else @market
        console.log "--- pull_data --- market: #{market.name}, inverted: #{@market.inverted}"
        #promise =
#        @pull_bids(market, @market.inverted).then =>
#            @pull_asks(market, @market.inverted).then =>
#                @pull_orders(market, @market.inverted).then =>
#                    @is_refreshing = false
        @pull_history(@market, @market.inverted).then ->
            @is_refreshing = false
        #promise.finally => @is_refreshing = false

    watch_for_updates: =>
        @pull_data()
#        @interval (=>
#            @pull_data() if !@is_refreshing
#        ), 3000


angular.module("app").service("MarketService", ["$q", "$interval", "Wallet", "WalletAPI", "Blockchain",  "BlockchainAPI",  MarketService])
