class MarketHelper

    filter: null
    utils: null

    constructor: (@filter, @utils) ->

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
        return 0.0 if !value or (value.base_asset_id == 0 and value.quote_asset_id == 0)
        ba = assets[value.base_asset_id]
        qa = assets[value.quote_asset_id]
        return value.ratio * (ba.precision / qa.precision)

    read_market_data: (market, data, assets, inverted) ->
        actual_market = market.get_actual_market()
        ba = assets[data.base_id]

        actual_market.bid_depth = data.ask_depth / ba.precision
        actual_market.ask_depth = data.bid_depth / ba.precision
        actual_market.feed_price = data.center_price
        actual_market.shorts_price = data.center_price

        if inverted
            market.bid_depth = data.ask_depth / ba.precision
            market.ask_depth = data.bid_depth / ba.precision
            market.feed_price = 1.0 / data.center_price if data.center_price
            market.shorts_price = 1.0 / data.center_price if data.center_price

        #console.log "------ read_market_data ------>", market.shorts_price, data, assets

        if data.last_error
            actual_market.error.title = market.error.title = data.last_error.message
        else
            actual_market.error.text = market.error.text = market.error.title = null


    order_to_trade_data: (order, base_asset, quantity_asset, invert_price, invert_assets, invert_order_type, td) ->
        #console.log order
        #td = new TradeData()
        if order instanceof Array and order.length > 1
            td.id = order[0]
            order = order[1]
        else
            td.id = order.market_index.owner
        td.type = if invert_order_type then @invert_order_type(order.type) else order.type

        # calc order price
        price_quote_asset = if order.market_index.order_price.quote_asset_id == base_asset.id then base_asset else quantity_asset
        price_base_asset = if order.market_index.order_price.base_asset_id == base_asset.id then base_asset else quantity_asset
        price = order.market_index.order_price.ratio * (price_base_asset.precision / price_quote_asset.precision)
        td.price = if invert_price and price > 0.0 then 1.0 / price else price

        td.quantity = order.state.balance / quantity_asset.precision
        td.cost = td.quantity * price
        if order.expiration
            @utils.formatExpirationDate(order.expiration).then (result) ->
                td.expiration_days = result

        td.status = "posted"
        if order.type == "cover_order"
            #cover_price = 1.0 / price
            td.cost = order.state.balance / base_asset.precision
            td.quantity = -1.0 #td.cost * cover_price
            td.collateral = order.collateral / quantity_asset.precision
            td.type = "margin_order"
            td.status = "cover"
        else if order.type == "bid_order"
            td.cost = order.state.balance / base_asset.precision
            td.quantity = td.cost / price if price > 0.0
        else if order.type == "short_order"
            td.collateral_ratio = 1.0/price
            pl = order.state.short_price_limit
            if pl
                short_price_limit = pl.ratio * (quantity_asset.precision / base_asset.precision)
                td.short_price_limit = if invert_price and short_price_limit > 0.0 then 1.0 / short_price_limit else short_price_limit

        if invert_assets
            [td.cost, td.quantity] = [td.quantity, td.cost]

        td.display_type = @capitalize(td.type.split("_")[0])

    trade_history_to_order: (t, assets, invert_price) ->
        ba = assets[t.ask_price.base_asset_id]
        qa = assets[t.ask_price.quote_asset_id]
        o = {type: t.bid_type}
        o.id = t.ask_owner
        o.price = t.ask_price.ratio * (ba.precision / qa.precision)
        o.price = 1.0 / o.price if invert_price
        o.paid = t.ask_paid.amount / ba.precision
        o.received = t.ask_received.amount / qa.precision
        o.timestamp = @filter('prettyDate')(t.timestamp)
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
                if params.update
                    params.update(tv,dv)
                else if tv.update
                    tv.update(dv)
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

    sort_array: (array, field, field2, reverse = false, sort_callback = null) ->
         array.sort (a, b) ->
            if sort_callback
                res = sort_callback(a,b)
                return unless res == 0
            a = a[field]
            b = b[field]
            a2 = a[field2]
            b2 = b[field2]
            if (a == b)
                return if reverse then b2-a2 else a2-b2
            return if reverse then b - a else a - b

    add_to_order_book_chart_array: (array, price, volume) ->
        if array.length == 0
            array.push [price, volume]
        else
            last_element = array[array.length - 1]
            if last_element[0] == price
                last_element[1] = volume
            else
              array.push [price, volume]

    invert_order_type: (type) ->
        return "ask_order" if type == "bid_order"
        return "bid_order" if type == "ask_order"
        return type

    find_order_by_transaction: (orders, t) ->
#        res = jsonPath.eval(t, "$.ledger_entries[0].to_account")
#        return null if not res or res.length == 0
#        to_account = res[0]
#        match = /^([A-Z]+)\-(\w+)/.exec(to_account)
#        return null unless match
#        subid = match[2]
#        return null unless subid.length > 5
#        for o in orders
#            return o if o.id and o.id.indexOf(subid) > -1
        for o in orders
            return o if o.id == t.trx_id
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

    formatUTCDate: (date) ->
        year = date.getUTCFullYear()
        month = @forceTwoDigits(date.getUTCMonth()+1)
        day = @forceTwoDigits(date.getUTCDate())
        hour = @forceTwoDigits(date.getUTCHours())
        minute = @forceTwoDigits(date.getUTCMinutes())
        second = @forceTwoDigits(date.getUTCSeconds())
        return "#{year}#{month}#{day}T#{hour}#{minute}#{second}"
        
    is_in_short_wall: (short, shorts_price, inverted) ->
        short_collateral_ratio_condition = (not inverted and short.price < shorts_price) or (inverted and short.price > shorts_price)
        short_price_limit_condition = true
        if short.short_price_limit
            short_price_limit_condition = (not inverted and short.short_price_limit > shorts_price) or (inverted and short.short_price_limit < shorts_price)
        return short_collateral_ratio_condition and short_price_limit_condition

    to_float: (value) ->
        return null if value is undefined or value is null
        str_value = value+""
        return null unless /^[\d\.\,\+]+$/.test(str_value)
        if str_value.indexOf(",") > -1
            return parseFloat str_value.replace(/,/g, "")
        return parseFloat value

angular.module("app").service("MarketHelper", ["$filter", "Utils",  MarketHelper])
