angular.module("app").controller "CreateWalletController", ($scope, $modal, $log, $location, RpcService, Wallet) ->
  $scope.wallet_name = "default"
  $scope.descriptionCollapsed = true
  $scope.submitForm = (isValid) ->
    if isValid
      Wallet.create($scope.wallet_name, $scope.spending_password).then ->
        $location.path("/home")
    else
      alert "Please properly fill up the form below"
