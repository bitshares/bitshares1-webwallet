angular.module("app").controller "BlocksController", ($scope, $location, $stateParams, $state, Growl, Blockchain ) ->
  if $stateParams.withtrxs == 'true'
      $scope.filter_zero_trxs = true
  else
      $scope.filter_zero_trxs = false

  $scope.blocks=Blockchain.recent_blocks

  Blockchain.refresh_recent_blocks()
