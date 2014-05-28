angular.module("app").controller "FooterController", ($scope, Wallet) ->
  $scope.connections = 0

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

    $scope.wallet_open = info.wallet_open

  $scope.$watch(watch_for, on_update, true)


