angular.module("app").controller "CreateAssetController", ($scope, $location, $stateParams, $modal, Growl, BlockchainAPI, RpcService, Utils, Info, Blockchain, Wallet) ->

    $scope.name = $stateParams.name
    $scope.asset_reg_fee = Info.info.asset_reg_fee
    $scope.create_asset =
        symbol : ""
        asset_name : ""
        description : ""
        memo : ""
        max_share_supply : 1000000000000000
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
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will create asset " + $scope.create_asset.symbol + " with max supply " + $scope.create_asset.max_share_supply + " and precision " + $scope.create_asset.precision + ".\n This will cost you " + $scope.asset_reg_fee + "."
                action: ->
                    ->
                        RpcService.request('wallet_asset_create', [$scope.create_asset.symbol, $scope.create_asset.asset_name, $scope.name, $scope.create_asset.description, $scope.create_asset.memo, $scope.create_asset.max_share_supply, $scope.create_asset.precision]).then (response) ->
                          $scope.create_asset.symbol = ""
                          $scope.create_asset.asset_name = ""
                          $scope.create_asset.description = ""
                          $scope.create_asset.memo = ""
                          $scope.create_asset.max_share_supply = 1000000000000000
                          $scope.create_asset.precision = 1000000
                          Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response.result)})"
                          Wallet.refresh_transactions_on_update()

    $scope.utils = Utils

    Blockchain.get_config().then (config) ->
        $scope.memo_size_max = config.memo_size_max

