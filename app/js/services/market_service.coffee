class TradeData

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

    invert: ->
        td = new TradeData()
        td.type = @type
        td.id = @id
        td.status = @status
        td.timestamp = @timestamp
        td.quantity = @cost
        td.cost = @quantity
        td.collateral = @collateral
        #td.price = if @price and @price > 0.0 then 1.0 / @price else 0.0
        td.price = 1.0 / @price
        td.warning = @warning
        td.display_type = @display_type
        return td

    touch: ->
        @timestamp = Date.now()
    expired: ->
        return Date.now() - @timestamp > 15000


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
        @bid_depth = 0.0
        @ask_depth = 0.0
        @avg_price_24h = 0.0
        @highest_bid = 0.0
        @lowest_ask = 0.0
        @median_price = 0.0
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
        m.shorts_available = m.base_asset.id == 0
        m.inverted = null
        m.url = @inverted_url
        m.inverted_url = @url
        m.price_symbol = "#{@quantity_symbol}/#{@base_symbol}"
        m.bid_depth = @bid_depth
        m.ask_depth = @ask_depth
        m.highest_bid = @highest_bid
        m.lowest_ask = @lowest_ask
        m.avg_price_24h = @avg_price_24h
        m.median_price = @median_price
        m.assets_by_id = @assets_by_id
        m.error = @error
        m.orig_market = @
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

    ratio_to_price: (value, assets) ->
        return 0.0 if value.base_asset_id == 0 and value.quote_asset_id == 0
        ba = assets[value.base_asset_id]
        qa = assets[value.quote_asset_id]
        return value.ratio * (ba.precision / qa.precision)

    read_market_data: (market, data, assets) ->
        ba = assets[data.base_id]
        market.bid_depth = data.bid_depth / ba.precision
        market.ask_depth = data.ask_depth / ba.precision
        market.avg_price_24h = @ratio_to_price(data.avg_price_24h, assets)
        market.avg_price_24h = 1.0 / market.avg_price_24h if market.inverted and market.avg_price_24h > 0
        if data.last_error
            market.error.title = data.last_error.message
        else
            market.error.text = market.error.title = null


    order_to_trade_data: (order, qa, ba, invert_price, invert_assets, invert_order_type) ->
        td = new TradeData()
        td.type = if invert_order_type then @invert_order_type(order.type) else order.type
        td.id = order.market_index.owner
        price = order.market_index.order_price.ratio * (ba.precision / qa.precision)
        td.price = if invert_price then 1.0 / price else price
        if order.type == "cover_order"
            cover_price = 1.0 / price
            td.cost = order.state.balance / qa.precision
            td.quantity = -1.0 #td.cost * cover_price
            td.collateral = order.collateral / ba.precision
            td.type = "margin_order"
            td.status = "cover"
        else if order.type == "bid_order"
            td.cost = order.state.balance / qa.precision
            td.quantity = td.cost / price
            td.status = "posted"
        else
            td.quantity = order.state.balance / ba.precision
            td.cost = td.quantity * price
            td.status = "posted"

        if invert_assets
            [td.cost, td.quantity] = [td.quantity, td.cost]

        td.display_type = @capitalize(td.type.split("_")[0])

        return td

    trade_history_to_order: (t, assets, invert_price) ->
        ba = assets[t.ask_price.base_asset_id]
        qa = assets[t.ask_price.quote_asset_id]
        o = {type: t.bid_type}
        o.id = t.ask_owner
        o.price = t.ask_price.ratio * (ba.precision / qa.precision)
        o.price = 1.0 / o.price if invert_price
        o.paid = t.ask_paid.amount / ba.precision
        o.received = t.ask_received.amount / qa.precision
        o.timestamp = t.timestamp
        o.display_type = @capitalize(o.type.split("_")[0])
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

    capitalize: (str) ->
        str.charAt(0).toUpperCase() + str.slice(1)

    sort_array: (array, field, reverse = false) ->
         array.sort (a, b) ->
            a = a[field]
            b = b[field]
            if reverse then b - a else a - b

    invert_order_type: (type) ->
        return "ask_order" if type == "bid_order"
        return "bid_order" if type == "ask_order"
        return type

    find_order_by_transaction: (orders, t) ->
        res = jsonPath.eval(t, "$.ledger_entries[0].to_account")
        return null if not res or res.length == 0
        to_account = res[0]
        match = /^([A-Z]+)\-(\w+)/.exec(to_account)
        return null unless match
        subid = match[2]
        return null unless subid.length > 5
        for o in orders
            return o if o.id and o.id.indexOf(subid) > -1
        return null

    date: (t) ->
        dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
        match = t.match(dateRE)
        return 0 unless match
        nums = []
        i = 1
        while i < match.length
            nums.push parseInt(match[i], 10)
            i++
        Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5])

    forceTwoDigits : (val) ->
        if val < 10
            return "0#{val}"
        return val

    formatUTCDate : (date) ->
        year = date.getUTCFullYear()
        month = @forceTwoDigits(date.getUTCMonth()+1)
        day = @forceTwoDigits(date.getUTCDate())
        hour = @forceTwoDigits(date.getUTCHours())
        minute = @forceTwoDigits(date.getUTCMinutes())
        second = @forceTwoDigits(date.getUTCSeconds())
        return "#{year}#{month}#{day}T#{hour}#{minute}#{second}"


