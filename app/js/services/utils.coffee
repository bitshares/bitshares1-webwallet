servicesModule = angular.module("app.services")

servicesModule.factory "Utils", ->

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
