angular.module("app").controller "MarketsController", ($scope, $location, Wallet, Blockchain) ->
    $scope.selected_market = null

    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            Wallet.get_current_or_first_account().then (account)->
                account_name = if account then account.name else 'no:account'
                $location.path("market/#{$scope.selected_market}/#{account_name}/buy")
