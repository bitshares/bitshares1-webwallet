angular.module("app").controller "BlocksController", ($scope, $location, $state, Growl, Blockchain ) ->
  $scope.blocks=Blockchain.recent_blocks

  Blockchain.refresh_recent_blocks()
