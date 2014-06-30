angular.module("app").controller "BlockController", ($scope, $location, $stateParams, $state, BlockchainAPI, Blockchain, Utils) ->
    
    $scope.number = $stateParams.number
    $scope.utils = Utils

    BlockchainAPI.get_block_by_number($scope.number).then (result) ->
        $scope.block = result
        $scope.block.transaction_count = result.user_transaction_ids.length
        BlockchainAPI.get_blockhash($scope.number).then (block_hash) ->
            $scope.block.block_hash = block_hash

            BlockchainAPI.get_transactions_for_block(block_hash).then (transactions) ->
                $scope.block.transactions = []
                Blockchain.refresh_asset_records().then () ->
                    for i in [0 ... transactions.length]
                    # TODO: are they totally matching?
                        trx = {}
                        trx.id = $scope.block.user_transaction_ids[i]
                        trx.withdraws = transactions[i].withdraws
                        trx.a_withdraws = []
                        for w in trx.withdraws
                            asset_type = Blockchain.asset_records[w[1].asset_id]
                            trx.a_withdraws.push Utils.newAsset(w[1].amount, asset_type.symbol, asset_type.precision)

                        trx.deposits = transactions[i].deposits
                        trx.a_deposits = []
                        for d in trx.deposits
                            asset_type = Blockchain.asset_records[d[1].asset_id]
                            trx.a_deposits.push Utils.newAsset(d[1].amount, asset_type.symbol, asset_type.precision)

                        trx.net_delegate_votes = transactions[i].net_delegate_votes
                        asset_type = Blockchain.asset_records[0]
                        for n in trx.net_delegate_votes
                            n.push Utils.asset(n[1].votes_for - n[1].votes_against, asset_type)
                        trx.operations = transactions[i].trx.operations
                        trx.balance = transactions[i].balance
                        for b in trx.balance
                            b.push  Utils.asset(b[1], Blockchain.asset_records[b[0]])

                        $scope.block.transactions.push trx

            BlockchainAPI.get_signing_delegate($scope.number).then (delegate_name) ->
                console.log delegate_name
                $scope.block.delegate_name = delegate_name
