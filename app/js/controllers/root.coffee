angular.module("app").controller "RootController", ($scope, $location, $modal, $q, $http, $rootScope, $state, $stateParams, Wallet, Client, $idle, Shared, Info, WalletAPI, Observer) ->
    $scope.unlockwallet = false
    $scope.bodyclass = "cover"
    $scope.currentPath = $location.path()
    $scope.theme = 'default'
    $scope.is_bitshares_js = window.bts isnt undefined
    
    $scope.current_path_includes = (str, params = null)->
        res = $state.current.name.indexOf(str) >= 0
        if res and params
            key = Object.keys(params)[0]
            res = $stateParams[key] == params[key]
        return res

    $scope.started = false

    closeModals = ->
        if $scope.warning
            $scope.warning.close()
            $scope.warning = null
        if $scope.timedout
            $scope.timedout.close()
            $scope.timedout = null
        return
    $scope.started = false
    $scope.$on "$idleStart", ->
        closeModals()
        $scope.warning = $modal.open(
            templateUrl: "warning-dialog.html"
            windowClass: "modal-danger"
        )
        return

    $scope.$on "$idleEnd", ->
        closeModals()
        return

    $scope.$on "$idleTimeout", ->
        closeModals()
        Wallet.wallet_lock().then ->
            console.log('Wallet was locked due to inactivity')
            navigate_to('unlockwallet')

    $scope.startIdleWatch = ->
        closeModals()
        $idle.watch()
        $scope.started = true
        Info.watch_for_updates()
        return

    $scope.stopIdleWatch = ->
        closeModals()
        $idle.unwatch()
        $scope.started = false
        Info.watch_for_updates shutdown=true
        return

    open_wallet = (mode) ->
        $rootScope.cur_deferred = $q.defer()
        $modal.open
            templateUrl: "openwallet.html"
            controller: "OpenWalletController"
            resolve:
                return: ->
                    mode
        $rootScope.cur_deferred.promise

    $scope.wallet_action = (mode) ->
        open_wallet(mode)

#    $scope.$watch ->
#        $location.path()
#    , ->
#        $scope.currentPath = $location.path()
#        if $location.path() == "/unlockwallet" || $location.path() == "/createwallet"
#            stopIdleWatch()
#            $scope.bodyclass = "splash"
#            $scope.unlockwallet = true
#        else
#            # TODO update bodyclass by watching unlockwallet
#            startIdleWatch()
#            $scope.bodyclass = "splash"
#            $scope.unlockwallet = false
#            Wallet.check_wallet_status()

    $scope.$watch ->
        Info.info.wallet_unlocked
    , (unlocked)->
        switch unlocked
            #when undefined
                # console.log 'wallet_unlocked undefined'
            when on
                #console.log 'wallet_unlocked',unlocked
                Observer.registerObserver Wallet.observer_config()
                Wallet.check_wallet_status().then ->
                    Info.watch_for_updates()
                    Wallet.refresh_accounts()

            when off
                #console.log 'wallet_unlocked',unlocked
                Observer.unregisterObserver Wallet.observer_config()

        navigate_to('unlockwallet') if Info.info.wallet_open and !unlocked
        ### mail is not used yet... Instead, a default mailserver may enable mail for everyone
        if unlocked
            #console.log 'unlocked, scan for mail accounts..'
            WalletAPI.list_accounts().then (result) ->
                for account in result
                    continue unless account.is_my_account
                    if account.public_data?.mail_servers
                        #console.log 'unlocked, mail account found..'
                        $scope.mail_enabled = on
                        break
        ###
    , true

    $scope.clear_form_errors = (form) ->
        form.$error.message = null if form.$error.message
        form.$dirty = false
        form.$valid = true
        form.$invalid= false
        for key of form
            continue if /^(\$|_)/.test key
            control = form[key]
            control.clear_errors() if control && control.clear_errors
            control.$setPristine true
            control.$valid = true

    $scope.close_context_help = ->
        $scope.context_help.open = false

    $scope.startIdleWatch()
