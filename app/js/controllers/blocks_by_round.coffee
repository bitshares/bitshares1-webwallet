angular.module("app").controller "BlocksByRoundController", ($scope, $location, $stateParams, $state, $q, Growl, Client, Blockchain, BlockchainAPI, RpcService, Utils) ->
    if $stateParams.withtrxs == 'true'
      $scope.filter_zero_trxs = true
    else
      $scope.filter_zero_trxs = false

    $scope.get_previous_block_timestamp = (blocks)->
        last_block_timestamp = 0
        if blocks.length and blocks[0].block_num != 1
            BlockchainAPI.get_block(blocks[0].block_num - 1).then (previous) ->
                last_block_timestamp = previous.timestamp
        else
            deferred = $q.defer()
            # ignore the case of missing blocks before #1
            deferred.resolve(0)
            return deferred.promise

    # TODO: change to $q.when all, to make it cleaner, add $watch?
    Blockchain.get_config().then (config) ->
        $scope.round_count = config.page_count
        $scope.round = parseInt($stateParams.round, 10)
        $scope.start = ($scope.round - 1) * $scope.round_count + 1
        $scope.end = $scope.start + $scope.round_count - 1

        BlockchainAPI.list_blocks($scope.start, $scope.round_count).then (result) ->
            block_numbers = []
            for block in result
                block_numbers.push [block.block_num]
            RpcService.request("batch", ["blockchain_get_block_signee", block_numbers]).then (response) ->
                delegate_names = response.result
                for i in [0...delegate_names.length]
                    result[i].delegate_name = delegate_names[i]
                $scope.end = $scope.start + result.length - 1

                $scope.blocks = []
                Blockchain.get_config().then (config) ->
                    $scope.get_previous_block_timestamp(result).then (last_block_timestamp) ->
                        for i in [0 ... result.length]
                            if last_block_timestamp == 0 and i == 0
                                last_block_timestamp = result[0].timestamp
                            delta = (Utils.toDate(result[i].timestamp) - Utils.toDate(last_block_timestamp))/1000 
                            delta = delta / config.block_interval
                            for j in [ 1 ... delta]
                                block = 
                                    block_num : -2
                                    timestamp : Utils.advance_interval(last_block_timestamp, config.block_interval, j)
                                    user_transaction_ids : []
                                $scope.blocks.push block
                            last_block_timestamp = result[i].timestamp
                            # TODO: still not detecting missing blocks between pages
                            $scope.blocks.push result[i]
                                
    Blockchain.get_last_block_round().then (last_block_round) ->
        $scope.last_block_round = last_block_round + 1

