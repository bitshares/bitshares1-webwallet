angular.module("app").controller "UnlockWalletController", ($scope, $modal, $log, RpcService, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.wrongPass = false
  $scope.submitForm = ->
    Wallet.wallet_unlock($scope.spending_password).then( () ->
      window.location.href = "/"
      return
    , (error) ->
      $scope.wrongPass = true
    )

