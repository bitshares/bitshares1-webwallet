angular.module("app").controller "AccountWallController", ($scope, $modal, $stateParams, BlockchainAPI, Blockchain, Utils, Wallet, WalletAPI) ->
    $scope.account_name = $stateParams.name
    $scope.burn_records = []
    $scope.burn =
        accounts: []
        symbols: []
        symbol: null
        from: null
        amount: null
        message: null

    BlockchainAPI.get_account_wall($scope.account_name).then (results) ->
        $scope.burn_records.splice(0, $scope.burn_records.length)
        for r in results
            asset = Blockchain.asset_records[r.amount.asset_id]
            continue until asset
            $scope.burn_records.push
                amount: Utils.formatAsset amount: r.amount.amount, precision: asset.precision, symbol: asset.symbol
                message: r.message

    Wallet.refresh_balances().then (balances) ->
        console.log "------ Wallet.balances 1 ------>", $scope.burn, balances
        currencies = {}
        for account_name, value of balances
            $scope.burn.accounts.push(account_name)
            currencies[symbol] = true for symbol, balance of value
        $scope.burn.from = $scope.burn.accounts[0] if $scope.burn.accounts.length > 0
        $scope.burn.symbols.push c for c in Object.keys(currencies)
        $scope.burn.symbols.push "XRP"
        $scope.burn.symbol = $scope.burn.symbols[0] if $scope.burn.symbols.length > 0
        console.log "------ Wallet.balances 2 ------>", $scope.burn

    $scope.post = ->
        form = @burn_form
        #my_transfer_form.amount.error_message = null
        #my_transfer_form.payto.error_message = null
        amount_asset = Wallet.balances[$scope.burn.symbol]
        transfer_amount = Utils.formatDecimal($scope.burn.amount, amount_asset.precision)
        WalletAPI.get_transaction_fee($scope.burn.symbol).then (tx_fee) ->
            transfer_asset = Blockchain.symbol2records[$scope.burn.symbol]
            Blockchain.get_asset(tx_fee.asset_id).then (tx_fee_asset) ->
                transaction_fee = Utils.formatAsset(Utils.asset(tx_fee.amount, tx_fee_asset))
                trx = {to: $scope.account_name, amount: transfer_amount + ' ' + $scope.burn.symbol, fee: transaction_fee, memo: $scope.burn.message, vote: null}
                $modal.open
                    templateUrl: "dialog-transfer-confirmation.html"
                    controller: "DialogTransferConfirmationController"
                    resolve:
                        title: -> "Transfer Authorization"
                        trx: -> trx
                        action: -> yesSend
                        xts_transfer: ->
                            $scope.burn.symbol == 'XTS' || $scope.burn.symbol == 'BTS'
