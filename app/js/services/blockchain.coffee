servicesModule = angular.module("app.services", [])

servicesModule.factory "Blockchain", ->
    asset_records: ->
        [
            {
                symbol: "XTS",
                precision: 0.000001
            }
        ]
    formatAsset: (amount, asset_id) ->
        if (asset_id == undefined)
            asset_id = 0
        parts = amount.toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.join(".") + asset_records[asset_id]
