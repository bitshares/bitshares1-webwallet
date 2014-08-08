angular.module("app").controller "AccountDelegatePriceFeeds", ($scope, BlockchainAPI) ->
    $scope.feeds=[]
    BlockchainAPI.blockchain_get_feeds_from_delegate($scope.name).then (result) ->
        console.log(result)