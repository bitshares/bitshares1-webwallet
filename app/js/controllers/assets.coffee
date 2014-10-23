angular.module("app").controller "AssetsController", ($scope, $location, BlockchainAPI, RpcService, Blockchain, Utils) ->
    $scope.assets = []
    assets_with_unknown_issuer = []
    Blockchain.refresh_asset_records().then (records)->
        for key, asset of records
            asset.current_supply = Utils.newAsset(asset.current_share_supply, asset.symbol, asset.precision)
            asset.maximum_supply = Utils.newAsset(asset.maximum_share_supply, asset.symbol, asset.precision)
            asset.c_fees = Utils.newAsset(asset.collected_fees, asset.symbol, asset.precision)
            assets_with_unknown_issuer.push asset unless asset.account_name
            $scope.assets.push asset
        if assets_with_unknown_issuer.length > 0
            accounts_ids = ([a.issuer_account_id] for a in assets_with_unknown_issuer)
            RpcService.request("batch", ["blockchain_get_account", accounts_ids]).then (response) ->
                accounts = response.result
                for i in [0...accounts.length]
                    assets_with_unknown_issuer[i].account_name = if accounts[i] then accounts[i].name else "None"
        return null