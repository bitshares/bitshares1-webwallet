angular.module("app").controller "AssetController", ($scope, BlockchainAPI, Blockchain, $stateParams) ->
    $scope.feeds=[]
    $scope.symbol2records={}
    $scope.ticker = $stateParams.ticker.toUpperCase()

    $scope.$watch ->
        Blockchain.symbol2records
    , ->
        $scope.symbol2records=Blockchain.symbol2records

    Blockchain.refresh_asset_records()

    BlockchainAPI.get_feeds_for_asset($scope.ticker).then (result) ->
        $scope.feeds=result