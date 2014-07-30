angular.module("app").controller "PreferencesController", ($scope, $location, $q, Wallet, WalletAPI, Blockchain, Shared, Growl, $idle) ->
    $scope.model ={ priority_fee: 0.0 }
    $scope.model.timeout = Wallet.timeout
    priority_fee = {}

    WalletAPI.set_priority_fee(null).then (result) ->
        console.log "set_priority_fee =======", result
        priority_fee.amount = result.amount
        priority_fee.asset_id = result.asset_id
        Blockchain.get_asset(priority_fee.asset_id).then (asset) ->
            priority_fee.precision = asset.precision
            $scope.model.symbol = asset.symbol
            $scope.model.priority_fee = priority_fee.amount / priority_fee.precision

    $scope.$watch ->
        Wallet.timeout
    , ->
        $scope.model.timeout = Wallet.timeout

    $scope.updatePreferences = ->
        if $scope.model.timeout < 15
            $scope.model.timeout = '15'
            Growl.notice "","User-input timeout was too low.  It was increased to 15"
        if $scope.model.timeout > 99999999
            $scope.model.timeout = '99999999'
            Growl.notice "","User-input timeout was too high.  It was decrease to 99999999"
        Wallet.timeout = $scope.model.timeout
        $idle._options().idleDuration=Wallet.timeout
        pf = $scope.model.priority_fee
        $q.all([Wallet.set_setting('timeout', $scope.model.timeout), WalletAPI.set_priority_fee(pf)]).then (r) ->
            Growl.notice "Preferences Updated",""
