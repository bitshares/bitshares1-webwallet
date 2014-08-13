angular.module("app").controller "MarketsController", ($scope, $state, Wallet, Blockchain, WalletAPI) ->
    $scope.selected_market = null
    recent_markets = $scope.recent_markets = []

    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()

    WalletAPI.get_setting("recent_markets").then (result) ->
        return if not result or not result.value
        recent_markets.splice(0, recent_markets.length)
        recent_markets.push r for r in JSON.parse(result.value)

    save_to_recent_markets = (market_name) ->
        index = recent_markets.indexOf(market_name)
        recent_markets.splice(index,1) if index >= 0
        recent_markets.unshift(market_name)
        recent_markets.pop() if recent_markets.length > 20
        WalletAPI.set_setting("recent_markets", JSON.stringify(recent_markets))

    $scope.select_market = (market) ->
        $scope.selected_market = market

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            Wallet.get_current_or_first_account().then (account)->
                account_name = if account then account.name else 'no:account'
                save_to_recent_markets($scope.selected_market)
                $state.go("market.buy", {name: $scope.selected_market, account: account_name})
