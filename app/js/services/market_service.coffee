class TradeData

    @helper: null

    constructor: ->
        @type = null
        @id = null
        @uid = null
        @timestamp = null
        @quantity = null
        @quantity_filtered = null
        @price = null
        @price_int = null
        @price_dec = null
        @cost = 0.0
        @collateral
        @status = null # possible values: canceled, unconfirmed, confirmed, placed
        @warning = null
        @display_type = null
        @collateral_ratio = null
        @interest_rate = null
        @short_price_limit = null
        @received = null
        @paid = null

    invert: ->
        td = new TradeData()
        td.type = @type
        td.id = @id
        td.uid = @uid
        td.status = @status
        td.timestamp = @timestamp
        td.quantity = @cost
        td.quantity_filtered = @quantity_filtered
        td.cost = @quantity
        td.collateral = @collateral
        td.price = 1.0 / @price if @price and @price > 0.0
        td.price_int = @price_int
        td.price_dec = @price_dec
        td.warning = @warning
        td.display_type = @display_type
        td.collateral_ratio = @collateral_ratio
        td.interest_rate = @interest_rate
        td.short_price_limit = if @short_price_limit and @short_price_limit > 0.0 then 1.0 / @short_price_limit else null
        td.received = @received
        td.paid = @paid
        return td

    clone_and_normalize: ->
        td = angular.copy(@)
        td.quantity = TradeData.helper.to_float(@quantity)
        td.cost = TradeData.helper.to_float(@cost)
        td.collateral = TradeData.helper.to_float(@collateral)
        td.price = TradeData.helper.to_float(@price)
        td.collateral_ratio = TradeData.helper.to_float(@collateral_ratio)
        td.interest_rate = TradeData.helper.to_float(@interest_rate)
        td.short_price_limit = if @short_price_limit and @short_price_limit > 0.0 then TradeData.helper.to_float(@short_price_limit) else null
        td.received = TradeData.helper.to_float(@received)
        td.paid = TradeData.helper.to_float(@paid)
        td.timestamp = td.timestamp
        return td

    update: (td) ->
        @status = td.status
        @timestamp = td.timestamp
        @cost = td.cost
        @quantity= td.quantity
        @quantity_filtered = td.quantity_filtered
        @collateral = td.collateral
        @price = td.price
        @price_int = td.price_int
        @price_dec = td.price_dec
        @warning = td.warning
        @display_type = td.display_type
        @collateral_ratio = td.collateral_ratio
        @interest_rate = td.interest_rate
        @short_price_limit = td.short_price_limit
        @received = td.received
        @paid = td.paid

    touch: ->
        @timestamp = Date.now()
    expired: ->
        return Date.now() - @timestamp > 2000


class Market

    constructor: ->
        @actual_market = null
        @name = ''
        @quantity_symbol = ''
        @asset_quantity_symbol = ''
        @quantity_asset = null
        @quantity_precision = 0
        @base_symbol = ''
        @asset_base_symbol = ''
        @base_asset = null
        @base_precision = 0
        @price_precision = 0
        @inverted = true
        @url = ''
        @inverted_url = ''
        @price_symbol = ''
        @collateral_symbol = ''
        @bid_depth = 0.0
        @ask_depth = 0.0
        @feed_price = 0.0
        @highest_bid = 0.0
        @lowest_ask = 0.0
        @median_price = 0.0
        @shorts_price = 0.0
        @assets_by_id = null
        @shorts_available = false
        @orig_market = null
        @actual_market = null
        @error = {title: null, text: null}
        @max_trade = 0
        @daily_high = 0
        @daily_low = 0
        @volume = 0
        @change = 0
        @max_my_trades = 0

    get_actual_market: ->
        return @ if !@inverted
        return @actual_market if @actual_market
        m = new Market()
        m.name = "#{@base_symbol}:#{@quantity_symbol}"
        m.quantity_symbol = @base_symbol
        m.asset_quantity_symbol = @asset_base_symbol
        m.quantity_asset = @base_asset
        m.quantity_precision = @base_precision
        m.base_symbol = @quantity_symbol
        m.asset_base_symbol = @asset_quantity_symbol
        m.base_asset = @quantity_asset
        m.base_precision = @quantity_precision
        m.price_precision = @price_precision
        m.shorts_available = (m.base_asset?.id == 0 or m.quantity_asset?.id == 0) and not (m.base_asset.issuer_id > 0 or m.quantity_asset.issuer_id > 0)
        m.inverted = null
        m.url = @inverted_url
        m.inverted_url = @url
        m.price_symbol = "#{@quantity_symbol}/#{@base_symbol}"
        m.collateral_symbol = @collateral_symbol
        m.bid_depth = @bid_depth
        m.ask_depth = @ask_depth
        m.highest_bid = @highest_bid
        m.lowest_ask = @lowest_ask
        m.feed_price = @feed_price
        m.median_price = @median_price
        m.shorts_price = @shorts_price
        m.assets_by_id = @assets_by_id
        m.error = @error
        m.orig_market = @
        @actual_market = m
        return @actual_market

