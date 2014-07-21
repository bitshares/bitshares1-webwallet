angular.module("app").controller "CreateAccountController", ($scope, $location, $http, Wallet, Growl) ->
    $scope.f = { error_message: null }
    $scope.account_error_message = "empty"

    $scope.createAccount = ->
        $scope.f.error_message = null
        #gravatarDisplayName is put on the scope from the controller
        #console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then (pubkey)=>
            $location.path("accounts/" + name)
        , (response) ->
            if response.data.error.code == 10
                $scope.f.error_message = response.data.error.message?.match(/\: ([\w\s]+)\./)[1]
