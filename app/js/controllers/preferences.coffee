angular.module("app").controller "PreferencesController", ($scope, $location, $q, Wallet, WalletAPI, Blockchain, Shared, Growl, Utils, $idle) ->
    $scope.model ={ transaction_fee: 0.0 }
    $scope.model.timeout = Wallet.timeout
    $scope.model.autocomplete = Wallet.autocomplete
    $scope.model.symbol = ''

    $scope.$watch ->
        Wallet.timeout
    , ->
        $scope.model.timeout = Wallet.timeout

    $scope.$watch ->
        Wallet.autocomplete
    , ->
        $scope.model.autocomplete = Wallet.autocomplete

    $scope.$watch ->
        Wallet.info.transaction_fee
    , ->
        console.log('Wallet.info.transaction_fee',Wallet.info.transaction_fee)
        Blockchain.get_asset(0).then (v)->
            pf_obj = Utils.asset(Wallet.info.transaction_fee, v)
            $scope.model.transaction_fee = pf_obj.amount.amount / pf_obj.precision
            $scope.model.symbol = v.symbol
    
    $scope.updatePreferences = ->
        if $scope.model.timeout < 15
            $scope.model.timeout = '15'
            Growl.notice "","User-input timeout was too low.  It was increased to 15"
        if $scope.model.timeout > 99999999
            $scope.model.timeout = '99999999'
            Growl.notice "","User-input timeout was too high.  It was decrease to 99999999"
        Wallet.timeout = $scope.model.timeout
        $idle._options().idleDuration=Wallet.timeout
        pf = $scope.model.transaction_fee
        $q.all([Wallet.set_setting('timeout', $scope.model.timeout), WalletAPI.set_transaction_fee(pf), Wallet.set_setting('autocomplete', $scope.model.autocomplete)]).then (r) ->
            Wallet.wallet_get_info()
            Growl.notice "Preferences Updated",""
