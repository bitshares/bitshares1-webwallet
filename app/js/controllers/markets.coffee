angular.module("app").controller "MarketsController", ($scope, $location, Blockchain) ->
    $scope.selected_market = null

    Blockchain.refresh_asset_records().then ->
        $scope.markets = Blockchain.get_markets()

    $scope.$watch 'selected_market', (newMarket, oldMarket) ->
        if newMarket and newMarket != oldMarket
            #$scope.current_market = newMarket
            $location.path("market/" + $scope.selected_market.replace('/',':') + "/no:account")