class MarketService

    TradeData: TradeData

    recent_markets: []
    market: null
    quantity_symbol: null
    base_symbol: null
    asks: null
    combined_asks: null
    bids: null
    combined_bids: null
    shorts: null
    covers: null
    orders: null
    trades: null
    price_history: null
    orderbook_chart_data = null
    history_interval = null

    id_sequence: 0
    loading_promise: null

    constructor: (@q, @interval, @log, @filter, @wallet, @wallet_api, @blockchain, @blockchain_api, @helper) ->
        window.hlp = @helper
        TradeData.helper = @helper

    load_recent_markets: ->
        return if @recent_markets.length > 0
        @recent_markets = []
        @wallet_api.get_setting("recent_markets").then (result) =>
            if result and result.value
                @recent_markets.splice(0, @recent_markets.length)
                @recent_markets.push r for r in JSON.parse(result.value.replace(/BTSX/g,'BTS').replace(/GLD/g,'GOLD'))

    add_recent_market: (market_name) ->
        index = @recent_markets.indexOf(market_name)
        @recent_markets.splice(index,1) if index >= 0
        market_symbols = market_name.split(':')
        if market_symbols.length == 2
            inverted_name = "#{market_symbols[1]}:#{market_symbols[0]}"
            index = @recent_markets.indexOf(inverted_name)
            @recent_markets.splice(index,1) if index >= 0
        @recent_markets.unshift(market_name)
        @recent_markets.pop() if @recent_markets.length > 20
        @wallet_api.set_setting("recent_markets", JSON.stringify(@recent_markets))

    init: (market_name) ->
        @add_recent_market(market_name)
        deferred = @q.defer()
        if @market and @market.name == market_name
            deferred.resolve(@market)
            return deferred.promise

        if @loading_promise
            @loading_promise.finally =>
                @market = null
                @create_new_market(market_name, deferred)
        else
            @market = null
            @create_new_market(market_name, deferred)

        return deferred.promise

    create_new_market: (market_name, deferred) ->
        @asks = []
        @combined_asks = []
        @bids = []
        @combined_bids = []
        @shorts = []
        @covers = []
        @orders = []
        @trades = []
        @my_trades = []
        @market = market = new Market()
        @history_interval = 1800;
        market.name = market_name
        market_symbols = market.name.split(':')
        @quantity_symbol = market.quantity_symbol = market_symbols[0]
        @base_symbol = market.base_symbol = market_symbols[1]
        market.url = "#{market.quantity_symbol}:#{market.base_symbol}"
        market.inverted_url = "#{market.base_symbol}:#{market.quantity_symbol}"
        market.price_symbol = "#{market.base_symbol}/#{market.quantity_symbol}"
        market.assets_by_id = {}
        market.asset_quantity_symbol = market.quantity_symbol.replace("Bit", "")
        market.asset_base_symbol = market.base_symbol.replace("Bit", "")
        @blockchain.refresh_asset_records().then =>
            @q.all([@blockchain.get_asset(market.asset_quantity_symbol), @blockchain.get_asset(market.asset_base_symbol), @blockchain.get_asset(0)]).then (results) =>
                if !results[0] or !results[1] or !results[2]
                    deferred.reject("Cannot initialize the market module, failed to get assets data.")
                    return
                market.quantity_asset = results[0]
                market.quantity_precision = market.quantity_asset.precision
                market.base_asset = results[1]
                market.base_precision = market.base_asset.precision
                market.price_precision = Math.max(market.quantity_precision, market.base_precision) * 10
                market.assets_by_id[market.quantity_asset.id] = market.quantity_asset
                market.assets_by_id[market.base_asset.id] = market.base_asset
                market.shorts_available = (market.base_asset.id == 0 or market.quantity_asset.id == 0) and not (market.base_asset.issuer_id > 0 or market.quantity_asset.issuer_id > 0)
                market.collateral_symbol = results[2].symbol
                market.inverted = market.quantity_asset.id > market.base_asset.id
                @pull_market_status().then ->
                    deferred.resolve(market)
                , =>
                    error_message = "Cannot get market status. Probably no orders have been placed."
                    market.error.title = error_message
                    @log.error "!!! Error in pull_market_status", error_message
                    deferred.resolve(market)
            , => deferred.reject("Cannot initialize market module, failed to get assets data.")

    change_history_interval: (interval) ->
        @history_interval = interval

    add_unconfirmed_order: (order) ->
        o = order #o = angular.copy(order)
        @id_sequence += 1
        o.id = "o" + @id_sequence
        o.status = "unconfirmed"
        @orders.unshift o

        @helper.sort_array @orders, "price", "quantity", false, (a, b) ->
                    return 1 if a.status == "unconfirmed" and b.status != "unconfirmed"
                    return -1 if a.status != "unconfirmed" and b.status == "unconfirmed"
                    return 0

    cancel_order: (id) ->
        order = @helper.get_array_element_by_id(@orders, id)
        if order and order.status == "unconfirmed"
            @helper.remove_array_element_by_id(@orders, id)
            return null
        order.status = "canceled" if order
        console.log "---- order canceling: ", id
        @wallet_api.market_cancel_order(id)

    confirm_order: (id, account) ->
        order = @helper.get_array_element_by_id(@orders, id)
        order.touch()
        order.status = "pending"
        order.warning = null
        call = if order.type == "bid_order"
            @post_bid(order, account)
        else if order.type == "ask_order"
            @post_ask(order, account)
        else if order.type == "short_order" 
            @post_short(order, account)
        else
            throw new Error "ERROR unknown order type: "+ order.type
        call.then (result) ->
            order.id = result.record_id
            console.log "===== order placed: ", order.id
        return call

    cover_order: (order, quantity, account, error_handler) ->
        order.touch()
        order.status = "pending"
        order.quantity -= quantity if quantity > 0.0 and order.quantity > quantity
        symbol = if @market.inverted then @market.asset_quantity_symbol else @market.asset_base_symbol
        console.log "------ wallet_market_cover #{[account.name, quantity, symbol, order.id].join(' ')}"
        @wallet_api.market_cover(account.name, quantity, symbol, order.id, error_handler)

    post_bid: (bid, account) ->
        call = if !@market.inverted
            console.log "---- adding bid regular ----", bid.quantity, @market.asset_quantity_symbol, bid.price, @market.asset_base_symbol
            @wallet_api.market_submit_bid(account.name, bid.quantity.toString(), @market.asset_quantity_symbol, bid.price.toString(), @market.asset_base_symbol)
        else
            ibid = bid.invert()
            console.log "---- adding bid inverted ----", ibid.quantity, @market.asset_base_symbol, ibid.price, @market.asset_quantity_symbol
            @wallet_api.market_submit_ask(account.name, ibid.quantity.toString(), @market.asset_base_symbol, ibid.price.toString(), @market.asset_quantity_symbol)
        return call

    post_short: (short, account) ->
        #if @market.inverted then 1.0/short.price else short.price
        actual_market = @market.get_actual_market()
        price_limit = 0.0
        if @market.inverted
            price_limit = 1.0 / short.short_price_limit if short.short_price_limit > 0.0
        else
            price_limit = short.short_price_limit

        console.log "---- before market_submit_short ----", account.name, short.collateral, actual_market.asset_quantity_symbol, short.interest_rate, actual_market.asset_base_symbol, price_limit
        call = @wallet_api.market_submit_short(account.name, short.collateral, actual_market.asset_quantity_symbol, short.interest_rate, actual_market.asset_base_symbol, price_limit)
        return call

    post_ask: (ask, account, deferred) ->
        call = if !@market.inverted
            console.log "---- adding ask regular ----", ask.quantity, @market.asset_quantity_symbol, ask.price, @market.asset_base_symbol
            @wallet_api.market_submit_ask(account.name, ask.quantity.toString(), @market.asset_quantity_symbol, ask.price.toString(), @market.asset_base_symbol)
        else
            iask = ask.invert()
            console.log "---- adding ask inverted ----", iask.quantity, @market.asset_base_symbol, iask.price, @market.asset_quantity_symbol
            @wallet_api.market_submit_bid(account.name, iask.quantity.toString(), @market.asset_base_symbol, iask.price.toString(), @market.asset_quantity_symbol)
        return call

    pull_bids: (market, inverted) ->
        bids = []
        call = if !inverted
            @blockchain_api.market_list_bids(market.asset_base_symbol, market.asset_quantity_symbol, 1000)
        else
            @blockchain_api.market_list_asks(market.asset_base_symbol, market.asset_quantity_symbol, 1000)
        call.then (results) =>
            for r in results
                td = new TradeData()
                @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted, inverted, td)
                td.type = "bid"
                @highest_bid = td.price if td.price > @highest_bid
                price_string = @helper.split_price td.price, market, inverted
                # price_string = td.price.toFixed(4).split(".")
                td.price_int = price_string[0]
                td.price_dec = price_string[1]
                td.quantity_filtered = @helper.filter_quantity(td.quantity,market, inverted)
                
                bids.push td
            #console.log "------ pull_bids ------>", bids.length, @bids.length
            @helper.update_array {target: @bids, data: bids, can_remove: (target_el) -> target_el.type == "bid"}

    pull_asks: (market, inverted) ->
        asks = []
        call = if !inverted
            @blockchain_api.market_list_asks(market.asset_base_symbol, market.asset_quantity_symbol, 1000)
        else
            @blockchain_api.market_list_bids(market.asset_base_symbol, market.asset_quantity_symbol, 1000)
        call.then (results) =>
            for r in results
                td = new TradeData()
                @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted, inverted, td)
                td.type = "ask"
                @lowest_ask = td.price if td.price < @lowest_ask
                price_string = @helper.split_price td.price, market, inverted
                td.price_int = price_string[0]
                td.price_dec = price_string[1]
                td.quantity_filtered = @helper.filter_quantity(td.quantity,market, inverted)
                asks.push td
            #console.log "------ pull_asks ------>", asks.length, @asks.length
            @helper.update_array {target: @asks, data: asks, can_remove: (target_el) -> target_el.type == "ask" }

    pull_shorts: (market, inverted) ->
        shorts = []
        shorts_price = if inverted and market.shorts_price > 0 then 1.0 / market.shorts_price else market.shorts_price
        short_wall = new TradeData()
        short_wall.id = "short_wall"
        short_wall.uid = "short_wall"
        short_wall.display_type = "Short Wall"
        short_wall.type = "short_wall"
        short_wall.price = shorts_price
        short_wall.cost = 0.0
        short_wall.quantity = 0.0
        short_wall_dest = if inverted then @asks else @bids

        @blockchain_api.market_list_shorts(market.asset_base_symbol, 1000).then (results) =>
            for r in results
                #console.log "---- 1 short: ", r, inverted, market.base_asset, market.quantity_asset
                td = new TradeData()
                @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, false, inverted, td)
                td.type = "short"
                td.quantity = td.collateral * market.shorts_price / 2.0

                #console.log "---- 2 short: ", td.cost, td.quantity, td.price, td.short_price_limit, shorts_price
                #console.log "------ short ------>", td.cost, td.quantity
                if @helper.is_in_short_wall(td, shorts_price, inverted)
                    if inverted
                        short_wall.cost +=  td.quantity * shorts_price #td.collateral
                        short_wall.quantity += td.quantity
                        @lowest_ask = shorts_price if shorts_price < @lowest_ask
                        if td.short_price_limit == null || td.short_price_limit < short_wall.price
                            td.short_price_limit = short_wall.price   
                    else
                        short_wall.quantity += td.quantity / shorts_price #td.collateral
                        short_wall.cost += td.quantity
                        @highest_bid = shorts_price if shorts_price > @highest_bid
                        if td.short_price_limit == null || td.short_price_limit > short_wall.price
                            td.short_price_limit = short_wall.price
                else
                    if inverted
                        @lowest_ask = td.short_price_limit if td.short_price_limit < @lowest_ask
                    else
                        @highest_bid = td.short_price_limit if td.short_price_limit > @highest_bid

                price_string = @helper.split_price td.short_price_limit, market, inverted
                td.price_int = price_string[0]
                td.price_dec = price_string[1]
                td.quantity_filtered = @helper.filter_quantity(td.quantity,market, inverted)
                
                
                shorts.push td
                ###
                for s in self.shorts
                    if self.market.inverted
                                     
                        
                    else
                       
                ###

            #console.log "------ short wall ------>", short_wall
            @helper.update_array {target: @shorts, data: shorts}
            if short_wall.quantity > 0.0
                price_string = @helper.split_price short_wall.price, market, inverted
                short_wall.price_int = price_string[0]
                short_wall.price_dec = price_string[1]
                short_wall.quantity_filtered = @helper.filter_quantity(short_wall.quantity, market, inverted)
                
            short_wall_array = if short_wall.cost > 0.0 or short_wall.quantity > 0.0 then [short_wall] else []
            @helper.update_array {
                target: short_wall_dest, 
                data: short_wall_array,
                update: (target_el, data) =>
                    target_el.price = data.price
                    target_el.price_int = data.price_int
                    target_el.price_dec = data.price_dec
                    target_el.quantity = data.quantity
                can_remove: (target_el) -> 
                    target_el.type == "short_wall"
                }

    combine_orders: (market,inverted) ->
        if deferred
            return deferred
        if inverted
            feed_price = 1 / market.feed_price
        else
            feed_price = market.feed_price
        deferred = @q.defer()

        combined_asks = []
        for ask in @asks
            if ask.type != "short_wall"
                combined_asks.push ask

        combined_bids = []
        for bid in @bids
            if bid.type != "short_wall"
                combined_bids.push bid

        price_string = null
        now = new Date()
        if market.shorts_available
            for short in @shorts
                if inverted
                    if short.short_price_limit >= feed_price
                        short.price = short.short_price_limit
                        combined_asks.push short 
                    else if short.short_price_limit < feed_price
                        short.price = feed_price
                        combined_asks.push short 
                else
                    if short.short_price_limit <= feed_price
                        short.price = short.short_price_limit
                        combined_bids.push short 
                    else
                        short.price = feed_price
                        combined_bids.push short 
            ###
            for cover in @covers
                console.log cover
                if new Date(cover.expiration.timestamp) > now or !(inverted and ask.price < feed_price) or (!inverted and ask.price > feed_price)
                    if not inverted
                        combined_asks.push cover          
                    else
                        combined_bids.push cover
            ###

        for ask in combined_asks
            if inverted                
                if ask.type == "short" and ask.short_price_limit > feed_price
                    ask.price = ask.short_price_limit
        
        for bid in combined_bids
            if not inverted
                if bid.type == "short" and bid.short_price_limit < feed_price
                    bid.price = bid.short_price_limit

        @helper.update_array {
            target: @combined_asks, 
            data: combined_asks, 
            can_remove: (target_el) -> 
                target_el.type == "ask" || target_el.type == "short" || target_el.type == "short_wall" || target_el.type == "margin_order"
            }
        @helper.update_array {
            target: @combined_bids, 
            data: combined_bids, 
            can_remove: (target_el) -> 
                target_el.type == "bid" || target_el.type == "short" || target_el.type == "short_wall" || target_el.type == "margin_order"
            }

        @combined_asks.sort (a,b) ->
            if a.interest_rate and b.interest_rate
                if a.price - b.price == 0
                    if b.interest_rate - a.interest_rate == 0 then b.quantity - a.quantity else b.interest_rate - a.interest_rate
                else 
                    a.price - b.price
            else if a.interest_rate and !b.interest_rate
                if a.price - b.price == 0 then -1 else a.price - b.price
            else if b.interest_rate and !a.interest_rate
                if a.price - b.price == 0 then 1 else a.price - b.price
            else
                if a.price - b.price == 0 then b.quantity - a.quantity else a.price - b.price

        @combined_bids.sort (a,b) ->
            if a.interest_rate and b.interest_rate
                if b.price - a.price == 0
                    if b.interest_rate - a.interest_rate == 0 then b.quantity - a.quantity else b.interest_rate - a.interest_rate
                else 
                    b.price - a.price
            else if a.interest_rate and !b.interest_rate
                if b.price - a.price == 0 then -1 else b.price - a.price
            else if b.interest_rate and !a.interest_rate
                if b.price - a.price == 0 then 1 else b.price - a.price
            else
                if b.price - a.price == 0 then b.quantity - a.quantity else b.price - a.price
        
        #@combined_bids.sort (a,b) ->
        #    if b.price - a.price == 0 then a.quantity - b.quantity else b.price - a.price

        deferred.resolve(true)
       
    pull_covers: (market, inverted) ->
        covers = []
        feed_price =  if inverted then 1 / market.feed_price else market.feed_price
        now  = Date.now()
        expired = 0
        margin_called = 0
        margin_orders = new TradeData()
        margin_orders.uid = "forced_covers"
        margin_orders.type = "margin_order"
        margin_orders.price = if inverted then feed_price * 1.1 else feed_price * (1/1.1)
        margin_orders.cost = 0.0
        margin_orders.quantity = 0.0
        margin_orders.collateral = 0.0

        expired_orders = new TradeData()
        expired_orders.uid = "expired_covers"
        expired_orders.type = "margin_order"
        expired_orders.price = feed_price
        expired_orders.cost = 0.0
        expired_orders.quantity = 0.0
        expired_orders.collateral = 0.0

        margin_calls_dest = if inverted then @bids else @asks

        @blockchain_api.market_list_covers(market.asset_base_symbol, market.asset_quantity_symbol, 1000).then (results) =>
            results = if results then [].concat.apply(results) else [] # flattens array of results
            for r, i in results
                continue unless r.type == "cover_order"
                #r.type = "cover"
                td = new TradeData()
                @helper.cover_to_trade_data(r, market, inverted, td)
                #console.log "---- cover ", r.state.balance, td.cost
                td.collateral = r.collateral / market.quantity_precision
                td.quantity = if inverted then td.cost else td.cost / feed_price
                price_string = @helper.split_price feed_price, market, inverted
                td.price_int = price_string[0]
                td.price_dec = price_string[1]
                td.quantity_filtered = @helper.filter_quantity(td.quantity,market, inverted)
                #td.type = "cover"
                if new Date(r.expiration) < now
                    expired++
                    expired_orders.collateral += td.collateral
                    expired_orders.cost += td.cost
                    expired_orders.quantity += td.quantity
                else if (inverted and td.price < feed_price) or (!inverted and td.price > feed_price)
                    margin_called++
                    margin_orders.collateral += td.collateral
                    margin_orders.cost += td.cost
                    margin_orders.quantity += td.quantity
            
                covers.push td


            @helper.update_array {target: @covers, data: covers }
            #console.log "------ pull_covers ------>", @covers
            #@helper.sort_array(@covers, "price", "quantity", !inverted)

            if expired_orders.quantity > 0.0
                price_string = @helper.split_price expired_orders.price, market, inverted
                expired_orders.price_int = price_string[0]
                expired_orders.price_dec = price_string[1]
                expired_orders.quantity_filtered = @helper.filter_quantity(expired_orders.quantity, market, inverted)
                if inverted
                    @highest_bid = expired_orders.price if expired_orders.price > @highest_bid
                else
                    @lowest_ask = expired_orders.price if expired_orders.price < @lowest_ask
            if margin_orders.quantity > 0.0
                price_string = @helper.split_price margin_orders.price, market, inverted
                margin_orders.price_int = price_string[0]
                margin_orders.price_dec = price_string[1]
                margin_orders.quantity_filtered = @helper.filter_quantity(margin_orders.quantity, market, inverted)
                if inverted
                    @highest_bid = margin_orders.price if margin_orders.price > @highest_bid
                else
                    @lowest_ask = margin_orders.price if margin_orders.price < @lowest_ask

            #console.log margin_orders, expired_orders

            expired_orders_array = if expired_orders.cost > 0.0 or expired_orders.quantity > 0.0 then [expired_orders] else []
            margin_orders_array = if margin_orders.cost > 0.0 or margin_orders.quantity > 0.0 then [margin_orders] else []
            
            @helper.update_array {
                target: margin_calls_dest, 
                data: expired_orders_array,
                can_remove: (target_el) -> 
                    target_el.uid == "expired_covers"
                }

            @helper.update_array {
                target: margin_calls_dest, 
                data: margin_orders_array,
                can_remove: (target_el) -> 
                    target_el.uid == "forced_covers"
                }


    pull_orders: (market, inverted, account_name) ->
        orders = []
        deferred = @q.defer()
