angular.module("app").controller "FooterController", ($scope, Wallet) ->
  $scope.connections = 0
  $scope.blockchain_blocks_behind = 0
  $scope.blockchain_status = "off"
  $scope.blockchain_last_block_num = 0

  watch_for = ->
    Wallet.info

  on_update = (info) ->
    connections = info.network_connections
    $scope.connections = connections
    if connections == 0
      $scope.connections_str = "Not connected to the network"
    else if connections == 1
      $scope.connections_str = "1 network connection"
    else
      $scope.connections_str = "#{connections} network connections"

    if connections < 4
      $scope.connections_img = "/img/signal_#{connections}.png"
    else
      $scope.connections_img = "/img/signal_4.png"

    $scope.wallet_unlocked = info.wallet_unlocked

    if info.last_block_time
      $scope.blockchain_blocks_behind = Math.floor((Date.now() - info.last_block_time.getTime()) / (30 * 1000))
      $scope.blockchain_status = if $scope.blockchain_blocks_behind < 2 then "synced" else "syncing"
      $scope.blockchain_last_block_num = info.last_block_num

  $scope.$watch(watch_for, on_update, true)


