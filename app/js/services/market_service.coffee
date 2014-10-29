class TradeData

    @helper: null

    constructor: ->
        @type = null
        @id = null
        @timestamp = null
        @quantity = null
        @price = null
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
        td.status = @status
        td.timestamp = @timestamp
        td.quantity = @cost
        td.cost = @quantity
        td.collateral = @collateral
        td.price = 1.0 / @price if @price and @price > 0.0
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
        @collateral = td.collateral
        @price = td.price
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
        m.shorts_available = m.base_asset?.id == 0 or m.quantity_asset?.id == 0
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
    bids: null
    shorts: null
    covers: null
    orders: null
    trades: null
    price_history: null
    orderbook_chart_data = null

    id_sequence: 0
    loading_promise: null

    constructor: (@q, @interval, @log, @wallet, @wallet_api, @blockchain, @blockchain_api, @helper) ->
        window.hlp = @helper
        TradeData.helper = @helper

    load_recent_markets: ->
        return if @recent_markets.length > 0
        @recent_markets = []
        @wallet_api.get_setting("recent_markets").then (result) =>
            if result and result.value
                @recent_markets.splice(0, @recent_markets.length)
                @recent_markets.push r for r in JSON.parse(result.value)

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
        @bids = []
        @shorts = []
        @covers = []
        @orders = []
        @trades = []
        @my_trades = []
        @market = market = new Market()
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
                market.shorts_available = market.base_asset.id == 0 or market.quantity_asset.id == 0
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
            @wallet_api.market_submit_bid(account.name, bid.quantity, @market.asset_quantity_symbol, bid.price, @market.asset_base_symbol)
        else
            ibid = bid.invert()
            console.log "---- adding bid inverted ----", ibid.quantity, @market.asset_base_symbol, ibid.price, @market.asset_quantity_symbol
            @wallet_api.market_submit_ask(account.name, ibid.quantity, @market.asset_base_symbol, ibid.price, @market.asset_quantity_symbol)
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
            @wallet_api.market_submit_ask(account.name, ask.quantity, @market.asset_quantity_symbol, ask.price, @market.asset_base_symbol)
        else
            iask = ask.invert()
            console.log "---- adding ask inverted ----", iask.quantity, @market.asset_base_symbol, iask.price, @market.asset_quantity_symbol
            @wallet_api.market_submit_bid(account.name, iask.quantity, @market.asset_base_symbol, iask.price, @market.asset_quantity_symbol)
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
                asks.push td
            #console.log "------ pull_asks ------>", asks.length, @asks.length
            @helper.update_array {target: @asks, data: asks, can_remove: (target_el) -> target_el.type == "ask" }

    pull_shorts: (market, inverted) ->
        shorts = []
        shorts_price = if inverted and market.shorts_price > 0 then 1.0 / market.shorts_price else market.shorts_price
        short_wall = new TradeData()
        short_wall.id = "short_wall"
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
                    #console.log "------ short wall ------>", td.collateral, td.quantity
                    if inverted
                        short_wall.cost += td.collateral
                        short_wall.quantity += td.quantity
                        #@lowest_ask = shorts_price if shorts_price < @lowest_ask
                    else
                        short_wall.quantity += td.collateral
                        short_wall.cost += td.quantity
                        #short_wall.quantity += td.cost
                        #short_wall.cost += td.cost / shorts_price
                    @highest_bid = shorts_price if shorts_price > @highest_bid

                shorts.push td

            #console.log "------ short wall ------>", short_wall
            @helper.update_array {target: @shorts, data: shorts}
            short_wall_array = if short_wall.cost > 0.0 or short_wall.quantity > 0.0 then [short_wall] else []
            @helper.update_array {target: short_wall_dest, data: short_wall_array, can_remove: (target_el) -> target_el.type == "short_wall"}

    pull_covers: (market, inverted) ->
        covers = []
        @blockchain_api.market_list_covers(market.asset_base_symbol, 1000).then (results) =>
            results = [].concat.apply(results) # flattens array of results
            for r in results
                continue unless r.type == "cover_order"
                #r.type = "cover"
                td = new TradeData()
                @helper.cover_to_trade_data(r, market, inverted, td)
                #console.log "---- cover ", r.state.balance, td.cost
                td.collateral = r.collateral / market.quantity_precision
                #td.type = "cover"
                covers.push td
            @helper.update_array {target: @covers, data: covers }
            #console.log "------ pull_covers ------>", @covers
            #@helper.sort_array(@covers, "price", "quantity", !inverted)

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
        @blockchain_api.market_order_history(market.asset_base_symbol, market.asset_quantity_symbol, 0, 500).then (results) =>
            for r in results
                td = new TradeData
                @helper.trade_history_to_order(r, td, market.assets_by_id, inverted)
                trades.push td
            @helper.update_array {target: @trades, data: trades, update: null}

    pull_my_trades: (market, inverted, account_name) ->
        new_trades = []
        last_trade_block_num = 0
        last_trade_id = null
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
                td.timestamp = t.pretty_time
                l = t.ledger_entries[0]
                continue unless l.memo.indexOf(toolkit_market_name) > 0
                td.memo = l.memo
                td.amount_asset = l.amount_asset
                new_trades.push td
            #console.log "------ new trades ------>", new_trades
            for t in new_trades.reverse()
                @my_trades.unshift t

        return promise

    pull_price_history: (market, inverted) ->
        #console.log "------ pull_price_history ------>"
        start_time = @helper.formatUTCDate(new Date(Date.now()-10*24*3600*1000))
        prc = (price) -> if inverted then 1.0/price else price

        @blockchain_api.market_price_history(market.asset_base_symbol, market.asset_quantity_symbol, start_time, 10*24*3600, 0).then (result) =>
            ohlc_data = []
            volume_data = []
            for t in result
                time = @helper.date(t.timestamp)
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
                h = 1.10 * Math.max(o,c) if h/oc_avg > 1.25
                l = 0.90 * Math.min(o,c) if oc_avg/l > 1.25

                ohlc_data.push [time, o, h, l, c]
                volume_data.push [time, t.volume / market.quantity_asset.precision]

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
                self.market.orderbook_chart_data =
                    bids_array: bids_array
                    asks_array: asks_array

                # shorts collateralization chart data
                self.helper.sort_array(self.shorts, "price", "quantity", self.market.inverted)
                sum_shorts = 0.0
                shorts_array = []
                for s in self.shorts
                    continue unless self.helper.is_in_short_wall(s, self.market.shorts_price, self.market.inverted)
                    #console.log "------ S H O R T ------>", s.price, s.cost, s.quantity
                    sum_shorts += if self.market.inverted then s.cost else s.quantity
                    price = if self.market.inverted then s.price else 1.0/s.price
                    self.helper.add_to_order_book_chart_array(shorts_array, price, sum_shorts)

                shorts_price = if self.market.inverted then self.market.shorts_price else 1.0/self.market.shorts_price
                self.helper.add_to_order_book_chart_array(shorts_array, shorts_price, sum_shorts)

                shorts_array.sort (a,b) -> a[0] - b[0]
                self.market.shortscollat_chart_data = { array: shorts_array }

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
#                        supply = record["current_share_supply"] / actual_market.base_precision
#                        actual_market.collateralization = 100 * ((actual_market.collateral / actual_market.median_price) / supply)
#                        deferred.resolve(true)
#                , (error) ->
#                    deferred.reject(error)

        , (error) ->
                deferred.reject(error)

        return deferred.promise


angular.module("app").service("MarketService", ["$q", "$interval", "$log", "Wallet", "WalletAPI", "Blockchain",  "BlockchainAPI", "MarketHelper",  MarketService])
