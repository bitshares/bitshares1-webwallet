angular.module("app").controller "TransactionController", ($scope, $location, $stateParams, $state, BlockchainAPI, Utils) ->
    
    $scope.id = $stateParams.id
    $scope.next_trx_id = ""
    $scope.next_trx_num = -1
    $scope.prev_trx_id = ""
    $scope.prev_trx_num = -1

    BlockchainAPI.get_transaction($scope.id).then (result) ->
        $scope.t = result
        BlockchainAPI.get_block_by_number($scope.t.chain_location.block_num).then (result) ->
            $scope.t.timestamp = result.timestamp
            if ($scope.t.chain_location.trx_num + 1) < result.user_transaction_ids.length
                $scope.next_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num + 1]
                $scope.next_trx_num = $scope.t.chain_location.trx_num + 1

            if ($scope.t.chain_location.trx_num - 1) >= 0
                $scope.prev_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num - 1]
                $scope.prev_trx_num = $scope.t.chain_location.trx_num - 1
