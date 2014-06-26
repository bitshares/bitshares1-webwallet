angular.module("app").controller "BlocksByRoundController", ($scope, $location, $stateParams, $state, Growl, Client, Blockchain, BlockchainAPI, RpcService) ->
    if $stateParams.withtrxs == 'true'
      $scope.filter_zero_trxs = true
    else
      $scope.filter_zero_trxs = false

    # TODO: change to $q.when all, to make it cleaner, add $watch?
    Blockchain.get_config().then (config) ->
        $scope.round_count = config.delegate_num
        $scope.round = parseInt($stateParams.round, 10)
        $scope.start = ($scope.round - 1) * $scope.round_count + 1
        $scope.end = $scope.start + $scope.round_count - 1

        BlockchainAPI.list_blocks($scope.start, $scope.round_count).then (result) ->
            blocks = []
            for block_stat in result
                block = block_stat[0]
                block.missed = block_stat[1].missed
                block.latency = block_stat[1].latency
                blocks.push block
            $scope.blocks = blocks
            $scope.end = $scope.start + $scope.blocks.length - 1
            block_numbers = []
            for block in $scope.blocks
                block_numbers.push [block.block_num]
            RpcService.request("batch", ["blockchain_get_signing_delegate", block_numbers]).then (response) ->
                delegate_names = response.result
                for i in [0...delegate_names.length]
                    $scope.blocks[i].delegate_name = delegate_names[i]

    Blockchain.get_last_block_round().then (last_block_round) ->
        $scope.last_block_round = last_block_round + 1

