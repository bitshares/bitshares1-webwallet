angular.module("app").controller "UnlockWalletController", ($scope, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.wrongPass = false
  $scope.submitForm = ->
    Wallet.wallet_unlock($scope.spending_password).then( () ->
      $scope.history_back()
    , (error) ->
      $scope.wrongPass = true
    )

