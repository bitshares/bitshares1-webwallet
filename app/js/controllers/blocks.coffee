angular.module("app").controller "BlocksController", ($scope, $location, $stateParams, $state, $q, Growl, Blockchain, Info, BlockchainAPI, Utils) ->
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

    Blockchain.get_blocks_with_missed(10000, 10).then (blocks) =>
        console.log "merged blocks"
        console.log blocks

    refresh_blocks = ->
        BlockchainAPI.get_block_count().then (head_block) =>
            start = head_block - 20
            if start < 0
                start = 0
            Blockchain.get_blocks_with_missed(start, 20).then (blocks) =>
                $scope.blocks = blocks

    Blockchain.get_last_block_round().then (last_block_round) ->
        $scope.last_block_round = last_block_round

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        refresh_blocks()

    refresh_blocks()

    $scope.$watch(watch_for, on_update, true)
