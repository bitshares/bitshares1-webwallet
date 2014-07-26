angular.module("app").controller "CreateAccountController", ($scope, $location, $http, Wallet) ->
    $scope.f = {}

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.error_message = null
        #gravatarDisplayName is put on the scope from the controller
        #console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data': {'email': $scope.email}}).then (pubkey)=>
            $location.path("accounts/" + name)
        , (response) ->
            if response.data.error.code == 10 and response.data.error.message
                message = response.data.error.message.replace(/(\r\n|\n|\r)/gm,'')
                regex_match = message.match(/Assert\sException.+\:\s?(.+)/i)
                if regex_match and regex_match.length > 1
                    form.account_name.error_message = regex_match[1]
                else
                    form.account_name.error_message = message