angular.module("app").controller "BlockTransactionsController", ($scope, $location, $stateParams, $state, BlockchainAPI, Utils) ->

    $scope.transactions = []
    $scope.utils = Utils
    
    BlockchainAPI.get_block($stateParams.number).then (result) ->
        transactions = []
