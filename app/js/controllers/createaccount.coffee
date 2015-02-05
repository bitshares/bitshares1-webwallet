angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, WalletAPI, Utils) ->
    $scope.f = {}

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

        Wallet.create_account(name, null, error_handler).then ->
            WalletAPI.account_set_favorite(name, true, error_handler).then ->
                $location.path("accounts/" + name)
            , (error) ->
                $location.path("accounts/" + name)
