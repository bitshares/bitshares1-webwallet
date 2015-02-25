angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, $interval, $location, $q, Wallet, Observer, Info, Growl) ->
    $rootScope.splashpage = true
    Wallet.get_setting("interface_theme").then (result) ->
        $rootScope.theme = if result && result.value then result.value else 'default'

    $scope.stopIdleWatch()

    $scope.descriptionCollapsed = true
    $scope.wrongPass = false
    $scope.update_available = false
    $scope.spending_password = ""

    isCapsLockOn = ($event) ->
        keyCode = if $event.keyCode then $event.keyCode else $event.which
        char = String.fromCharCode(keyCode);
        if (char.toUpperCase() == char.toLowerCase())
            return undefined
        isUpperCase = (char == char.toUpperCase())
        return ((isUpperCase && !$event.shiftKey) || (!isUpperCase && $event.shiftKey))

    $scope.keydown = ($event) ->
        $scope.wrongPass = false
        if ($event.keyCode == 20 && $scope.capsLockOn?)
            $scope.capsLockOn = !$scope.capsLockOn;

    $scope.keypress = ($event) ->
        if ((capsLockOn = isCapsLockOn($event))?)
            $scope.capsLockOn = capsLockOn

    cancel = $scope.$watch ->
        Info.info.client_version
    , ->
        if (Info.info.client_version)
            cancel()
            $scope.client_version = Info.info.client_version

    $scope.submitForm = ->
        $scope.wrongPass = false

        error_handler = (response) ->
            if response.data?.error?.code
                code = response.data.error.code
                if code == 20015 or code == 20001
                    $scope.wrongPass = true
                    $scope.spending_password = ""
                    return true

            Growl.error response.data.error.message, response.data.error.detail
            return true

        deferred = $q.defer()

        Wallet.open().then ->
            Wallet.wallet_unlock($scope.spending_password, error_handler).then ->
                deferred.resolve()
                res = $scope.history_back()
                navigate_to('accounts') unless res
            , (error) ->
                deferred.reject()
        , (error) ->
            deferred.reject()
        $rootScope.showLoadingIndicator deferred.promise

    $scope.$on "$destroy", ->
        $rootScope.splashpage = false
        $scope.startIdleWatch()