#        @wallet_api.account_transaction_history(account_name).then (results) =>
#            for t in results
#                continue if t.is_confirmed
#                order = @helper.find_by_id(@orders, t.trx_id)
#                if order
#                    order.status = "pending"
#                    order.touch()

        @wallet_api.market_order_list(market.asset_base_symbol, market.asset_quantity_symbol, 100, account_name).then (results) =>
            for r in results
                td = new TradeData()
                order = r
                if r instanceof Array and r.length > 1
                    td.id = r[0]
                    order = r[1]
                #console.log "------ market order ------>", order
                if order.type == "cover_order"
                    @helper.cover_to_trade_data(order, market, inverted, td)
                    #console.log("------ cover order ------>", order, td)
                else
                    @helper.order_to_trade_data(order, market.base_asset, market.quantity_asset, inverted, inverted, inverted, td)
                td.status = "posted" if td.status != "cover"
                orders.push td
            @helper.update_array
                target: @orders
                data: orders
                update: (target_el, data_el) =>
                    if data_el.status and target_el.status != "canceled" and !(target_el.status == "pending" and !target_el.expired())
                        target_el.status = data_el.status
                    target_el.type = data_el.type
                    target_el.cost = data_el.cost
                    target_el.quantity = data_el.quantity
                    target_el.collateral = data_el.collateral
                    target_el.type = data_el.type
                    target_el.display_type = @helper.capitalize(target_el.type.split("_")[0])
                can_remove: (o) ->
                    #!(o.status == "unconfirmed" or (o.status == "pending" and !o.expired()))
                    !(o.status == "unconfirmed" or (o.status == "pending" and !o.expired()))

            @helper.sort_array @orders, "price", "quantity", false, (a, b) ->
                return 1 if a.status == "unconfirmed" and b.status != "unconfirmed"
                return -1 if a.status != "unconfirmed" and b.status == "unconfirmed"
                return 0

            deferred.resolve(true)

        , (error) -> deferred.reject(error)

        #, (error) -> deferred.reject(error)

        return deferred.promise


    pull_trades: (market, inverted) ->
        trades = []
        max = 0
        dailyHigh = 0
        dailyLow = 10e9
        volume = 0
        change = 0
        open = null

        @blockchain_api.market_order_history(market.asset_base_symbol, market.asset_quantity_symbol, 0, 500).then (results) =>
            now = new Date()
            today = now.setDate(now.getDate()-1)
            tradesFound = false
            n_trades = results.length

            for r, index in results
                td = new TradeData
                @helper.trade_history_to_order(r, td, market.assets_by_id, inverted)

                td.localtime = @helper.utils.toDate(td.timestamp.timestamp)
                price_string = @helper.split_price td.price, market, inverted
                td.price_int = price_string[0]
                td.price_dec = price_string[1]

                td.paid_filtered = @helper.filter_quantity(td.paid,market, inverted)
                td.received_filtered = @helper.filter_quantity(td.received,market, inverted)
                
                if index < 100 # because the order history table is limited to 100 items
                    if inverted
                        max = Math.max td.received, max
                    else
                        max = Math.max td.received, max
                
                if today < td.localtime
                    tradesFound = true
                    dailyHigh = Math.max(dailyHigh, td.price)
                    dailyLow = Math.min(dailyLow, td.price)
                    if inverted
                        if market.shorts_available
                            volume += td.paid * market.feed_price
                        else
                            volume += td.received
                    else
                        volume += td.paid
                    open = td.price

                trades.push td

            @market.max_trade = max

            # Check for duplicates in uid which will cause problems with angular and update_array
            temp = {duplicates: true}
            start = Date.now()
            while temp.duplicates
                temp = @helper.removeDuplicates trades, 100
                trades = temp.array
            
            if tradesFound
                @market.daily_high = dailyHigh
                @market.daily_low = dailyLow
                @market.volume = volume
                @market.change = 100 * (trades[0].price - open) / trades[0].price

            @helper.update_array {target: @trades, data: trades, update: null}

            @trades.sort (a,b) ->
                time_a = a.localtime.getTime()
                time_b = b.localtime.getTime()

                if time_b == time_a
                    if b.received == a.received then b.price - a.price else b.received - a.received 
                else 
                    time_b - time_a

    pull_my_trades: (market, inverted, account_name) ->
        new_trades = []
        last_trade_block_num = 0
        last_trade_id = null
        max = 0

        if @my_trades.length > 0
            last_trade_block_num = @my_trades[0].block_num
            last_trade_id = @my_trades[0].id

        toolkit_market_name = "#{market.asset_base_symbol} / #{market.asset_quantity_symbol}"
        promise = @wallet.refresh_transactions()
        promise.then =>
            transactions = @wallet.transactions[account_name] or []            
            for t in transactions
                #console.log "------ pull_my_trades transaction ------>", t, t.block_num < last_trade_block_num
                break if t.block_num < last_trade_block_num
                continue if not t.is_market
                continue if t.is_virtual
                if not t.is_confirmed
                    order = @helper.find_by_id(@orders, t.id)
                    if order
                        order.status = "pending"
                        order.touch()
                    continue
                continue unless t.ledger_entries.length > 0
                continue if last_trade_id == t.id
                td = {}
                td.block_num = t.block_num
                td.id = t.id
                td.time = @filter('prettySortableTime')(t.time)
                l = t.ledger_entries[0]
                continue unless l.memo.indexOf(toolkit_market_name) > 0
                td.memo = l.memo
                td.amount_asset = l.amount_asset
                max = Math.max td.amount_asset.amount, max
                parsed_memo = @helper.parse_memo td.memo, td.amount_asset.amount / td.amount_asset.precision, @market
                td.price_int = parsed_memo.price_int
                td.price_dec = parsed_memo.price_dec
                td.quantity = parsed_memo.quantity
                td.type = parsed_memo.type

                new_trades.push td
            #console.log "------ new trades ------>", new_trades
            @market.max_my_trades = max

            for t in new_trades.reverse()
                @my_trades.unshift t

        return promise

    pull_price_history: (market, inverted) ->
        #console.log "------ pull_price_history ------>"
        days = 365
        prc = (price) -> if inverted then 1.0/price else parseFloat price
        fetch_interval = "each_day"

        interval = @history_interval;
        desired_nr_items = 900;

        if interval < 3600 # one hour
            fetch_interval = "each_block"
        else if interval  < 3600 * 24 # one day
            fetch_interval = "each_hour"

        # start_time = @helper.formatUTCDate(new Date(Date.now()-days*24*3600*1000))
        start_time = @helper.formatUTCDate(new Date(Date.now()-interval * desired_nr_items * 1000))

        now  = Date.now();

        # console.log "start:",start_time, "duration:", (interval * desired_nr_items) / 60, "mins", "fetch_interval", fetch_interval

        @blockchain_api.market_price_history(market.asset_base_symbol, market.asset_quantity_symbol, start_time, 10 * interval * desired_nr_items, fetch_interval).then (result) =>
            # console.log "time to fetch price history:",Date.now()-now, "ms"
            now  = Date.now();

            ohlc_data = []
            volume_data = []

            current_interval = []

            # console.log "number of items in price history:", result.length

            if result.length > 0
                interval_time = new Date(result[result.length-1].timestamp)
                # console.log "first date:", new Date(result[0].timestamp), "last date:",interval_time
                rounded_initial_time = new Date(result[result.length-1].timestamp)
                rounded_initial_time.setSeconds(rounded_initial_time.getSeconds() - interval * 2)
                rounded_initial_time.setHours(0)
                rounded_initial_time.setMinutes(0)
                rounded_initial_time.setSeconds(0)

                while rounded_initial_time < interval_time
                    rounded_initial_time.setSeconds(rounded_initial_time.getSeconds() + interval)
                rounded_initial_time.setSeconds(rounded_initial_time.getSeconds() - interval)
                interval_time.setSeconds(0);
                interval_time = rounded_initial_time.getTime()

                interval_counter = 0 
                interval_o = null
                interval_l = null
                interval_h = null
                interval_v = 0
                c_old = null
                h_old = null
                l_old = null

            # in_interval = false
            for t, index in result by -1

                time = @helper.date(t.timestamp)

                # add the current interval to the array
                if time < interval_time 
                    ohlc_data.unshift [interval_time, interval_o, interval_h, interval_l, interval_c]
                    if inverted
                        volume_data.unshift [interval_time, interval_v / market.base_asset.precision]
                    else
                        volume_data.unshift [interval_time, interval_v / market.quantity_asset.precision]
                    interval_time -= interval * 1000
                    interval_counter = 0
                    interval_v = 0
                    in_interval = false

                # if the current time is outside the interval, adjust the interval time
                if not in_interval and time < interval_time 
                    while interval_time > time
                        interval_time -= interval * 1000
                else
                    in_interval = true

                o = prc(t.opening_price)
                c = prc(t.closing_price)
                lowest_ask = prc(t.lowest_ask)
                highest_bid = prc(t.highest_bid)
                h = if lowest_ask > highest_bid then lowest_ask else highest_bid
                l = if lowest_ask < highest_bid then lowest_ask else highest_bid

                h = o if o > h
                h = c if c > h
                l = o if o < l
                l = c if c < l

                oc_avg = (o + c) / 2.0
                h = 1.0 * Math.max(o,c) if h/oc_avg > 1.25
                l = 1.0 * Math.min(o,c) if oc_avg/l > 1.25

                # We're looping backwards in time so the current open is always the interval open
                interval_o = o

                # First point of the interval
                if interval_counter == 0
                    interval_c = c
                    interval_l = l
                    interval_h = h
                else # Remaining points
                    interval_l = Math.min l, interval_l
                    interval_h = Math.max h, interval_h

                if inverted
                    interval_v += t.quote_volume
                else
                    interval_v += t.base_volume
                    
                interval_counter++
                
                h_old = h
                l_old = l

                if index == 0
                    ohlc_data.unshift [interval_time, interval_o, interval_h, interval_l, interval_c]
                    if inverted
                        volume_data.unshift [interval_time, interval_v / market.base_asset.precision]
                    else
                        volume_data.unshift [interval_time, interval_v / market.quantity_asset.precision]

            # console.log "items in final array:", ohlc_data.length
            # console.log "first date:", new Date(ohlc_data[0][0]), "last date:",new Date(ohlc_data[ohlc_data.length - 1][0])
            if market.orig_market and inverted
                market.orig_market.price_history = ohlc_data
                market.orig_market.volume_history = volume_data
            else
                market.price_history = ohlc_data
                market.volume_history = volume_data
            

    pull_market_data: (data, deferred) ->
        self = data.context
        self.loading_promise = deferred.promise
        market = self.market.get_actual_market()
        self.lowest_ask = Number.MAX_VALUE
        self.highest_bid = 0.0
        #console.log "--- pull_data --- market: #{market.name}, inverted: #{self.market.inverted}, counter: #{@counter}:#{@counter%5}"
        promises = [
            self.pull_bids(market, self.market.inverted),
            self.pull_asks(market, self.market.inverted),
            self.pull_orders(market, self.market.inverted, data.account_name),
            self.pull_trades(market, self.market.inverted),
            self.pull_my_trades(market, self.market.inverted, data.account_name)
        ]
        if market.shorts_available
            promises.push(self.pull_shorts(market, self.market.inverted))
            promises.push(self.pull_covers(market, self.market.inverted))

        promises.push(self.pull_price_history(market, self.market.inverted)) if @counter % 5 == 0       

        
        self.q.all(promises).finally =>
            self.q.all([self.combine_orders(market, self.market.inverted)]).finally =>
                try
                    self.market.lowest_ask = market.lowest_ask = self.lowest_ask if self.lowest_ask != Number.MAX_VALUE
                    self.market.highest_bid = market.highest_bid = self.highest_bid

                    self.market.lowest_ask = market.lowest_ask = self.market.feed_price unless market.lowest_ask
                    self.market.highest_bid = market.highest_bid = self.market.feed_price unless market.highest_bid

                    self.helper.sort_array(self.asks, "price", "quantity", false)
                    self.helper.sort_array(self.bids, "price", "quantity", true)

                    # order book chart data
                    feed_price = self.market.feed_price
                    sum_asks = 0.0
                    asks_array = []
                    for a in self.asks
                        continue if feed_price and (a.price > 1.5 * feed_price or a.price < 0.5 * feed_price)
                        sum_asks += a.quantity
                        self.helper.add_to_order_book_chart_array(asks_array, a.price, sum_asks)
                    sum_bids = 0.0
                    bids_array = []
                    for b in self.bids
                        continue if feed_price and (b.price > 1.5 * feed_price or b.price < 0.5 * feed_price)
                        sum_bids += b.quantity
                        self.helper.add_to_order_book_chart_array(bids_array, b.price, sum_bids)

                    bids_array.sort (a,b) -> a[0] - b[0]
                    asks_array.sort (a,b) -> a[0] - b[0]
                    
                    bids_length = bids_array.length
                    asks_length = asks_array.length

                    high = null
                    low = null
                    
                    if asks_length > 0 and bids_length > 0
                        high = asks_array[0][0]
                        low = bids_array[bids_array.length - 1][0]
                    else if asks_length > 0
                        high = asks_array[0][0]
                        low = high;
                    else if bids_length > 0
                        low = bids_array[bids_array.length - 1][0]
                        high = low

                    avg_value = if (high and low) then (high + low) / 2 else null;

                    self.market.orderbook_chart_data =
                        bids_array: self.helper.flatten_orderbookchart(bids_array,false,true, self.market.price_precision)
                        asks_array: self.helper.flatten_orderbookchart(asks_array,false,false, self.market.price_precision)
                        avg_value: avg_value

                    # shorts collateralization chart data
