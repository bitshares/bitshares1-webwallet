angular.module("app").controller "PreferencesController", ($scope, $location, Wallet, Shared, Growl, $idle) ->
    $scope.model ={}
    $scope.model.timeout = Wallet.timeout

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
        console.log($idle._options())
        Wallet.set_setting('timeout', $scope.model.timeout).then (r) ->
            Growl.notice "Preferences Updated",""
