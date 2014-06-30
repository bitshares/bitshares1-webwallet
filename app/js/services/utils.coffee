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
        parts = (asset.amount / asset.precision).toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.join(".") + " " + asset.symbol
    
    toDate: (t) ->
        dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
        match = t.match(dateRE)
        return 0 unless match
        nums = []
        i = 1
        while i < match.length
            nums.push parseInt(match[i], 10)
            i++
        new Date(Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5]))

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
