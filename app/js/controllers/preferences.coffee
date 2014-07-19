angular.module("app").controller "PreferencesController", ($scope, $location, Wallet, Shared, Growl, $idle) ->
    $scope.model ={}
    $scope.model.timeout = Wallet.timeout

    $scope.$watch ->
        Wallet.timeout
    , ->
        $scope.model.timeout = Wallet.timeout

    $scope.updatePreferences = ->
        Wallet.timeout = $scope.model.timeout
        $idle._options().idleDuration=Wallet.timeout
        console.log($idle._options())
        Wallet.set_setting('timeout', $scope.model.timeout).then (r) ->
            console.log('t sumbitted')
            Growl.notice "", "Preferences Updated"