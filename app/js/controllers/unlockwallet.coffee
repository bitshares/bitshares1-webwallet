angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, $interval, Wallet) ->
  $scope.descriptionCollapsed = true
  $scope.wrongPass = false
  $scope.submitForm = ->
    $scope.wrongPass = false
    promise = Wallet.wallet_unlock($scope.spending_password).then( () ->
      $scope.history_back()
    , (error) ->
      $scope.wrongPass = true
    )

    i = $interval ->
        Wallet.wallet_get_info().then (info)->
            $rootScope.updateProgress Math.floor(info.wallet_scan_progress * 100)
        , 2000
    $rootScope.showLoadingIndicator promise, i

