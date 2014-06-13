angular.module("app").controller "BlocksController", ($scope, $location, $state, Growl, Blockchain, Utils) ->
  $scope.blocks=Blockchain.reverse_blocks

  #TODO make this more efficient by using parllel, and updating realtime
  Blockchain.refresh_recent_blocks(20)
