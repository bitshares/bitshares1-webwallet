angular.module("app").controller "PreferencesController", ($scope, $location, Wallet, Shared, Growl, $idle) ->
    $scope.timeout = Wallet.timeout
    $scope.updatePreferences = ->
        Wallet.timeout = $scope.timeout
        $idle._options().idleDuration=Wallet.timeout
        console.log($idle._options())
        Wallet.set_setting('timeout', $scope.timeout).then (r) ->
            console.log('t sumbitted')
            Growl.notice "", "Preferences Updated"