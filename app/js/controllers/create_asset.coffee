angular.module("app").controller "CreateAssetController", ($scope, $location, $stateParams, $modal, Growl, BlockchainAPI, RpcService, Utils, Info, Blockchain, Wallet) ->

    $scope.name = $stateParams.name

    Info.refresh_info().then ->
        Blockchain.get_asset(0).then (v)->
            $scope.asset_reg_fee = Utils.formatAsset(Utils.asset(Info.info.asset_reg_fee, v))

            $scope.create_asset =
                symbol : ""
                asset_name : ""
                description : ""
                memo : ""
                max_share_supply : 100000000
                precision : 1000000

            # TODO validate that this symbol has not already been created
            $scope.is_valid_symbol = (value) ->
                if !angular.isString value
                    return false

                pattern = /// ^
                    ([A-Z0-9]{3,5})     # Only uppercase or number, 3-5 characters
                $ ///

                if value.match pattern
                    true
                else
                    false

            $scope.create = ->
                if $scope.create_asset.max_share_supply * $scope.create_asset.precision > 1000000000000000
                    Growl.error "", "You need to specify a lower precision or fewer shares."
                    return
                data=
                  # title: 'Asset Creation Authorization'
                  symbol: $scope.create_asset.symbol
                  name: $scope.create_asset.asset_name
                  description: $scope.create_asset.description
                  supply:$scope.create_asset.max_share_supply.toFixed($scope.create_asset.precision.toString().length-1)
                  issuer: $scope.name
                  fee: $scope.asset_reg_fee
                  memo: $scope.create_asset.memo
                $modal.open
                    templateUrl: "dialog-asset-confirmation.html"
                    controller: "DialogWithDataController"
                    resolve:
                        data: -> data
                        action: ->
                            ->
                                RpcService.request('wallet_asset_create', [$scope.create_asset.symbol, $scope.create_asset.asset_name, $scope.name, $scope.create_asset.description, $scope.create_asset.memo, $scope.create_asset.max_share_supply, $scope.create_asset.precision]).then (response) ->
                                  $scope.create_asset.symbol = ""
                                  $scope.create_asset.asset_name = ""
                                  $scope.create_asset.description = ""
                                  $scope.create_asset.memo = ""
                                  $scope.create_asset.max_share_supply = 100000000
                                  $scope.create_asset.precision = 1000000
                                  Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response.result)})"
                                  Wallet.refresh_transactions_on_update()

    $scope.utils = Utils

    Blockchain.get_info().then (config) ->
        $scope.memo_size_max = config.memo_size_max

