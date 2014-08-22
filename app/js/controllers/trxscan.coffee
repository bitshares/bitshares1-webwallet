angular.module("app").controller "TrxScanController", ($scope, Info) ->
  $scope.progress=0
  $scope.last_block_time = null

  $scope.$watch ->
    Info.info.wallet_scan_progress
  , ->
    if (Info.info && Info.info.wallet_scan_progress)
      $scope.progress=Info.info.wallet_scan_progress*100

  $scope.$watch ->
    Info.info.last_block_time
  , ->
    if (Info.info && Info.info.last_block_time)
      $scope.last_block_time = Info.info.last_block_time