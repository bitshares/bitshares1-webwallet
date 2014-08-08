angular.module("app").controller "AssetController", ($scope, BlockchainAPI, Blockchain, $stateParams, Utils) ->
    $scope.feeds=[]
    $scope.symbol2records=Blockchain.symbol2records
    $scope.ticker = $stateParams.ticker.toUpperCase()
    $scope.Utils = Utils
    $scope.issuer =''


    Blockchain.refresh_asset_records().then ->
        $scope.symbol2records=Blockchain.symbol2records
        console.log($scope.ticker)
        console.log($scope.symbol2records)
        if($scope.symbol2records[$scope.ticker].issuer_account_id != -2)
            BlockchainAPI.get_account($scope.symbol2records[$scope.ticker].issuer_account_id).then (result) ->
                $scope.issuer = result
        

    BlockchainAPI.get_feeds_for_asset($scope.ticker).then (result) ->
        $scope.feeds=result

    