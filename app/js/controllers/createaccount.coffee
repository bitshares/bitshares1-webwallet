angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.error_message = null
        name = $scope.f.name

        error_handler = (response) ->
            if response.data.error
                form.account_name.error_message = response.data.error.message
                return true
            else
                return false

        Wallet.create_account(name, {'gui_data': {'website': $scope.website}}, error_handler).then ->
            $location.path("accounts/" + name)
