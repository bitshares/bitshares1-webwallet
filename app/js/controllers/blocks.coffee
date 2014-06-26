angular.module("app").controller "BlocksController", ($scope, $location, $stateParams, $state, Growl, Blockchain, Info) ->
    if $stateParams.withtrxs == 'true'
        $scope.filter_zero_trxs = true
    else
        $scope.filter_zero_trxs = false

    $scope.blocks = Blockchain.recent_blocks

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        Blockchain.refresh_recent_blocks()

    Blockchain.refresh_recent_blocks()

    $scope.$watch(watch_for, on_update, true)
