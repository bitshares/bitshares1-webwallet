angular.module("app").controller "MarketsController", ($scope, $state, Wallet, Blockchain, WalletAPI, MarketService, MarketHelper, Utils, RpcService) ->
    $scope.selected_market = null
    MarketService.load_recent_markets()
    $scope.recent_markets = MarketService.recent_markets
    $scope.account_name = false
    $scope.featured_markets = []
    $scope.open_orders = []
    $scope.tx_fee_symbol = ""
    $scope.tx_fee = 0

    $scope.orderByField = "yield";
    $scope.reverseSort = true;
    $scope.orderByFieldUIA = "symbol";
    $scope.reverseSortUIA = false;

    promise = Wallet.get_current_or_first_account()
    promise.then (account)->
        $scope.account_name = account?.name
    $scope.showLoadingIndicator(promise)

    $scope.select_market = (market) ->
        $scope.selected_market = market

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            $state.go("market.buy", {name: $scope.selected_market, account: $scope.account_name})

    $scope.market_peg_assets = []
    $scope.user_issued_assets = []
    $scope.p =
        currentPage: 0
        pageSize: 20
        numberOfPages: 0
    assets_with_unknown_issuer = []

    list_open_orders = ->
        WalletAPI.account_order_list(null, 100).then (results) ->
            inverted = false
            for r in results
                td = { market: {} }
                order = r
                if r instanceof Array and r.length > 1
                    td.id = r[0]
                    order = r[1]
                if order.market_index?.order_price
                    td.market.quantity_asset = Blockchain.asset_records[order.market_index.order_price.quote_asset_id]
                    td.market.quantity_precision = td.market.quantity_asset.precision
                    bit = if td.market.quantity_asset.id > 0 and td.market.quantity_asset.id < 24 then "Bit" else ""
                    td.market.quantity_symbol = bit + td.market.quantity_asset.symbol
                    td.market.base_asset = Blockchain.asset_records[order.market_index.order_price.base_asset_id]
                    td.market.base_precision = td.market.base_asset.precision
                    bit = if td.market.base_asset.id > 0 and td.market.base_asset.id < 24 then "Bit" else ""
                    td.market.base_symbol = bit + td.market.base_asset.symbol
                    td.market.price_precision = Math.max(td.market.quantity_precision, td.market.base_precision)
                if order.type == "cover_order"
                    td.market.base_asset = Blockchain.asset_records[order.market_index.order_price.quote_asset_id]
                    MarketHelper.cover_to_trade_data(order, td.market, inverted, td)
                else
                    MarketHelper.order_to_trade_data(order, td.market.quantity_asset, td.market.base_asset, inverted, inverted, inverted, td)
                $scope.open_orders.push td

    Blockchain.refresh_asset_records().then (records) ->
        $scope.markets = Blockchain.get_markets()
        # for market, index in $scope.markets by -1
           # console.log('index:',index, 'market:',market);
            # for market2 in $scope.markets
                # if market2.issuer_id == -2 && market.symbol.toLowercase() == market2.symbol.toLowerCase()
                    # console.log('user asset:',market.symbol,'market asset:',market2.symbol)

        main_asset = Blockchain.asset_records[0]
        $scope.featured_markets.push "BitUSD:#{main_asset.symbol}"
        $scope.featured_markets.push "BitCNY:#{main_asset.symbol}"
        $scope.featured_markets.push "BitBTC:#{main_asset.symbol}"
        $scope.featured_markets.push "BitGOLD:#{main_asset.symbol}"
        $scope.featured_markets.push "BitEUR:#{main_asset.symbol}"
        $scope.featured_markets.push "BitSILVER:#{main_asset.symbol}"
        $scope.featured_markets.push "NOTE:BTS"
        $scope.featured_markets.push "BitBTC:BitUSD"
        $scope.featured_markets.push "BitBTC:BitCNY"

        for key, asset of records
            asset.currentSupply = Utils.newAsset(asset.current_supply, asset.symbol, asset.precision)
            asset.maximum_supply = Utils.newAsset(asset.max_supply, asset.symbol, asset.precision)
            asset.c_fees = Utils.newAsset(asset.collected_fees, asset.symbol, asset.precision)
            assets_with_unknown_issuer.push asset unless asset.account_name
            asset.yield = if asset.current_supply==0 then 0 else 100 * asset.collected_fees / asset.current_supply
            if asset.issuer_id > 0
                scam = false;
                for key2, asset2 of records
                    if (asset2.issuer_id == -2 and ("bit"+asset2.symbol).toLowerCase() == asset.symbol.toLowerCase())
                        scam = true
                if not scam
                    $scope.user_issued_assets.push asset
            else if asset.issuer_id == -2
                $scope.market_peg_assets.push asset
        if assets_with_unknown_issuer.length > 0
            accounts_ids = ([a.issuer_id] for a in assets_with_unknown_issuer)
            RpcService.request("batch", ["blockchain_get_account", accounts_ids]).then (response) ->
                accounts = response.result
                for i in [0...accounts.length]
                    assets_with_unknown_issuer[i].account_name = if accounts[i] then accounts[i].name else "None"
        $scope.p.numberOfPages = Math.ceil($scope.user_issued_assets.length / $scope.p.pageSize)
        tx_fee_asset = Blockchain.asset_records[0]
        $scope.tx_fee_symbol = tx_fee_asset.symbol
        WalletAPI.get_transaction_fee(tx_fee_asset.symbol).then (tx_fee) ->
            $scope.tx_fee = Utils.formatDecimal(tx_fee.amount / tx_fee_asset.precision, tx_fee_asset.precision)
        list_open_orders()

        return null

    $scope.go_to_asset = (name) ->
        $state.go("asset", {ticker: name})

    $scope.cancel_order = (id) ->
        WalletAPI.market_cancel_order(id).then (res) ->
            $scope.open_orders.splice(i, 1) for i, o of $scope.open_orders when o.id == id

    $scope.removeRecent = (m) ->
        $scope.recent_markets.splice m, 1
