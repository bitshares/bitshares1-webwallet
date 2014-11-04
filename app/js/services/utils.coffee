servicesModule = angular.module("app.services")

servicesModule.factory "Utils", ($translate,$q) ->
    asset: (amount, asset_type) ->
        amount: amount
        symbol: if asset_type then asset_type.symbol else "NA"
        precision: if asset_type then asset_type.precision else 0

    newAsset: (amount, symbol, precision) ->
        amount: amount
        symbol: symbol
        precision: precision

    formatAsset: (asset) ->
        if not asset
            return ""
        amount = if asset.precision < 1.0 then asset.amount else Math.round(asset.amount)
        parts = (amount / asset.precision).toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.push('00') if parts.length == 1
        parts.join(".") + " " + asset.symbol

    formatAssetPrice: (asset) ->
        if not asset
            return ""
        amount = if asset.precision < 1.0 then asset.amount else Math.round(asset.amount)
        parts = ( amount / asset.precision).toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.push('00') if parts.length == 1
        parts[1] += '0' if parts[1].length == 1
        parts.join(".")

    formatMoney: (value) ->
        parts = value.toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.push('00') if parts.length == 1
        parts.join(".")


    truncateTrailing9s: (value) ->
        parts = (value + "").split('.')
        return value if parts.length < 2
        fractional_part = parts[1]
        return value if fractional_part.length < 7
        len = fractional_part.replace(/9*$/,'').length
        len = 10 if len > 10
        len = 1 if len == 0
        Number(value).toFixed(len)

    fractional_part_len: (value) ->
        parts = (Number(value) + "").split('.')
        return if parts.length < 2 then 0 else parts[1].length

    formatDecimal: (value, decPlaces, truncate0s = true) ->
        return "-" if value == null
        n = @truncateTrailing9s(value)
        #return n unless decPlaces
        decPlaces = decPlaces.toString().length - 1 if decPlaces > 9
        if truncate0s
           fl = @fractional_part_len(n)
           fl = 2 if fl < 2
           decPlaces = fl if fl < decPlaces
        decSeparator = "." # decSeparator = (if decSeparator is `undefined` then "." else decSeparator)
        thouSeparator = "," # thouSeparator = (if thouSeparator is `undefined` then "," else thouSeparator)
        sign = (if n < 0 then "-" else "")
        i = parseInt(n = Math.abs(+n or 0).toFixed(decPlaces)) + ""
        j = (if (j = i.length) > 3 then j % 3 else 0)
        res = sign + ((if j then i.substr(0, j) + thouSeparator else "")) + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSeparator) + ((if decPlaces then decSeparator + Math.abs(n - i).toFixed(decPlaces).slice(2) else ""))

    assetValue: (asset) ->
        return 0.0 unless asset
        asset.amount / asset.precision
    
    toDate: (t) ->
        new Date(@toUTCDate(t))

    toUTCDate: (t) ->
        dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
        match = t.match(dateRE)
        return 0 unless match
        nums = []
        i = 1
        while i < match.length
            nums.push parseInt(match[i], 10)
            i++
        Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5])

    #advance time according to interval in seconds
    advance_interval: (t, interval, j) ->
        @formatUTCDate(new Date(@toUTCDate(t) + j * interval * 1000))

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

    is_registered: (account) ->
        if account and account.registration_date == "19700101T000000"
            return false
        return true

    byteLength : (str) ->
        if !str
            return 0
        # returns the byte length of an utf8 string
        s = str.length
        i = str.length - 1

        while i >= 0
            code = str.charCodeAt(i)
            if code > 0x7f and code <= 0x7ff
                s++
            else s += 2  if code > 0x7ff and code <= 0xffff
            i--  if code >= 0xDC00 and code <= 0xDFFF #trail surrogate
            i--
        s

    formatExpirationDate : (_date) ->
        deferred = $q.defer()
        if not _date
            deferred.resolve("")
            return deferred.promise

        #_date="20141001T164450"
        date = @toDate(_date)
        diff = (date - Date.now()) / 1000.0
        #console.log _date,date,diff,date.toLocaleDateString() #20140930T191750 Tue Sep 30 2014 15:17:50 GMT-0400 (EDT) -71989.91 9/30/2014

        promise = if diff <= 0
            $translate("utils.expired")
        else if diff <= 60
            $translate("utils.seconds", {value: Math.round(diff)})
        else if diff <= 3600 # 1 hour
            $translate("utils.minutes", {value: Math.round(diff/60.0)})
        else if diff <= 24 * 3600
            $translate("utils.hours", {value: Math.round(diff/3600.0)})
        else if diff <= 30 * 24 * 3600
            $translate("utils.days", {value: Math.round(diff/3600.0/24)})
        else
            null

        if promise
            promise.catch (error) ->
                deferred.resolve(date.toLocaleDateString() + " #{error}")
            promise.then (result) ->
                deferred.resolve(result)
        else
            deferred.resolve(date.toLocaleDateString())

        deferred.promise

    too_soon_times: {}
    
    too_soon: (name, time_mills) ->
        now = Date.now()
        was = @too_soon_times[name]
        if not was or now - was > time_mills
            @too_soon_times[name] = now
            #console.log "[too_soon] #{name} false"
            return false
        else
            #console.log "[too_soon] #{name} true"
            return true

    formatAssertException: (text) ->
        match = /Assert Exception [\s\S.]+: ([\s\S.]+)/mi.exec(text)
        return if !match or match.length < 2 then text else match[1]

    formatAssertExceptionWithAssets: (text, assets) ->
        match = /Assert Exception [\s\S.]+: ([\s\S.]+)/mi.exec(text)
        return text if !match or match.length < 2
        match[1].replace /\{\"amount\":\d+\,\"asset_id\"\:\d+\}/g, (match) =>
            a = JSON.parse(match)
            asset = assets[a.asset_id]
            return match unless asset
            a.precision = asset.precision
            a.symbol = asset.symbol
            @formatAsset(a)

    select_where: (array, query) ->
        return [] if typeof query isnt "object"
        hit = Object.keys(query).length
        array.filter (item) ->
            match = 0
            for key, val of query
                match += 1 if item[key] is val
            if match is hit then true else false
