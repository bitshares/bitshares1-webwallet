angular.module("app").controller "MarketsController", ($scope, $state, Wallet, Blockchain, WalletAPI, MarketService) ->
    $scope.selected_market = null
    MarketService.load_recent_markets()
    $scope.recent_markets = MarketService.recent_markets

    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()

    $scope.select_market = (market) ->
        $scope.selected_market = market

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            Wallet.get_current_or_first_account().then (account)->
                account_name = if account then account.name else 'no:account'
                $state.go("market.buy", {name: $scope.selected_market, account: account_name})
