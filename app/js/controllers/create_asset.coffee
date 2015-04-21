angular.module("app").controller "CreateAssetController", ($scope, $location, $stateParams, $modal, Growl, BlockchainAPI, RpcService, Utils, Info, Blockchain, WalletAPI) ->
    $scope.name = $stateParams.name
    $scope.reg_fee =
        symbol: ''
        short: 0
        long: 0
        current: 0

    Info.refresh_info().then ->
        Blockchain.get_asset(0).then (v)->
            $scope.asset_reg_fee = Utils.formatAsset(Utils.asset(Info.info.asset_reg_fee, v))

    $scope.create_asset =
        symbol: ""
        name: ""
        description: ""
        memo: ""
        max_supply: "100,000,000"
        current_supply: 0
        precision: "1,000,000"
        issuer: $scope.name

    # TODO validate that this symbol has not already been created
    $scope.is_valid_symbol = (value) ->
        return true unless value
        return false unless angular.isString value
        value = value.split '.'
        scam_pattern = /^BIT/
        pattern = /^([A-Z]{3,8})$/
        if value.length == 1
            return !!value[0].match(pattern) and not !!value[0].match(scam_pattern)
        else if value.length == 2
            rest = 12-(value[0].length+1)
            pattern2 = new RegExp('^([A-Z]{3,'+rest+'})$');
            return !!value[0].match(pattern) and !!value[1].match(pattern2)


    $scope.create = ->
        form = @create_asset_form
        asset = $scope.create_asset
        asset.fee = $scope.reg_fee.current
        asset.fee_symbol = $scope.reg_fee.symbol
        @create_asset_form.$error.message = null
        max_supply = Utils.parseInt($scope.create_asset.max_supply)
        precision = Utils.parseInt($scope.create_asset.precision)
        if max_supply * precision > 1000000000000000
            @create_asset_form.$error.message = "You need to specify a lower precision or fewer shares."
            return
        $modal.open
            templateUrl: "dialog-asset-confirmation.html"
            controller: "DialogWithDataController"
            resolve:
                data: -> asset
                action: ->
                    ->
                        WalletAPI.asset_create(asset.symbol, asset.name, $scope.name, asset.description, max_supply, precision, asset.memo, false).then (response) ->
                            Growl.notice "", "Asset '#{asset.symbol}' was created"
                            copy = angular.copy(asset)
                            copy.registration_date = new Date()
                            copy.max_supply = max_supply * precision
                            copy.precision = precision
                            $scope.add_asset(copy)
                            $scope.create_asset.symbol = ""
                            $scope.create_asset.name = ""
                            $scope.create_asset.description = ""
                            $scope.create_asset.memo = ""
                            $scope.create_asset.max_supply = "100,000,000"
                            $scope.create_asset.precision = "1,000,000"
                            $scope.clear_form_errors(form)

    $scope.utils = Utils

    Blockchain.get_info().then (data) ->
        Blockchain.get_asset(0).then (asset) ->
            $scope.reg_fee.symbol = asset.symbol
            $scope.reg_fee.short = data.short_symbol_asset_reg_fee / asset.precision
            $scope.reg_fee.long = data.long_symbol_asset_reg_fee / asset.precision

    $scope.symbol_changed = ->
        return if not $scope.create_asset.symbol
        $scope.reg_fee.current = if $scope.create_asset.symbol.length < 6 then $scope.reg_fee.short else $scope.reg_fee.long