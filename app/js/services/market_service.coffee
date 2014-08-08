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
        @actual_market = null
        @name = ''
        @quantity_symbol = ''
        @quantity_asset = null
        @quantity_decimals = 0
        @base_symbol = ''
        @base_asset = null
        @base_decimals = 0
        @inverted = true
        @url = ''
        @inverted_url = ''
        @price_symbol = ''
        @bid_depth = 0.0
        @ask_depth = 0.0
        @avg_price_24h = 0.0
        @assets_by_id = null
    get_actual_market: ->
        return @ if !@inverted
        return @actual_market if @actual_market
        m = new Market()
        m.name = "#{@base_symbol}:#{@quantity_symbol}"
        m.quantity_symbol = @base_symbol
        m.quantity_asset = @base_asset
        m.quantity_decimals = @base_decimals
        m.base_symbol = @quantity_symbol
        m.base_asset = @quantity_asset
        m.base_decimals = @quantity_decimals
        m.inverted = null
        m.url = @inverted_url
        m.inverted_url = @url
        m.price_symbol = "#{@quantity_symbol}/#{@base_symbol}"
        m.bid_depth = @bid_depth
        m.ask_depth = @ask_depth
        m.avg_price_24h = @avg_price_24h
        m.assets_by_id = @assets_by_id
        @actual_market = m
        return @actual_market

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
        td.type = if inverted then @invert_order_type(order.type) else order.type
        td.id = order.market_index.owner
        td.quantity = order.state.balance / ba.precision
        price = order.market_index.order_price.ratio * (ba.precision / qa.precision)
        td.price = if inverted then price else 1.0 / price
        td.cost = td.quantity * td.price
        return td

    trade_history_to_order: (t, assets) ->
        ba = assets[t.ask_price.base_asset_id]
        qa = assets[t.ask_price.quote_asset_id]
        console.log("-------------", t, assets) if !ba or !qa
        o = {type: t.bid_type}
        o.id = t.ask_owner
        o.price = t.ask_price.ratio * (ba.precision / qa.precision)
        o.paid = t.ask_paid.amount / ba.precision
        o.received = t.ask_received.amount / qa.precision
        return o

    array_to_hash: (list) ->
        hash = {}
        for i, v of list
            v.index = i
            hash[v.id] = v
        return hash

    update_array: (params) ->
        target = params.target
        data = params.data
        target_hash = @array_to_hash(target)
        data_hash = @array_to_hash(data)
        for i, dv of data
            tv = target_hash[dv.id]
            if tv
                params.update(tv,dv) if params.update
            else
                target.push dv
        for i, tv of target
            if !data_hash[tv.id]
                if params.can_remove
                    target.splice(tv.index, 1) if params.can_remove(tv)
                else
                    target.splice(tv.index, 1)

    invert_order_type: (type) ->
        return "ask_order" if type == "bid_order"
        return "bid_order" if type == "ask_order"
        return type


