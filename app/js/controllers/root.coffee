angular.module("app").controller "RootController", ($scope, $location, $modal, $q, $http, $rootScope, Wallet, Client, $idle, Shared, Info) ->
  $scope.unlockwallet = false
  $scope.bodyclass = "cover"
  $scope.currentPath = $location.path()

  $scope.check_wallet_status = ->
      Wallet.wallet_get_info().then (result) ->
        if result.state == "open"
            #redirection
            Wallet.check_if_locked()
            Wallet.get_setting('timeout').then (result) ->
                if result && result.value
                    Wallet.timeout=result.value
        else
            Wallet.open().then ->
                #redirection
                Wallet.check_if_locked()

        Info.refresh_info().then ()->
            if Info.info.wallet_open and Info.info.wallet_unlocked
                if (Object.keys(Wallet.accounts).length < 1) 
                    Wallet.refresh_accounts().then ->
                      if Object.keys(Wallet.accounts).length < 1
                          $location.path("/create/account")

  $scope.$watch ->
        $location.path()
    , -> 
        $scope.currentPath = $location.path()
        if $location.path() == "/unlockwallet" || $location.path() == "/createwallet"
            $scope.bodyclass = "splash"
            $scope.unlockwallet = true
        else
            # TODO update bodyclass by watching unlockwallet
            $scope.bodyclass = "splash"
            $scope.unlockwallet = false
            $scope.check_wallet_status()

  $scope.$watch ->
        Info.info.wallet_unlocked
    , (unlocked)->
        Info.refresh_info().then () ->
            if Info.info.wallet_open and !Info.info.wallet_unlocked 
                ($scope.lock || angular.noop)()
    , true
  
  $scope.check_wallet_status()
    
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
        $location.path("/unlockwallet")

  $scope.start = ->
    closeModals()
    $idle.watch()
    $scope.started = true
    return

  $scope.stop = ->
    closeModals()
    $idle.unwatch()
    $scope.started = false
    return

  open_wallet = (mode) ->
    $rootScope.cur_deferred = $q.defer()
    $modal.open
      templateUrl: "openwallet.html"
      controller: "OpenWalletController"
      resolve:
        return: -> mode
    $rootScope.cur_deferred.promise

  $rootScope.open_wallet_and_repeat_request = (mode, request_data) ->
    deferred_request = $q.defer()
    console.log "------ open_wallet_and_repeat_request #{mode} ------"
    return
    open_wallet(mode).then ->
      #console.log "------ open_wallet_and_repeat_request #{mode} ------ repeat ---"
      $http(
        method: "POST",
        cache: false,
        url: '/rpc'
        data: request_data
      ).success((data, status, headers, config) ->
        #console.log "------ open_wallet_and_repeat_request  #{mode} ------ repeat success ---", data
        deferred_request.resolve(data)
      ).error((data, status, headers, config) ->
        deferred_request.reject()
      )
    deferred_request.promise

  $scope.wallet_action = (mode) ->
    open_wallet(mode)

  $scope.lock = ->
    Wallet.wallet_lock().then ->
      $location.path("/unlockwallet")
  
  
