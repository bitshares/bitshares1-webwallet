angular.module("app").controller "BlockController", ($scope, $location, $stateParams, $state, BlockchainAPI, Utils) ->
    
    $scope.number = $stateParams.number

    BlockchainAPI.blockchain_get_block_by_number($scope.number).then (result) ->
        $scope.block = result
        $scope.block.transaction_count = result.user_transactions.length
