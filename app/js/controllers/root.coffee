angular.module("app").controller "RootController", ($scope, $location, $modal, $q, $http, $rootScope, Wallet, Client, $idle, Shared) ->
  $scope.unlockwallet = false
  $scope.bodyclass = "cover"

  $scope.check_wallet_status = ->
      Wallet.wallet_get_info().then (result) ->
        if result.state == "open"
            #redirection
            Wallet.check_if_locked()
            Wallet.get_setting('timeout').then (result) ->
                Shared.timeout=result.value
        else
            Wallet.open().then ->
                #redirection
                Wallet.check_if_locked()
        # here is unlock state    
        # alert(Object.keys(Wallet.accounts).length)
        if (Object.keys(Wallet.accounts).length < 1) 
            Wallet.refresh_accounts().then ->
              if Object.keys(Wallet.accounts).length < 1
                  $location.path("/create/account")


  $scope.$watch ->
        $location.path()
    , -> 
        if $location.path() == "/unlockwallet" || $location.path() == "/createwallet"
            $scope.bodyclass = "splash"
            $scope.unlockwallet = true
        else
            # TODO update bodyclass by watching unlockwallet
            $scope.bodyclass = "splash"
            $scope.unlockwallet = false
            $scope.check_wallet_status()
  
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
        mode: -> mode
    $rootScope.cur_deferred.promise

  $rootScope.open_wallet_and_repeat_request = (mode, request_data) ->
    deferred_request = $q.defer()
    #console.log "------ open_wallet_and_repeat_request #{mode} ------"
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
  
  
