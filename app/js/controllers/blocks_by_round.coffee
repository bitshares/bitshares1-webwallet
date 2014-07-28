angular.module("app").controller "BlocksByRoundController", ($scope, $location, $stateParams, $state, $q, Growl, Client, Blockchain, BlockchainAPI, RpcService, Utils) ->
    if $stateParams.withtrxs == 'true'
      $scope.filter_zero_trxs = true
    else
      $scope.filter_zero_trxs = false

    $scope.plural = (delta)->
        if delta > 1 then "s" else ""

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
    Blockchain.get_info().then (config) ->
        $scope.round_count = config.page_count
        $scope.round = parseInt($stateParams.round, 10)
        $scope.start = ($scope.round - 1) * $scope.round_count + 1
        $scope.end = $scope.start + $scope.round_count - 1

        Blockchain.get_blocks_with_missed($scope.start, $scope.round_count).then (result) ->
            $scope.blocks = result
            for b in $scope.blocks.slice().reverse() 
                if b.block_num != -2
                    $scope.end = b.block_num
                    break
    
    Blockchain.get_last_block_round().then (last_block_round) ->
        $scope.last_block_round = last_block_round + 1

