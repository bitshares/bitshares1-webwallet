angular.module("app").controller "UnlockWalletController", ($scope, $rootScope, $interval, $location, $q, Wallet, Observer, Info) ->
#    observer =
#        name: "scanning_transactions_observer"
#        data: {progress: 0}
#        frequency: 1000
#        update: (data, deferred) ->
#            Wallet.wallet_get_info().then (info)->
#                progress = info.scan_progress * 100
#                changed = data.progress != progress
#                data.progress = progress
#                deferred.resolve(changed)
#            , -> deferred.reject()

    $scope.descriptionCollapsed = true
    $scope.wrongPass = false
    $scope.keydown = -> $scope.wrongPass = false

    cancel = $scope.$watch ->
      Info.info.client_version
    , ->
      if (Info.info.client_version)
        cancel()
        $scope.client_version = Info.info.client_version

    $scope.submitForm = ->
        $scope.wrongPass = false
        #deferred = $q.defer()
        unlock_promise = Wallet.wallet_unlock($scope.spending_password)
        unlock_promise.then ->
            res = $scope.history_back()
            $location.path('/home') unless res
#            Observer.registerObserver(observer)
#            observer.notify = (data) ->
#                console.log "scanning_transactions_observer updated data: ", data.progress
#                deferred.notify(data.progress)
#                if data.progress == 0 or data.progress >= 100 or observer.counter > 120
#                    Observer.unregisterObserver(observer)
#                    res = $scope.history_back()
#                    $location.path('/home') unless res
#                    deferred.resolve()

        unlock_promise.catch ->
            $scope.wrongPass = true
            $scope.spending_password = ""
            #deferred.reject()

        $rootScope.showLoadingIndicator unlock_promise
