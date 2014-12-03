angular.module("app").controller "AccountWallController", ($scope, $modal, $stateParams, BlockchainAPI, Blockchain, Utils, Wallet, WalletAPI) ->
    $scope.account_name = $stateParams.name
    $scope.burn_records = []
    $scope.burn =
        accounts: []
        symbols: []
        from: null
        amount: { value: 0, symbol: '' }
        message: null

    form = null

    BlockchainAPI.get_account_wall($scope.account_name).then (results) ->
        $scope.burn_records.splice(0, $scope.burn_records.length)
        for r in results
            asset = Blockchain.asset_records[r.amount.asset_id]
            continue until asset
            $scope.burn_records.push
                amount: Utils.formatAsset amount: r.amount.amount, precision: asset.precision, symbol: asset.symbol
                message: r.message

    Wallet.refresh_balances().then (balances) ->
        currencies = {}
        for account_name, value of balances
            $scope.burn.accounts.push(account_name)
            currencies[symbol] = true for symbol, balance of value
        $scope.burn.from = $scope.burn.accounts[0] if $scope.burn.accounts.length > 0
        $scope.burn.symbols.push c for c in Object.keys(currencies)
        $scope.burn.amount.symbol = $scope.burn.symbols[0] if $scope.burn.symbols.length > 0

    yesSend = ->
        WalletAPI.burn($scope.burn.amount.value, $scope.burn.amount.symbol, $scope.burn.from, "for", $scope.account_name, $scope.burn.message, false).then (response) ->
            $scope.burn_records.push
                amount: $scope.transfer_amount
                message: $scope.burn.message
            $scope.burn.amount.value = 0
            $scope.burn.message = ''
            form.message.$setPristine()
        ,
        (error) ->
            if (error.data.error.code == 20010)
                form.amount.$error.message = "Insufficient funds"

    $scope.post = ->
        form = @burn_form
        symbol = $scope.burn.amount.symbol
        amount_asset = Wallet.balances[$scope.burn.from][symbol]
        $scope.transfer_amount = Utils.formatDecimal($scope.burn.amount.value, amount_asset.precision) + ' ' + symbol
        WalletAPI.get_transaction_fee(symbol).then (tx_fee) ->
            transfer_asset = Blockchain.symbol2records[symbol]
            Blockchain.get_asset(tx_fee.asset_id).then (tx_fee_asset) ->
                transaction_fee = Utils.formatAsset(Utils.asset(tx_fee.amount, tx_fee_asset))
                trx = {to: $scope.account_name, amount: $scope.transfer_amount, fee: transaction_fee, memo: $scope.burn.message, vote: null}
                $modal.open
                    templateUrl: "dialog-transfer-confirmation.html"
                    controller: "DialogTransferConfirmationController"
                    resolve:
                        title: -> "Burn/Post Message Confirmation"
                        trx: -> trx
                        action: -> yesSend
                        transfer_type: ->
                            'burn'
