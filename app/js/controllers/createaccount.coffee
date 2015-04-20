angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, WalletAPI, Utils, Info) ->
    $scope.f = { fully_synced: true }

    $scope.fully_synced = true
    $scope.$watch ()->
        Info.info.seconds_behind
    , (seconds_behind) ->
        $scope.f.fully_synced = seconds_behind <= Info.FULL_SYNC_SECS if seconds_behind

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.$error.message = ""
        name = $scope.f.name

        error_handler = (response) ->
            if response.data.error
                form.account_name.$error.message = Utils.formatAssertException(response.data.error.message)
                return true
            else
                return false

        Wallet.create_account(name, error_handler).then ->
            $location.path("accounts/" + name)