#                    self.helper.sort_array(self.shorts, "price", "quantity", self.market.inverted)
#                    sum_shorts = 0.0
#                    shorts_array = []
#                    for s in self.shorts
#                        continue unless self.helper.is_in_short_wall(s, self.market.shorts_price, self.market.inverted)
#                        #console.log "------ S H O R T ------>", s.price, s.cost, s.quantity
#                        sum_shorts += if self.market.inverted then s.cost else s.quantity
#                        price = if self.market.inverted then s.price else 1.0/s.price
#                        self.helper.add_to_order_book_chart_array(shorts_array, price, sum_shorts)
#
#                    shorts_price = if self.market.inverted then self.market.shorts_price else 1.0/self.market.shorts_price
#                    self.helper.add_to_order_book_chart_array(shorts_array, shorts_price, sum_shorts)
#
#                    shorts_array.sort (a,b) -> a[0] - b[0]
#                    self.market.shortscollat_chart_data = { array: shorts_array }

                catch e
                    console.log "!!!!!! error in pull_market_data: ", e


                deferred.resolve(true)

    pull_market_status: (data = null, deferred = null) ->
        self = data?.context or @
        deferred ||= self.q.defer()
        market = self.market.get_actual_market()
        self.blockchain_api.market_status(market.asset_base_symbol, market.asset_quantity_symbol).then (result) ->
            self.helper.read_market_data(self.market, result, market.assets_by_id, self.market.inverted)
            self.market.price_precision = market.price_precision = 4 if self.market.feed_price > 1.0
            deferred.resolve(true)

            # override with median if it exists
            # TODO, median_price removed .. "finally" block remain intact
