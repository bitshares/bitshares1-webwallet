angular.module("app").controller "BlocksByRoundController", ($scope, $location, $stateParams, $state, Growl, Client, BlockchainAPI, RpcService) ->
  $scope.round_count = Client.config.num_delegates
  $scope.round = parseInt($stateParams.round, 10)
  $scope.start = ($scope.round - 1) * $scope.round_count + 1
  $scope.end = $scope.start + $scope.round_count - 1
  

  BlockchainAPI.list_blocks($scope.start, $scope.round_count).then (result) ->
    $scope.blocks = result
    block_numbers = []
    for block in $scope.blocks
        block_numbers.push [block.block_num]
    RpcService.request("batch", ["blockchain_get_signing_delegate", block_numbers]).then (response) ->
        delegate_names = response.result
        for i in [0...delegate_names.length]
            $scope.blocks[i].delegate_name = delegate_names[i]
