angular.module("app").filter "formatAsset", (Utils)->
    (asset) ->
        Utils.formatAsset(asset)

# Example convert {"amount":500000, "asset_id": 0} to asset object can using formatAsset  
angular.module("app").filter "toAsset", (Blockchain, Utils) ->
    (asset) ->
        asset_type = Blockchain.asset_records[asset.asset_id]
        Utils.newAsset(asset.amount, asset_type.symbol, asset_type.precision)

angular.module("app").filter "formatAccountBalance", (Blockchain, Utils) ->
    (account) ->
        result = account[0] + " | "
        balances = (Utils.formatAsset(Utils.newAsset(balance[1], balance[0], Blockchain.symbol2records[balance[0]].precision)) for balance in account[1])
        result + balances.join('; ')
