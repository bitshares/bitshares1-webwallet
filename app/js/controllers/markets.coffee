angular.module("app").controller "MarketsController", ($scope, $state, Wallet, Blockchain, WalletAPI, MarketService, Utils) ->
    $scope.selected_market = null
    MarketService.load_recent_markets()
    $scope.recent_markets = MarketService.recent_markets
    $scope.account_name = false
    $scope.featured_markets = []

    promise = Wallet.get_current_or_first_account()
    promise.then (account)->
        $scope.account_name = account?.name
    $scope.showLoadingIndicator(promise)

    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()
        Blockchain.get_asset(0).then (main_asset) ->
            $scope.featured_markets.push "BitUSD:#{main_asset.symbol}"
            $scope.featured_markets.push "BitCNY:#{main_asset.symbol}"
            $scope.featured_markets.push "BitBTC:#{main_asset.symbol}"
            $scope.featured_markets.push "BitGOLD:#{main_asset.symbol}"
            $scope.featured_markets.push "BitEUR:#{main_asset.symbol}"

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
    Blockchain.refresh_asset_records().then (records)->
        for key, asset of records
            asset.current_supply = Utils.newAsset(asset.current_share_supply, asset.symbol, asset.precision)
            asset.maximum_supply = Utils.newAsset(asset.maximum_share_supply, asset.symbol, asset.precision)
            asset.c_fees = Utils.newAsset(asset.collected_fees, asset.symbol, asset.precision)
            assets_with_unknown_issuer.push asset unless asset.account_name
            if asset.issuer_account_id > 0
                $scope.user_issued_assets.push asset
            else
                $scope.market_peg_assets.push asset
        if assets_with_unknown_issuer.length > 0
            accounts_ids = ([a.issuer_account_id] for a in assets_with_unknown_issuer)
            RpcService.request("batch", ["blockchain_get_account", accounts_ids]).then (response) ->
                accounts = response.result
                for i in [0...accounts.length]
                    assets_with_unknown_issuer[i].account_name = if accounts[i] then accounts[i].name else "None"
        $scope.p.numberOfPages = Math.ceil($scope.user_issued_assets.length / $scope.p.pageSize)
        return null

    $scope.go_to_asset = (name) ->
        $state.go("asset", {ticker: name})
