angular.module("app").controller "TransactionController", ($scope, $location, $stateParams, $state, BlockchainAPI, Blockchain, Utils) ->
    
    $scope.id = $stateParams.id
    $scope.next_trx_id = ""
    $scope.next_trx_num = -1
    $scope.prev_trx_id = ""
    $scope.prev_trx_num = -1

    BlockchainAPI.get_transaction($scope.id).then (result) ->
        $scope.t = result

        Blockchain.refresh_asset_records().then ()->
            trx = $scope.t
            trx.a_withdraws = []
            for w in trx.withdraws
                asset_type = Blockchain.asset_records[w[1].asset_id]
                trx.a_withdraws.push Utils.newAsset(w[1].amount, asset_type.symbol, asset_type.precision)

            trx.a_deposits = []
            for d in trx.deposits
                asset_type = Blockchain.asset_records[d[1].asset_id]
                trx.a_deposits.push Utils.newAsset(d[1].amount, asset_type.symbol, asset_type.precision)

            asset_type = Blockchain.asset_records[0]
            for n in trx.net_delegate_votes
                n.push {votes_for: Utils.asset(n[1].votes_for, asset_type), votes_against: Utils.asset(n[1].votes_against, asset_type), votes_total: Utils.asset(n[1].votes_for - n[1].votes_against, asset_type)}

            for b in trx.balance
                b.push  Utils.asset(b[1], Blockchain.asset_records[b[0]])

        BlockchainAPI.get_block_by_number($scope.t.chain_location.block_num).then (result) ->
            $scope.t.timestamp = result.timestamp
            if ($scope.t.chain_location.trx_num + 1) < result.user_transaction_ids.length
                $scope.next_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num + 1]
                $scope.next_trx_num = $scope.t.chain_location.trx_num + 1

            if ($scope.t.chain_location.trx_num - 1) >= 0
                $scope.prev_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num - 1]
                $scope.prev_trx_num = $scope.t.chain_location.trx_num - 1
