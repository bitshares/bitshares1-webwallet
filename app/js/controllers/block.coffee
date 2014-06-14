angular.module("app").controller "BlockController", ($scope, $location, $stateParams, $state, BlockchainAPI, Utils) ->
    
    $scope.number = $stateParams.number
    $scope.utils = Utils

    BlockchainAPI.blockchain_get_block_by_number($scope.number).then (result) ->
        $scope.block = result
        $scope.block.transaction_count = result.user_transaction_ids.length
        BlockchainAPI.blockchain_get_blockhash($scope.number).then (block_hash) ->
            $scope.block_hash = block_hash

            BlockchainAPI.blockchain_get_transactions_for_block(block_hash).then (transactions) ->
                $scope.block.transactions = []
                for i in [0 ... transactions.length]
                # TODO: are they totally matching?
                    trx = {}
                    trx.id = $scope.block.user_transaction_ids[i]
                    trx.out = transactions[i].withdraws
                    trx.in = transactions[i].deposits
                    trx.net_delegate_votes = transactions[i].net_delegate_votes
                    trx.operations = transactions[i].trx.operations
                    $scope.block.transactions.push trx
                    # not all block trxs are stored, do not know the trx: trx.time = 
