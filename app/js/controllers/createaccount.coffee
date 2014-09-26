angular.module("app").controller "CreateAccountController", ($scope, $location, $http, Wallet) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.error_message = null
        name=$scope.f.name
        Wallet.create_account(name, {'gui_data': {'website': $scope.website}}).then (pubkey)=>
            $location.path("accounts/" + name)
        , (response) ->
            console.log response
            if response.data.error
                form.account_name.error_message = response.data.error.message
