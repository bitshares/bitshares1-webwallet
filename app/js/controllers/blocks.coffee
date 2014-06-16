angular.module("app").controller "BlocksController", ($scope, $location, $state, Growl, Blockchain, Utils, $interval) ->
  $scope.blocks=Blockchain.recent_blocks

  Blockchain.refresh_recent_blocks()
