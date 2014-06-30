angular.module("app").filter "formatAsset", (Utils)->
    (asset) ->
        Utils.formatAsset(asset)

angular.module("app").filter "formatAccountBalance", (Blockchain, Utils) ->
    (account) ->
        result = account[0] + " | "
        balances = (Utils.formatAsset(balance) for balance in account[1])
        result + balances.join('; ')
