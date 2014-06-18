angular.module("app").controller "BlocksByRoundController", ($scope, $location, $stateParams, $state, Growl, Client, BlockchainAPI) ->
  $scope.round_count = Client.config.num_delegates
  $scope.round = parseInt($stateParams.round, 10)
  $scope.start = ($scope.round - 1) * $scope.round_count + 1
  $scope.end = $scope.start + $scope.round_count - 1
  

  BlockchainAPI.blockchain_list_blocks($scope.start, $scope.round_count).then (result) ->
    $scope.blocks = result
