servicesModule = angular.module("app.services")

servicesModule.factory "Utils", ->
    asset: (amount, asset_type) ->
        amount: amount
        symbol: asset_type.symbol
        precision: asset_type.precision

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
        len = 1 if len == 0
        value.toFixed(len)

    formatDecimal: (value, decPlaces) ->
        n = @truncateTrailing9s(value)
        return n unless decPlaces
        decPlaces = decPlaces.toString().length - 1 if decPlaces > 9
        decSeparator = "." # decSeparator = (if decSeparator is `undefined` then "." else decSeparator)
        thouSeparator = "," # thouSeparator = (if thouSeparator is `undefined` then "," else thouSeparator)
        sign = (if n < 0 then "-" else "")
        i = parseInt(n = Math.abs(+n or 0).toFixed(decPlaces)) + ""
        j = (if (j = i.length) > 3 then j % 3 else 0)
        sign + ((if j then i.substr(0, j) + thouSeparator else "")) + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSeparator) + ((if decPlaces then decSeparator + Math.abs(n - i).toFixed(decPlaces).slice(2) else ""))

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
