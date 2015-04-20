angular.module("app").controller "TransactionController", ($scope, $location, $stateParams, $state, $q, BlockchainAPI, Blockchain, Utils) ->
    $scope.id = $stateParams.id
    $scope.next_trx_id = ""
    $scope.next_trx_num = 0
    $scope.prev_trx_id = ""
    $scope.prev_trx_num = 0

    BlockchainAPI.get_transaction($scope.id).then (result) ->
#        console.log "------ transaction ------>", result
        trx = $scope.t = result[1]
        $q.all([Blockchain.refresh_asset_records(), Blockchain.refresh_delegates()]).then ()->
#            trx.a_withdraws = []
#            for w in trx.withdraws
#                asset_type = Blockchain.asset_records[w[0]]
#                trx.a_withdraws.push Utils.newAsset(w[1], asset_type.symbol, asset_type.precision)
#
#            trx.a_deposits = []
#            for d in trx.deposits
#                asset_type = Blockchain.asset_records[d[0]]
#                trx.a_deposits.push Utils.newAsset(d[1], asset_type.symbol, asset_type.precision)

            asset_type = Blockchain.asset_records[0]
            if trx.net_delegate_votes
                for n in trx.net_delegate_votes
                    n.push Utils.asset(n[1].votes_for, asset_type)
                    #delegate name
                    n.push Blockchain.id_delegates[n[0]].name

            if trx.balance
                for b in trx.balance
                    b.push  Utils.asset(b[1], Blockchain.asset_records[b[0]])

            BlockchainAPI.get_block(trx.chain_location.block_num).then (result) ->
                $scope.t.timestamp = result.timestamp
                if ($scope.t.chain_location.trx_num + 1) < result.user_transaction_ids.length
                    $scope.next_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num + 1]
                    $scope.next_trx_num = $scope.t.chain_location.trx_num + 1

                if ($scope.t.chain_location.trx_num - 1) >= 0
                    $scope.prev_trx_id = result.user_transaction_ids[$scope.t.chain_location.trx_num - 1]
                    $scope.prev_trx_num = $scope.t.chain_location.trx_num - 1
