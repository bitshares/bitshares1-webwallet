angular.module("app").controller "AssetsController", ($scope, $location, BlockchainAPI, RpcService, Blockchain, Utils) ->

    #$scope.assets = Blockchain.assets
    #$scope.my_assets = Wallet.assets
    $scope.assets = []

    BlockchainAPI.list_assets("", -1).then (result) =>
        $scope.assets = []
        asset_ids = []
        Blockchain.refresh_asset_records().then ()->
            for i in [0 ... result.length]
                asset = result[i]
                asset_type = Blockchain.asset_records[asset.id]

                asset.current_supply = Utils.newAsset(asset.current_share_supply, asset_type.symbol, asset_type.precision)
                asset.maximum_supply = Utils.newAsset(asset.maximum_share_supply, asset_type.symbol, asset_type.precision)
                asset.c_fees = Utils.newAsset(asset.collected_fees, asset_type.symbol, asset_type.precision)
                asset_ids.push [asset.issuer_account_id]

                $scope.assets.push asset

            RpcService.request("batch", ["blockchain_get_account", asset_ids]).then (response) ->
                accounts = response.result
                for i in [0...accounts.length]
                    if accounts[i]
                        $scope.assets[i].account_name = accounts[i].name
                    else
                        $scope.assets[i].account_name = "None"
