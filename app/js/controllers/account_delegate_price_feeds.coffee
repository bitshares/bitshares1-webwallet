angular.module("app").controller "AccountDelegatePriceFeeds", ($scope, BlockchainAPI, Blockchain) ->
    $scope.feeds=[]
    $scope.symbol2records={}

    $scope.$watch ->
        Blockchain.symbol2records
    , ->
        $scope.symbol2records=Blockchain.symbol2records

    console.log('Blockchain.asset_records', Blockchain.asset_records)
    console.log('Blockchain.symbol2records', Blockchain.symbol2records)
    BlockchainAPI.get_feeds_from_delegate($scope.account_name).then (result) ->
        $scope.feeds=result