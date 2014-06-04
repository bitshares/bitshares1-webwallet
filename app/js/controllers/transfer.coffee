angular.module("app").controller "TransferController", ($scope, $location, $state, RpcService, Growl, Shared) ->

  $scope.payto = Shared.contactName
  $scope.symbolOptions = ['XTS', '...']
  $scope.send = ->
  	# $scope.memo was removed
    RpcService.request('wallet_transfer', [$scope.amount, $scope.symbol, $scope.payfrom, $scope.payto, $scope.memo]).then (response) ->
      #$state.go("transactions")
      $scope.payto = ""
      $scope.amount = ""
      $scope.memo = ""
      Growl.notice "", "Transaction broadcasted (#{response.result})"
