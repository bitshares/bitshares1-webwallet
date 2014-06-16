angular.module("app").controller "BlocksByRoundController", ($scope, $location, $state, Growl, Client, BlockchainAPI) ->
  $scope.round = $stateParam.round
  $scope.start = ($scope.round - 1) * Client.config.num_delegates + 1
  

  BlockchainAPI.blockchain_list_blocks($scope.start, Client.config.num_delegates).then (result) ->
    $scope.blocks = result
