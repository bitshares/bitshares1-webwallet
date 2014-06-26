angular.module("app").controller "BlocksController", ($scope, $location, $stateParams, $state, Growl, Blockchain, Wallet ) ->
  if $stateParams.withtrxs == 'true'
      $scope.filter_zero_trxs = true
  else
      $scope.filter_zero_trxs = false

  $scope.blocks=Blockchain.recent_blocks

  old_block_time = Wallet.info.last_block_time
  watch_for =->
    Wallet.info.last_block_time

  on_update = (last_block_time) ->
    if last_block_time != old_block_time
        Blockchain.refresh_recent_blocks()

  Blockchain.refresh_recent_blocks()

  $scope.$watch(watch_for, on_update, true)
