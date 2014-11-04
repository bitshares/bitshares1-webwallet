angular.module("app").controller "PreferencesController", ($scope, $location, $q, Wallet, WalletAPI, Blockchain, Shared, Growl, Utils, $idle, $translate) ->
    $scope.model = { transaction_fee: null, symbol: null }
    $scope.model.timeout = Wallet.timeout
    $scope.model.autocomplete = Wallet.autocomplete
    $scope.model.symbol = ''
    $scope.model.languages =
        "en": "English"
        "zh-CN": "简体中文"
        "de": "German"
        "ru": "Russian"
    $scope.model.language_locale = $translate.preferredLanguage()
    $scope.model.language_name = $scope.model.languages[$scope.model.language_locale]

    $scope.$watch ->
        Wallet.timeout
    , (value) ->
        return if value == null
        $scope.model.timeout = value

    $scope.$watch ->
        Wallet.autocomplete
    , (value) ->
        $scope.model.autocomplete = value

    $scope.$watch ->
        Wallet.info.transaction_fee
    , (value) ->
        return if not value or $scope.model.transaction_fee != null
        Blockchain.get_asset(0).then (v)->
            pf_obj = Utils.asset(value, v)
            $scope.model.transaction_fee = pf_obj.amount.amount / pf_obj.precision
            $scope.model.symbol = v.symbol

    $scope.$watch ->
        Wallet.interface_locale
    , (value) ->
        return if value == null
        $scope.model.language_locale = value
        $scope.model.language_name = $scope.model.languages[value]

    $scope.updatePreferences = ->
        if $scope.model.timeout < 15
            $scope.model.timeout = '15'
            Growl.notice "", "User-input timeout was too low. It was increased to 15"
        if $scope.model.timeout > 99999999
            $scope.model.timeout = '99999999'
            Growl.notice "", "User-input timeout was too high. It was decreased to 99999999"
        Wallet.timeout = $scope.model.timeout
        $idle._options().idleDuration = Wallet.timeout
        pf = $scope.model.transaction_fee
        calls = [
                Wallet.set_setting('timeout', $scope.model.timeout),
                WalletAPI.set_transaction_fee(pf),
                Wallet.set_setting('autocomplete', $scope.model.autocomplete),
                Wallet.set_setting('interface_locale', $scope.model.language_locale)
        ]
        $q.all(calls).then (r) ->
            $translate.use($scope.model.language_locale)
            Growl.notice "Preferences Updated", ""
