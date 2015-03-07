angular.module("app").controller "CreateAccountController", ($scope, $location, $translate, Wallet, WalletAPI, Utils) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.$error.message = ""
        name = $scope.f.name

        error_handler = (response) ->
            if response.data.error
                if window.bts
                    message = JSON.parse response.data.error.message
                    $translate(message.key, message).then (message)->
                        form.account_name.$error.message = message
                else
                    message = Utils.formatAssertException response.data.error.message
                    form.account_name.$error.message = message
                return true
            else
                return false

        Wallet.create_account(name, null, error_handler).then ->
            WalletAPI.account_set_favorite(name, true, error_handler).then ->
                $location.path("accounts/" + name)
            , (error) ->
                $location.path("accounts/" + name)
