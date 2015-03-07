angular.module("app").controller "RecoverAccountController", ($scope, $location, $translate, Wallet, WalletAPI, Utils) ->
    $scope.f = {}

    $scope.recoverAccount = ->
        throw new Error "bitshares-js only" unless window.bts
        form = @recoveraccount
        form.account_name.$error.message = ""
        name = $scope.f.name

        error_handler = (response) ->
            if response.data.error
                message = response.data.error.message
                form.account_name.$error.message = message
                return true
            else
                return false

        Wallet.recover_account(name, error_handler).then ->
            WalletAPI.account_set_favorite(name, true, error_handler).then ->
                $location.path("accounts/" + name)
            , (error) ->
                $location.path("accounts/" + name)
