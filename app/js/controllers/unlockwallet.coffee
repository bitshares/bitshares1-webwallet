angular.module("app").controller "UnlockWalletController", ($scope, $modal, $log, $location, RpcService, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.wrongPass = false
  $scope.submitForm = ->
    Wallet.wallet_unlock($scope.spending_password).then( () ->
      # TODO: change to the history.back() address, need to rember issue 63
      $location.path("/home")
    , (error) ->
      $scope.wrongPass = true
    )

