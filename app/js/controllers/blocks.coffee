angular.module("app").controller "BlocksController", ($scope, $location, $stateParams, $state, $q, Growl, Blockchain, Info, BlockchainAPI, Utils) ->
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

    refresh_blocks = ->
        Blockchain.refresh_recent_blocks().then ()->
            result = Blockchain.recent_blocks.value
            blocks = []
            $scope.last_block_round = Blockchain.recent_blocks.last_block_round
            $scope.last_block_timestamp = Blockchain.recent_blocks.last_block_timestamp
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
                            blocks.push block
                        last_block_timestamp = result[i].timestamp
                        # TODO: still not detecting missing blocks between pages
                        blocks.push result[i]
                    $scope.blocks = blocks

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        refresh_blocks()

    refresh_blocks()

    $scope.$watch(watch_for, on_update, true)
