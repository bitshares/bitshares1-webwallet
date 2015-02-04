angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Utils) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.$error.message = ""
        name = $scope.f.name

        error_handler = (response) ->
            console.log "------ error ------>", response.data.error
            if response.data.error
                form.account_name.$error.message = Utils.formatAssertException(response.data.error.message)
                return true
            else
                return false

        Wallet.create_account(name, null, error_handler).then ->
            $location.path("accounts/" + name)
