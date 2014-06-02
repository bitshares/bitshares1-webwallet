angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, InfoBarService, Shared) ->

  $scope.payto = Shared.contactName
  $scope.send = ->
  	# $scope.memo was removed
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom, $scope.payto, $scope.memo]).then (response) ->
      #$state.go("transactions")
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      InfoBarService.message = "Transaction broadcasted (#{response.result})"
