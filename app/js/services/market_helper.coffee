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
        ba = assets[data.index.base_id]

        actual_market.bid_depth = data.ask_depth / ba.precision
        actual_market.ask_depth = data.bid_depth / ba.precision
        actual_market.feed_price = parseFloat(data.current_feed_price)
        actual_market.shorts_price = actual_market.feed_price

        if inverted
            market.bid_depth = data.ask_depth / ba.precision
            market.ask_depth = data.bid_depth / ba.precision
            market.feed_price = 1.0 / data.current_feed_price if data.current_feed_price
            market.shorts_price = 1.0 / data.current_feed_price if data.current_feed_price

        #console.log "------ read_market_data ------>", market.shorts_price, data, assets

        if data.last_error
            actual_market.error.title = market.error.title = data.last_error.message
        else
            actual_market.error.text = market.error.text = market.error.title = null

    order_price: (order_price, asset1, asset2) ->
        quote_asset = if order_price.quote_asset_id == asset1.id then asset1 else asset2
        base_asset = if order_price.base_asset_id == asset1.id then asset1 else asset2
        order_price.ratio * (base_asset.precision / quote_asset.precision)

    order_to_trade_data: (order, base_asset, quantity_asset, invert_price, invert_assets, invert_order_type, td) ->
        td.id = order.market_index.owner unless td.id
        td.type = if invert_order_type then @invert_order_type(order.type) else order.type
        td.uid = @utils.hashString order.market_index.owner + order.market_index.order_price.ratio + order.state.last_update
        price = @order_price(order.market_index.order_price, base_asset, quantity_asset)
        td.price = if invert_price and price > 0.0 then 1.0 / price else price

        td.interest_rate = order.interest_rate.ratio * 100.0 if order.interest_rate

        td.quantity = order.state.balance / quantity_asset.precision
        td.cost = td.quantity * price
        if order.expiration
            @utils.formatExpirationDate(order.expiration).then (result) ->
                td.expiration = {days: result, timestamp: order.expiration}

        td.status = "posted"
        if order.type == "bid_order"
            td.cost = order.state.balance / base_asset.precision
            td.quantity = td.cost / price if price > 0.0
        else if order.type == "short_order"
            td.collateral = order.state.balance / quantity_asset.precision
            if order.state.limit_price and order.state.limit_price.ratio > 0.0
                short_price_limit =  @order_price(order.state.limit_price, base_asset, quantity_asset)
                td.short_price_limit = if invert_price then 1.0 / short_price_limit else short_price_limit
            else
                td.short_price_limit = null

        if invert_assets
            [td.cost, td.quantity] = [td.quantity, td.cost]

        td.display_type = @capitalize(td.type.split("_")[0])

    cover_to_trade_data: (order, market, invert_price, td) ->
        td.id = order.market_index.owner unless td.id
        td.uid = @utils.hashString order.market_index.owner + order.market_index.order_price.ratio  + order.state.last_update
        td.type = "margin_order"
        td.display_type = "Margin Order"
        td.status = "cover"
        price = @order_price(order.market_index.order_price, market.base_asset, market.quantity_asset)
        td.price = if invert_price and price > 0.0 then 1.0 / price else price
        td.interest_rate = order.interest_rate.ratio * 100.0
        td.collateral = order.collateral / market.quantity_asset.precision
        td.cost = order.state.balance / market.base_asset.precision
        td.expiration = order.expiration
        if td.expiration
            @utils.formatExpirationDate(td.expiration).then (result) ->
                td.expiration = {days: result, timestamp: td.expiration}

    trade_history_to_order: (t, o, assets, invert_price) ->
        ask_price = t.ask_price or t.ask_index.order_price
        ba = assets[ask_price.base_asset_id]
        qa = assets[ask_price.quote_asset_id]
        o.type = t.bid_type
        o.id = t.ask_owner+t.bid_owner
        o.price = ask_price.ratio * (ba.precision / qa.precision)
        o.price = 1.0 / o.price if invert_price
        o.paid = t.ask_paid.amount / ba.precision
        o.received = t.ask_received.amount / qa.precision
        o.timestamp = @filter('prettySortableTime')(t.timestamp)
        o.uid = @utils.hashString "#{t.bid_index.owner}#{t.timestamp}#{t.ask_received.amount}#{t.ask_index.owner}#{t.bid_received.amount}"
        o.display_type = @capitalize(o.type.split("_")[0])

    array_to_hash: (list) ->
        hash = {}
        for i, v of list
            v.index = i
            hash[v.uid] = v
        return hash

    update_array: (params, type) ->
        target = params.target
        data = params.data
        target_hash = @array_to_hash(target)
        data_hash = @array_to_hash(data)

        for i, dv of data
            tv = target_hash[dv.uid]
            if tv
                if params.update
                    params.update(tv,dv)
                else if tv.update
                    tv.update(dv)
                else
                    throw "no update callback provided"
            else
                target.push dv
        for i, tv of target
            if !data_hash[tv.uid]
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

    find_by_id: (array, id) ->
        for a in array
            return a if a.id == id
        return null

    date: (t) ->
        dateRE = /(\d\d\d\d)\-(\d\d)\-(\d\d)T(\d\d)\:(\d\d)\:(\d\d)/
        match = t.match(dateRE)
        unless match
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
        return "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}"
        
    is_in_short_wall: (short, shorts_price, inverted) ->
        return true if !short.short_price_limit or short.short_price_limit == 0.0
        return (not inverted and short.short_price_limit > shorts_price) or (inverted and short.short_price_limit < shorts_price)

    to_float: (value) ->
        return null if value is undefined or value is null
        str_value = value+""
        return null unless /^[\d\.\,\+]+$/.test(str_value)
        if str_value.indexOf(",") > -1
            return parseFloat str_value.replace(/,/g, "")
        return parseFloat value

    flatten_orderbookchart: (array, sumBoolean, inverse, precision) ->
        inverse = if inverse == undefined then false else inverse;
        orderBookArray = [];
        if inverse
            if array.length > 1
                array.sort (a, b) ->
                    a[0] - b[0]

            if array and array.length
                arrayLength = array.length - 1;
                orderBookArray.unshift([array[arrayLength][0], array[arrayLength][1]])
                if array.length > 1
                    for i in [array.length-2...0]
                        maxStep = Math.min((array[i + 1][0] - array[i][0] ) / 2, 0.1 / precision)
                        orderBookArray.unshift([array[i][0] + maxStep, array[i + 1][1]])
                        if (sumBoolean) 
                            array[i][1] += array[i - 1][1]                        
                        orderBookArray.unshift([array[i][0], array[i][1]])
                else
                    orderBookArray.unshift([0, array[arrayLength][1]])

        else 
            if array and array.length
                orderBookArray.push([array[0][0], array[0][1]])
                if array.length > 1
                    for i in [1...array.length]
                        maxStep = Math.min((array[i][0] - array[i - 1][0]) / 2, 0.1 / precision)
                        orderBookArray.push([array[i][0] - maxStep, array[i - 1][1]])
                        if (sumBoolean) 
                            array[i][1] += array[i - 1][1]                        
                        orderBookArray.push([array[i][0], array[i][1]])     
                else
                    orderBookArray.push([array[0][0]*1.5, array[0][1]])                     

        orderBookArray

    split_price: (price, market, inverted) ->
        price_string = null
        
        if inverted
            decPlaces = if market.base_precision > 9 then market.base_precision.toString().length - 1 else 2 
        else 
            decPlaces = if market.price_precision > 9 then market.price_precision.toString().length - 1 else 2 

        price_string = @filter('number')(price,decPlaces).split(".")

        return price_string   

    filter_quantity: (quantity, market, inverted) ->
        # console.log market, inverted
        if inverted
            decPlaces = if market.base_precision > 9 then market.base_precision.toString().length - 1 else 2 
        else
            decPlaces = if market.quantity_precision > 9 then market.quantity_precision.toString().length - 1 else 2 

        price_string = @filter('number')(quantity,decPlaces)
        # else 
            # decPlaces = if market.price_precision > 9 then market.price_precision.toString().length - 1 else 2 
            # price_string = price.toFixed(decPlaces).split(".")

    parse_memo: (memo, amount, market) ->
        price = null;
        parsed_memo = memo.split(" ")
        type = parsed_memo[0]
       
        if not market.inverted
            price = parseFloat parsed_memo[3]
            if type == "sell"
                amount *= price
            else if type == "buy"
                amount /= price
        else
            price = 1 / parsed_memo[3]
            if type == "sell"
                type = "buy"
                amount /= price
            else if type == "buy"
                type = "sell"
                amount *= price

        price_string = @utils.formatDecimal(price,market.price_precision).split(".")
        
        if (type == "sell" and market.actual_market) or (type == "buy" and !market.actual_market)
            if market.inverted
                quantity = @utils.formatDecimal(amount, market.base_asset.precision) + ' ' + market.asset_base_symbol
            else
                quantity = @utils.formatDecimal(amount, market.quantity_asset.precision) + ' ' + market.asset_quantity_symbol
        else if (type == "buy" and market.actual_market) or (type == "sell" and !market.actual_market)
            if market.inverted
                quantity = @utils.formatDecimal(amount, market.quantity_asset.precision) + ' ' + market.asset_quantity_symbol
            else
                quantity = @utils.formatDecimal(amount, market.base_asset.precision) + ' ' + market.asset_base_symbol

        return {
            quantity: quantity
            base_asset: parsed_memo[1]
            quote_asset: parsed_memo[4]
            price: price
            type: type
            price_int: price_string[0]
            price_dec: price_string[1]
            }

    removeDuplicates: (array, limit) =>
        duplicates = false
        uids = {}

        array.forEach (entry, index) ->
            if index < limit
                if not uids[entry.uid] 
                    uids[entry.uid] = true;
                else
                    entry.uid += 1
                    duplicates = true
        return {array: array, duplicates: duplicates}



angular.module("app").service("MarketHelper", ["$filter", "Utils",  MarketHelper])
