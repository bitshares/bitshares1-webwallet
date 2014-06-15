angular.module("app").controller "UnlockWalletController", ($scope, $modal, $log, RpcService, Wallet) ->
  #Uncomment when we start supporting brain wallets
  #$scope.isCollapsed = true
  $scope.submitForm = (isValid) ->
    if isValid
      Wallet.wallet_unlock($scope.spending_password).then ->
        window.location.href = "/"
        return        
    else
      alert "Please properly fill up the form below"
      return