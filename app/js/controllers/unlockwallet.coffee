angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, $interval, $location, Wallet) ->
    $scope.descriptionCollapsed = true
    $scope.wrongPass = false
    $scope.submitForm = ->
        $scope.wrongPass = false
        promise = Wallet.wallet_unlock($scope.spending_password).then(() ->
            res = $scope.history_back()
            $location.path('/home') unless res
        , (error) ->
            $scope.wrongPass = true
        )

        $scope.keydown = ->
            $scope.wrongPass = false

        i = $interval ->
            Wallet.wallet_get_info().then (info)->
                $rootScope.updateProgress Math.floor(info.scan_progress * 100)
            , 2000
        $rootScope.showLoadingIndicator promise, i

