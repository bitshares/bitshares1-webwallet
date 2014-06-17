angular.module("app").controller "UnlockWalletController", ($scope, $modal, $log, RpcService, Wallet) ->
  #Uncomment when we start supporting brain wallets
  #$scope.isCollapsed = true
  $scope.submitForm = ->
    Wallet.wallet_unlock($scope.spending_password).then ->
      window.location.href = "/"
      return