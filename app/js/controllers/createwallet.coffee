angular.module("app").controller "CreateWalletController", ($scope, $rootScope, $modal, $log, $location, RpcService, Wallet) ->
  $scope.wallet_name = "default"
  $scope.descriptionCollapsed = true
  $scope.license_accepted = false

  $scope.accept_license = ->
      $scope.license_accepted = true

  $scope.submitForm = (isValid) ->
    if isValid
      promise = Wallet.create($scope.wallet_name, $scope.spending_password).then ->
        $location.path("/create/account")
      $rootScope.showLoadingIndicator promise
    else
      alert "Please properly fill up the form below"