class MarketService

    TradeData: TradeData

    helper: new MarketHelper()

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

    constructor: (@q, @interval, @log, @filter, @wallet, @wallet_api, @blockchain, @blockchain_api) ->
        #console.log "MarketService constructor: ", @

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
            @q.all([@blockchain.get_asset(market.asset_quantity_symbol), @blockchain.get_asset(market.asset_base_symbol)]).then (results) =>
                if !results[0] or !results[1]
                    deferred.reject("Cannot initialize the market module. Can't get assets data.")
                    return
                market.quantity_asset = results[0]
                market.quantity_precision = market.quantity_asset.precision
                market.base_asset = results[1]
                market.base_precision = market.base_asset.precision
                market.price_precision = Math.max(market.quantity_precision, market.base_precision) * 100
                market.assets_by_id[market.quantity_asset.id] = market.quantity_asset
                market.assets_by_id[market.base_asset.id] = market.base_asset
                market.shorts_available = market.base_asset.id == 0
                if market.quantity_asset.id > market.base_asset.id
                    market.inverted = true
                    status_call = @blockchain_api.market_status(market.asset_quantity_symbol, market.asset_base_symbol)
                else
                    market.inverted = false
                    status_call = @blockchain_api.market_status(market.asset_base_symbol, market.asset_quantity_symbol)
                status_call.then (result) =>
                    console.log "market_status #{if market.inverted then 'inverted' else 'direct'} --->", result
                    @helper.read_market_data(market, result, market.assets_by_id)
                    deferred.resolve(market)
                , =>
                    error_message = "No orders have been placed."
                    market.error.title = error_message
                    @log.error error_message
                    deferred.resolve(market)
            , => deferred.reject("Cannot initialize market module. Failed to get assets data.")

    add_unconfirmed_order: (order) ->
        @id_sequence += 1
        order.id = "o" + @id_sequence
        order.status = "unconfirmed"
        #console.log "------ add_unconfirmed_order ------>", order
        @orders.unshift order
        #sorted_orders = @filter('orderBy')(@orders, 'price', false)
        #console.log "------ sorted_orders ------>", sorted_orders
        @helper.sort_array(@orders, "price")

    cancel_order: (id) ->
        order = @helper.get_array_element_by_id(@orders, id)
        if order and order.status == "unconfirmed"
            @helper.remove_array_element_by_id(@orders, id)
            return null
        order.status = "canceled" if order
        console.log "---- order canceling: ", id
        @wallet_api.market_cancel_order(id).then (result) =>
            #console.log "---- order canceled: ", result
            #@helper.remove_array_element_by_id(@orders, id)

    confirm_order: (id, account) ->
        order = @helper.get_array_element_by_id(@orders, id)
        order.touch()
        order.status = "pending"
        call = if order.type == "bid_order"
            @post_bid(order, account)
        else if order.type == "ask_order"
            @post_ask(order, account)
        else
            @post_short(order, account)
        call.then (result) ->
            console.log "===== order placed: ", result
            res = jsonPath.eval(result, "$.[*].data..owner")
            order.id = res[0] if res.length == 1
        return call

    cover_order: (order, account) ->
        order.touch()
        order.status = "pending"
        symbol = if @market.inverted then @market.asset_quantity_symbol else @market.asset_base_symbol
        @wallet_api.market_cover(account.name, order.quantity, symbol, order.id)

    post_bid: (bid, account) ->
        call = if !@market.inverted
            console.log "---- adding bid regular ----", bid
            @wallet_api.market_submit_bid(account.name, bid.quantity, @market.asset_quantity_symbol, bid.price, @market.asset_base_symbol)
        else
            ibid = bid.invert()
            console.log "---- adding bid inverted ----", bid, ibid
            @wallet_api.market_submit_ask(account.name, ibid.quantity, @market.asset_base_symbol, ibid.price, @market.asset_quantity_symbol)
        return call

    post_short: (short, account) ->
        price = if @market.inverted then 1.0/short.price else short.price
        console.log "---- before market_submit_short ----", account.name, short.quantity, price, @market.quantity_symbol
        call = @wallet_api.market_submit_short(account.name, short.quantity, price, @market.asset_quantity_symbol)
        return call

    post_ask: (ask, account, deferred) ->
        call = if !@market.inverted
            console.log "---- adding ask regular ----", ask
            @wallet_api.market_submit_ask(account.name, ask.quantity, @market.asset_quantity_symbol, ask.price, @market.asset_base_symbol)
        else
            iask = ask.invert()
            console.log "---- adding ask inverted ----", ask, iask
            @wallet_api.market_submit_bid(account.name, iask.quantity, @market.asset_base_symbol, iask.price, @market.asset_quantity_symbol)
        return call

    pull_bids: (market, inverted) ->
        bids = []
        call = if !inverted
            @blockchain_api.market_list_bids(market.asset_base_symbol, market.asset_quantity_symbol, 100)
        else
            @blockchain_api.market_list_asks(market.asset_base_symbol, market.asset_quantity_symbol, 100)
        call.then (results) =>
            for r in results
                #console.log "---- bid: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted, inverted)
                td.type = "bid"
                @highest_bid = td.price if td.price > @highest_bid
                bids.push td
            @helper.update_array {target: @bids, data: bids, can_remove: (target_el) -> target_el.type == "bid"}

    pull_asks: (market, inverted) ->
        asks = []
        call = if !inverted
            @blockchain_api.market_list_asks(market.asset_base_symbol, market.asset_quantity_symbol, 100)
        else
            @blockchain_api.market_list_bids(market.asset_base_symbol, market.asset_quantity_symbol, 100)
        call.then (results) =>
            for r in results
                #console.log "---- ask: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted, inverted)
                td.type = "ask"
                @lowest_ask = td.price if td.price < @lowest_ask
                asks.push td
            @helper.update_array {target: @asks, data: asks, can_remove: (target_el) -> target_el.type == "ask" }

    pull_shorts: (market, inverted) ->
        shorts = []
        dest = if inverted then @asks else @bids
        @blockchain_api.market_list_shorts(market.asset_base_symbol, 100).then (results) =>
            for r in results
                #console.log "---- short: ", r
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted, inverted)
                td.type = "short"
                if inverted
                    @lowest_ask = td.price if td.price < @lowest_ask
                else
                    @highest_bid = td.price if td.price > @highest_bid
                shorts.push td
            @helper.update_array {target: dest, data: shorts, can_remove: (target_el) -> target_el.type == "short" }

    pull_covers: (market, inverted) ->
        covers = []
        @blockchain_api.market_order_book(market.asset_base_symbol, market.asset_quantity_symbol, 100).then (results) =>
            results = [].concat.apply(results) # flattens array of results
            for r in results[1]
                continue unless r.type == "cover_order"
                #console.log "---- cover ", r
                #r.type = "cover"
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, false, inverted)
                #td.type = "cover"
                covers.push td
            @helper.update_array {target: @covers, data: covers }

    pull_orders: (market, inverted, account_name) ->
        orders = []
        @wallet_api.market_order_list(market.asset_base_symbol, market.asset_quantity_symbol, 100, account_name).then (results) =>
            for r in results
                td = @helper.order_to_trade_data(r, market.base_asset, market.quantity_asset, inverted, inverted,
                    inverted)
                #console.log("------ market_order_list ------>", r, td) if r.type == "cover_order"
                #td.status = "posted" if td.status != "cover"
                orders.push td
            @helper.update_array
                target: @orders
                data: orders
                update: (target_el, data_el) ->
                    if data_el.status and target_el.status != "canceled" and !(target_el.status == "pending" and !target_el.expired())
                        target_el.status = data_el.status
                can_remove: (o) ->
                    #!(o.status == "unconfirmed" or (o.status == "pending" and !o.expired()))
                    !(o.status == "unconfirmed" or (o.status == "pending" and !o.expired()))
            @helper.sort_array(@orders, "price", false)
            if magic_unicorn?
                magic_unicorn.log_message("in MarketService.pull_orders - received orders: #{results.length}, orders shown: #{@orders.length}")


    pull_trades: (market, inverted) ->
        trades = []
        @blockchain_api.market_order_history(market.asset_base_symbol, market.asset_quantity_symbol, 0, 100).then (results) =>
            for r in results
                td = @helper.trade_history_to_order(r, market.assets_by_id, inverted)
                trades.push td
                #console.log "------ market_order_history ------>", r, td
            @helper.update_array {target: @trades, data: trades}

    pull_unconfirmed_transactions: (account_name) ->
        @wallet_api.account_transaction_history(account_name).then (results) =>
            for t in results
                continue if t.is_confirmed
                order = @helper.find_order_by_transaction(@orders, t)
                if order
                    order.status = "pending"
                    order.touch()
                
    pull_price_history: (market, inverted) ->
        #console.log "------ pull_price_history ------>"
        start_time = @helper.formatUTCDate(new Date(Date.now()-24*3600*1000))
        precision = (market.price_precision+"").length - 1
        @blockchain_api.market_price_history(market.asset_base_symbol, market.asset_quantity_symbol, start_time, 86400).then (result) =>
            highest_bid_data = []
            lowest_ask_data = []
            for t in result
                highest_bid = if inverted then 1.0/t.highest_bid else t.highest_bid
                lowest_ask = if inverted then 1.0/t.lowest_ask else t.lowest_ask
                highest_bid_data.push [@helper.date(t.timestamp), Number(highest_bid).toFixed(precision)/1.0]
                lowest_ask_data.push [@helper.date(t.timestamp), Number(lowest_ask).toFixed(precision)/1.0]

            price_history = []
            if highest_bid_data.length > 0
                price_history.push {"key": "Highest Bid", color: "#2ca02c", "values": highest_bid_data}
                price_history.push {"key": "Lowest Ask", color: "#ff7f0e", "values": lowest_ask_data}

            if market.orig_market and inverted
                market.orig_market.price_history = price_history
            else
                market.price_history = price_history


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
            self.pull_shorts(market, self.market.inverted),
            self.pull_covers(market, self.market.inverted),
            self.pull_orders(market, self.market.inverted, data.account_name),
            self.pull_trades(market, self.market.inverted),
            self.pull_unconfirmed_transactions(data.account_name)
        ]
        promises.push(self.pull_price_history(market, self.market.inverted)) if @counter % 10 == 0

        self.q.all(promises).finally =>
            try
                self.market.lowest_ask = market.lowest_ask = self.lowest_ask if self.lowest_ask != Number.MAX_VALUE
                self.market.highest_bid = market.highest_bid = self.highest_bid

                self.helper.sort_array(self.asks, "price", false)
                self.helper.sort_array(self.bids, "price", true)

                if @counter % 5 == 0
                    p_precision = (self.market.price_precision+"").length - 1
                    q_precision = (self.market.quantity_precision+"").length - 1
                    sum_asks = 0.0
                    sum_bids = 0.0
                    asks_array = []
                    bids_array = []
                    for a in self.asks
                        sum_asks += a.quantity
                        #console.log "------ ask ------>", a.price, sum_asks
                        asks_array.push [Number(a.price,).toFixed(p_precision)/1.0, Number(sum_asks).toFixed(q_precision)/1.0]

                    for b in self.bids #.reverse()
                        sum_bids += b.quantity
                        #console.log "------ bid ------>", b.price, sum_bids
                        bids_array.push [Number(b.price,).toFixed(p_precision)/1.0, Number(sum_bids).toFixed(q_precision)/1.0]

                    orderbook_chart_data = []
                    if sum_asks > 0.0 or sum_bids > 0.0
                        orderbook_chart_data.push {"key": "Bids", "area": true, color: "#2ca02c", "values": bids_array}
                        orderbook_chart_data.push {"key": "Asks", "area": true, color: "#ff7f0e", "values": asks_array}
                    #console.log "------ orderbook_chart_data ------>", orderbook_chart_data
                    self.market.orderbook_chart_data = orderbook_chart_data

            catch e
                console.log "!!!!!! error in pull_market_data: ", e


            deferred.resolve(true)

    pull_market_status: (data, deferred) ->
        self = data.context
        market = self.market.get_actual_market()
        self.blockchain_api.market_status(market.asset_base_symbol, market.asset_quantity_symbol).then (result) ->
            self.helper.read_market_data(self.market, result, market.assets_by_id)
            if self.market.avg_price_24h > 0
                self.market.min_short_price = market.min_short_price = self.market.avg_price_24h * 3.0 / 4.0
            else
                self.blockchain_api.get_feeds_for_asset(market.asset_base_symbol).then (result) ->
                    res = jsonPath.eval(result, "$.[?(@.delegate_name=='MARKET')].median_price")
                    if res.length > 0
                        price = if self.market.inverted then 1.0/res[0] else res[0]
                        self.market.median_price = market.median_price = price
                        self.market.min_short_price = market.min_short_price = price * 3.0 / 4.0


angular.module("app").service("MarketService", ["$q", "$interval", "$log", "$filter", "Wallet", "WalletAPI", "Blockchain",  "BlockchainAPI",  MarketService])
