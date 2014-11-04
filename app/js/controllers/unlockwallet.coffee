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

        deferred = $q.defer()

        Wallet.open().then ->
            Wallet.wallet_unlock($scope.spending_password, error_handler).then ->
                deferred.resolve()
                res = $scope.history_back()
                navigate_to('home') unless res
            , (error) -> deferred.reject()
        , (error) -> deferred.reject()
        $rootScope.showLoadingIndicator deferred.promise

    $scope.$on "$destroy", ->
        $rootScope.splashpage = false
        $scope.startIdleWatch()
