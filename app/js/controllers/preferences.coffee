angular.module("app").controller "PreferencesController", ($scope, $rootScope, $location, $q, Wallet, WalletAPI, Blockchain, Shared, Growl, Utils, $idle, $translate, $filter) ->
    $scope.model = { transaction_fee: null, symbol: null }
    $scope.model.timeout = Wallet.timeout
    $scope.model.symbol = ''
    $scope.model.languages =
        "en": "English"
        "es": "Español"
        "zh-CN": "简体中文"
        "de": "Deutsch"
        "ru": "Русский"
        "it": "Italiano"
        "ko": "한국어"
    $scope.model.language_locale = $translate.preferredLanguage()
    $scope.model.language_name = $scope.model.languages[$scope.model.language_locale]


    $scope.voting = {default_vote: Wallet.default_vote}
    $scope.voting.vote_options =
        vote_none: "vote_none"
        vote_all: "vote_all"
        vote_random: "vote_random_subset"
        vote_recommended: "vote_as_delegates_recommended"
        vote_per_transfer: "vote_per_transfer"

    $scope.model.themes = {}

    getTranslations = () ->
        $translate.use($scope.model.language_locale).then () ->
            $translate(['pref.default',"pref.flowers", "pref.time_too_low", "pref.time_too_high",
             "pref.fee_too_low", "pref.updated"]).then (result) ->
                $scope.model.themes =
                    "default": result["pref.default"]
                    "flowers": result["pref.flowers"]
                $scope.warnings = 
                    "time_too_low": result["pref.time_too_low"]
                    "time_too_high": result["pref.time_too_high"]
                    "fee_too_low": result["pref.fee_too_low"]
                    "updated": result["pref.updated"]
                $scope.model.theme = Wallet.interface_theme
                $scope.model.theme_name = $scope.model.themes[$scope.model.theme]

    getTranslations()

    $scope.$watch ->
        Wallet.timeout
    , (value) ->
        return if value == null
        $scope.model.timeout = value

    $scope.$watch ->
        Wallet.default_vote
    , (value) ->
        $scope.voting.default_vote = value

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

    $scope.$watch ->
        Wallet.interface_theme
    , (value) ->
        return if value == null
        $scope.model.theme = value
        $scope.model.theme_name = $scope.model.themes[value]

    $scope.updatePreferences = ->
        getTranslations()
        if $scope.model.timeout < 15
            $scope.model.timeout = '15'
            Growl.notice "", $scope.warnings.time_too_low
        if $scope.model.timeout > 99999999
            $scope.model.timeout = '99999999'
            Growl.notice "", $scope.warnings.time_too_high
        if $scope.model.transaction_fee < 0.1
            $scope.model.transaction_fee = 0.1
            Growl.notice "", $scope.warnings.fee_too_low
        Wallet.timeout = $scope.model.timeout
        $idle._options().idleDuration = Wallet.timeout
        pf = $scope.model.transaction_fee
        calls = [
                Wallet.set_setting('timeout', $scope.model.timeout),
                WalletAPI.set_transaction_fee(pf),
                Wallet.set_setting('interface_locale', $scope.model.language_locale)
                Wallet.set_setting('interface_theme', $scope.model.theme)
                Wallet.set_setting('default_vote', $scope.voting.default_vote)
        ]
        $q.all(calls).then (r) ->
            $translate.use($scope.model.language_locale)
            moment.locale($scope.model.language_locale)
            Wallet.default_vote = $scope.voting.default_vote
            Growl.notice $scope.warnings.updated, ""

    $scope.blockchain_last_block_num = 111
    $scope.translationData = {value: 111}

    $rootScope.$on '$translateLoadingSuccess', () ->
      getTranslations()
    
