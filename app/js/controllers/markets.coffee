angular.module("app").controller "MarketsController", ($scope, $state, Wallet, Blockchain, WalletAPI, MarketService) ->
    $scope.selected_market = null
    MarketService.load_recent_markets()
    $scope.recent_markets = MarketService.recent_markets
    $scope.account_name = false

    promise = Wallet.get_current_or_first_account()
    promise.then (account)->
        $scope.account_name = account?.name
    $scope.showLoadingIndicator(promise)


    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()

    $scope.select_market = (market) ->
        $scope.selected_market = market

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            $state.go("market.buy", {name: $scope.selected_market, account: $scope.account_name})
