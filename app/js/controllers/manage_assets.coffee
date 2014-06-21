angular.module("app").controller "ManageAssetsController", ($scope, $location, $stateParams, Growl, BlockchainAPI, RpcService) ->

    $scope.name = $stateParams.name
    $scope.create_asset =
        symbol : ""
        asset_name : ""
        description : "" 
        memo : ""
        max_share_supply : 0
        precision : 1000000

    $scope.is_registered = false
    $scope.assets = []
    $scope.my_assets = []
    $scope.my_symbols = []

    BlockchainAPI.get_account_record($scope.name).then (result) =>
        if result
            $scope.is_registered = true

    refresh_my_assets = ->
        $scope.assets = []
        $scope.my_assets = []
        $scope.my_symbols = []
        BlockchainAPI.list_registered_assets("", -1).then (result) =>
            $scope.assets = result
            asset_ids = []
            for asset in $scope.assets
                asset_ids.push [asset.issuer_account_id]

            RpcService.request("batch", ["blockchain_get_account_record_by_id", asset_ids]).then (response) ->
                accounts = response.result
                for i in [0...accounts.length]
                    if accounts[i]
                        $scope.assets[i].account_name = accounts[i].name
                    else
                        $scope.assets[i].account_name = "None"

                    if accounts[i] and accounts[i].name == $scope.name
                        $scope.my_assets.push $scope.assets[i]
                        $scope.my_symbols.push $scope.assets[i].symbol

    refresh_my_assets()

    $scope.create = ->
        console.log $scope.create_asset
        RpcService.request('wallet_asset_create', [$scope.create_asset.symbol, $scope.create_asset.asset_name, $scope.name, $scope.create_asset.description, $scope.create_asset.memo, $scope.create_asset.max_share_supply, $scope.create_asset.precision]).then (response) ->
          $scope.create_asset.symbol = ""
          $scope.create_asset.asset_name = ""
          $scope.create_asset.description = ""
          $scope.create_asset.memo = ""
          $scope.create_asset.max_share_supply = "0"
          $scope.create_asset.precision = 1000000
          Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response.result)})"
          refresh_my_assets()
