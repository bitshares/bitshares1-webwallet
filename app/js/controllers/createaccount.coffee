angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.$error.message = ""
        name = $scope.f.name

        error_handler = (response) ->
            if response.data.error
                form.account_name.$error.message = response.data.error.message
                return true
            else
                return false

        Wallet.create_account(name, null, error_handler).then ->
            $location.path("accounts/" + name)