class MarketService

    TradeData: TradeData

    helper: new MarketHelper()

    market: null
    quantity_symbol: null
    base_symbol: null
    asks: null
    bids: null
    shorts: null
    covers: null
    orders: null
    trades: null

    id_sequence: 0
    is_refreshing: false
    loading_promise: null
    updates_promise: null

    constructor: (@q, @interval, @wallet, @wallet_api, @blockchain, @blockchain_api) ->
        #console.log "MarketService constructor: ", @

    init: (market_name) ->
        deferred = @q.defer()
        if @market and @market.name == market_name
            console.log "------ no reinit -----"
            deferred.resolve(@market)
            return deferred.promise

        @stop_updates()
        if @loading_promise
            @loading_promise.finally =>
                @market = null
                @create_new_market(market_name, deferred)
        else
            @market = null
            @create_new_market(market_name, deferred)

        deferred.promise.then (market) =>
            console.log "---- market initialized ----", market
            @market = market

        return deferred.promise

    create_new_market: (market_name, deferred) ->
        @asks = []
        @bids = []
        @shorts = []
        @covers = []
        @orders = []
        @trades = []
        market = new Market()
        market.name = market_name
        market_symbols = market.name.split(':')
        @quantity_symbol = market.quantity_symbol = market_symbols[0]
        @base_symbol = market.base_symbol = market_symbols[1]
        market.url = "#{market.quantity_symbol}:#{market.base_symbol}"
        market.inverted_url = "#{market.base_symbol}:#{market.quantity_symbol}"
        market.price_symbol = "#{market.base_symbol}/#{market.quantity_symbol}"
        market.assets_by_id = {}
        @blockchain.refresh_asset_records().then =>
            @q.all([@blockchain.get_asset(market.quantity_symbol), @blockchain.get_asset(market.base_symbol)]).then (results) =>
                console.log "-------------refresh_asset_records:",results
                if !results[0] or !results[1]
                    deferred.reject("Cannot initialize the market module. Can't get assets data.")
                market.quantity_asset = results[0]
                market.quantity_decimals = market.quantity_asset.precision.toString().length - 1
                market.base_asset = results[1]
                market.base_decimals = market.base_asset.precision.toString().length - 1
                market.assets_by_id[market.quantity_asset.id] = market.quantity_asset
                market.assets_by_id[market.base_asset.id] = market.base_asset
                #console.log "---- market: ", market
                @blockchain_api.market_status(market.quantity_symbol, market.base_symbol).then (result) =>
                    market.inverted = true
                    @helper.read_market_data(market, result)
                    console.log "market_status inverted --->", result
                    deferred.resolve(market)
                , =>
                    @blockchain_api.market_status(market.base_symbol, market.quantity_symbol).then (result) =>
                        market.inverted = false
                        @helper.read_market_data(market, result)
                        console.log "market_status direct --->", result
                        deferred.resolve(market)
                    , => deferred.reject("Cannot initialize the market module, the selected market may not exist.")
                , => deferred.reject("Cannot initialize the market module. Failed  get assets data.")

    add_unconfirmed_order: (order) ->
        @id_sequence += 1
        order.id = @id_sequence
        order.status = "unconfirmed"
        @orders.unshift order

    cancel_order: (id) ->
        order = @helper.get_array_element_by_id(@orders, id)
        if order and order.status == "unconfirmed"
            @helper.remove_array_element_by_id(@orders, id)
            return null
        order.status = "canceled" if order
        @wallet_api.market_cancel_order(id).then (result) =>
            #console.log "---- order canceled: ", result
            #@helper.remove_array_element_by_id(@orders, id)

    confirm_order: (id, account) ->
        #console.log "------", id, @orders
        order = @helper.get_array_element_by_id(@orders, id)
        order.status = "confirmed"
        if order.type == "bid_order"
            @post_bid(order, account)
        else if order.type == "ask_order"
            @post_ask(order, account)
        else
            @post_short(order, account)

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

    post_short: (short, account) ->
        @wallet_api.market_submit_short(account.name, short.quantity, short.price, @market.quantity_symbol).then (result) =>
            console.log "---- add_short added ----", result
            short.status = "placed"

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
            @blockchain_api.market_list_bids(market.base_symbol, market.quantity_symbol, 100)
        else
            @blockchain_api.market_list_asks(market.base_symbol, market.quantity_symbol, 100)
        call.then (results) =>
            for r in results
                #console.log "---- bid: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                bids.push td
            @helper.update_array {target: @bids, data: bids}

    pull_asks: (market, inverted) ->
        #@asks.splice(0, @asks.length)
        asks = []
        call = if !inverted
            @blockchain_api.market_list_asks(market.base_symbol, market.quantity_symbol, 100)
        else
            @blockchain_api.market_list_bids(market.base_symbol, market.quantity_symbol, 100)
        call.then (results) =>
            for r in results
                #console.log "---- ask: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                td.type = "ask"
                asks.push td
            @helper.update_array {target: @asks, data: asks, can_remove: (target_el) -> target_el.type == "ask" }

    pull_shorts: (market, inverted) ->
        shorts = []
        @blockchain_api.market_list_shorts(market.base_symbol, 100).then (results) =>
            #console.log "market_list_shorts --> ", results
            for r in results
                #console.log "---- short: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                td.type = "short"
                shorts.push td
            @helper.update_array {target: @asks, data: shorts, can_remove: (target_el) -> target_el.type == "short" }


    pull_covers: (market, inverted) ->
        covers = []
        @blockchain_api.market_list_covers(market.base_symbol, 100).then (results) =>
            #console.log "market_list_covers --> ", results
            for r in results
                console.log "---- cover: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                covers.push td
            @helper.update_array {target: @covers, data: covers}

    pull_orders: (market, inverted) ->
        orders = []
        @wallet_api.market_order_list(market.base_symbol, market.quantity_symbol, 100).then (results) =>
            #console.log "market_order_list --> ", results
            for r in results
                #console.log "---- order: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted)
                #td.status = "posted"
                orders.push td
            @helper.update_array
                target: @orders
                data: orders
                update: (target_el, data_el) ->
                    target_el.status = data_el.status if data_el.status
                can_remove: (target_el) -> target_el.status != "unconfirmed"

    pull_trades: (market, inverted) ->
        #@trades.splice(0, @trades.length)
        trades = []
        @blockchain_api.market_order_history(market.base_symbol, market.quantity_symbol, 0, 100).then (results) =>
            #console.log "==== market_order_history ===> ", results
            for r in results
                trades.push @helper.trade_history_to_order(r, market.assets_by_id)
            @helper.update_array {target: @trades, data: trades}

    pull_data: ->
        return if @is_refreshing or !@market
        @is_refreshing = true
        deferred = @q.defer()
        @loading_promise = deferred.promise
        market = @market.get_actual_market()
        console.log "--- pull_data --- market: #{market.name}, inverted: #{@market.inverted}"
        promises = []
        promises.push @pull_bids(market, @market.inverted)
        promises.push @pull_asks(market, @market.inverted)
        promises.push @pull_shorts(market, @market.inverted)
        #promises.push @pull_covers(market, @market.inverted)
        promises.push @pull_orders(market, @market.inverted)
        promises.push @pull_trades(market, @market.inverted)
        @q.all(promises).finally =>
            @is_refreshing = false
            deferred.resolve()
#        @pull_bids(market, @market.inverted).then =>
#            @pull_asks(market, @market.inverted).then =>
#                @pull_shorts(market, @market.inverted).then =>
#                    @pull_covers(market, @market.inverted).then =>
#                        @pull_orders(market, @market.inverted).then =>
#                            @pull_trades(@market, @market.inverted).then =>
#                                @is_refreshing = false
        #@is_refreshing = false
        #promise.finally => @is_refreshing = false

    watch_for_updates: ->
        @pull_data()
        @updates_promise = @interval (=>
            @pull_data()
        ), 3000

    stop_updates:  ->
        @interval.cancel(@updates_promise) if @updates_promise


angular.module("app").service("MarketService", ["$q", "$interval", "Wallet", "WalletAPI", "Blockchain",  "BlockchainAPI",  MarketService])
