angular.module("app").filter "formatAsset", (Utils)->
    (asset) ->
        Utils.formatAsset(asset)

# Example convert {"amount":500000, "asset_id": 0} to asset object can using formatAsset  
angular.module("app").filter "toAsset", (Blockchain, Utils) ->
    (asset) ->
        console.log Blockchain.asset_records
        asset_type = Blockchain.asset_records[asset.asset_id]
        console.log asset_type
        Utils.newAsset(asset.amount, asset_type.symbol, asset_type.precision)