#            feeds_promise = self.blockchain_api.get_feeds_for_asset(market.asset_base_symbol)
#            feeds_promise.then (result) ->
#                res = jsonPath.eval(result, "$.[?(@.delegate_name=='MARKET')].median_price")
#                if res.length > 0
#                    price = if self.market.inverted then 1.0/res[0] else res[0]
#                    self.market.median_price = market.median_price = price
#                else
#                    self.market.median_price = market.median_price = self.market.feed_price
#            feeds_promise.catch ->
#                self.market.median_price = market.median_price = self.market.feed_price
#
#            feeds_promise.finally ->
#                actual_market = self.market.get_actual_market()
#                self.blockchain_api.market_get_asset_collateral( actual_market.asset_base_symbol ).then (amount) =>
#                    actual_market.collateral = amount / actual_market.quantity_precision
#                    self.blockchain_api.get_asset( actual_market.base_asset.id ).then (record) =>
#                        supply = record["current_supply"] / actual_market.base_precision
#                        actual_market.collateralization = 100 * ((actual_market.collateral / actual_market.median_price) / supply)
#                        deferred.resolve(true)
#                , (error) ->
#                    deferred.reject(error)

        , (error) ->
            deferred.reject(error)

        return deferred.promise


angular.module("app").service("MarketService", ["$q", "$interval", "$log", "$filter", "Wallet", "WalletAPI", "Blockchain",  "BlockchainAPI", "MarketHelper",  MarketService])
