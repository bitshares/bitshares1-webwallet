angular.module("app").filter "formatAsset", (Utils)->
    (asset) ->
        Utils.formatAsset(asset)
