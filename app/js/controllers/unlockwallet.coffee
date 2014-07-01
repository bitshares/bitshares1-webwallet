angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.wrongPass = false
  $scope.submitForm = ->
    promise = Wallet.wallet_unlock($scope.spending_password).then( () ->
      $scope.history_back()
    , (error) ->
      $scope.wrongPass = true
    )
    $rootScope.showLoadingIndicator promise

