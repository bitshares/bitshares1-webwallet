angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, $interval, $location, $q, Wallet, Observer, Info) ->
    $rootScope.splashpage = true
    $scope.stopIdleWatch()

    $scope.descriptionCollapsed = true
    $scope.wrongPass = false
    $scope.keydown = -> $scope.wrongPass = false

    $scope.update_available = false

    cancel = $scope.$watch ->
      Info.info.client_version
    , ->
      if (Info.info.client_version)
        cancel()
        $scope.client_version = Info.info.client_version

    $scope.submitForm = ->
        $scope.wrongPass = false

        error_handler = (response) ->
            $scope.wrongPass = true
            $scope.spending_password = ""
            return true

        Wallet.open().then ->
            unlock_promise = Wallet.wallet_unlock($scope.spending_password, error_handler)
            unlock_promise.then ->
                res = $scope.history_back()
                navigate_to('home') unless res
            $rootScope.showLoadingIndicator unlock_promise

    $scope.$on "$destroy", ->
        $rootScope.splashpage = false
        $scope.startIdleWatch()
