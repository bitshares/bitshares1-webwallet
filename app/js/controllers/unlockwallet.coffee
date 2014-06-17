angular.module("app").controller "UnlockWalletController", ($scope, $modal, $log, RpcService, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.submitForm = ->
    Wallet.wallet_unlock($scope.spending_password).then ->
      window.location.href = "/"
      return
