angular.module("app").controller "TransactionController", ($scope, $location, $stateParams, $state, BlockchainAPI, Utils) ->
    
    $scope.id = $stateParams.id

    BlockchainAPI.get_transaction($scope.id).then (result) ->
        $scope.t = result
        BlockchainAPI.get_block_by_number($scope.t.chain_location.block_num).then (result) ->
            console.log result
            $scope.t.timestamp = result.timestamp
