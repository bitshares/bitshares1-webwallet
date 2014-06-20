angular.module("app").controller "AssetsController", ($scope, $location, BlockchainAPI, RpcService) ->

    #$scope.assets = Blockchain.assets
    #$scope.my_assets = Wallet.assets
    $scope.assets = []

    BlockchainAPI.list_registered_assets("", -1).then (result) =>
        $scope.assets = result
        asset_ids = []
        for asset in $scope.assets
            asset_ids.push [asset.id]

        RpcService.request("batch", ["blockchain_get_account_record_by_id", asset_ids]).then (response) ->
            accounts = response.result
            for i in [0...accounts.length]
                if accounts[i]
                    $scope.assets[i].account_name = accounts[i].name
                else
                    $scope.assets[i].account_name = "None"
