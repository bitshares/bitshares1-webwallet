angular.module("app").controller "CreateWalletController", ($scope, $rootScope, $modal, $log, $location, RpcService, Wallet, Growl) ->
    $scope.wallet_name = "default"
    $scope.spending_password = ""
    $scope.descriptionCollapsed = true
    $scope.license_accepted = false

    $scope.accept_license = ->
          $scope.license_accepted = true

    $scope.submitForm = (isValid, password) ->
        if isValid
            promise = Wallet.create($scope.wallet_name, password)
            promise.then ->
                $location.path("/create/account")
            $rootScope.showLoadingIndicator promise
        else
            Growl.error "", "Unable to create a wallet. Please fill up the form below."
