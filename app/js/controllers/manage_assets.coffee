angular.module("app").controller "ManageAssetsController", ($scope, $location, $stateParams, Growl, BlockchainAPI, RpcService, Blockchain, Info, Utils, WalletAPI) ->
    $scope.name = $stateParams.name

    $scope.is_registered = false
    $scope.assets = []
    assets_by_id = {}

    BlockchainAPI.get_account($scope.name).then (result) ->
        $scope.is_registered = !!result

    WalletAPI.get_account($scope.name).then (result) ->
        account_id = result.id
        Blockchain.refresh_asset_records().then ->
            angular.forEach Blockchain.asset_records, (asset) ->
                if asset.issuer_account_id == account_id and not assets_by_id[asset.id]
                    assets_by_id[asset.id] = asset
                    $scope.assets.push asset

    $scope.add_asset = (asset) ->
        $scope.assets.push asset
