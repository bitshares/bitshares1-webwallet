angular.module("app").controller "CreateAccountController", ($scope, $location, $http, Wallet, Growl) ->
    $scope.f={}

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then (pubkey)=>
            if $scope.f.free_registration
                params =
                    method: "POST"
                    cache: false
                    url: "http://" + $scope.f.free_registration_url + "/services/json"
                    data:
                        method: "register"
                        jsonrpc: "2.0"
                        params: [$scope.email, $scope.f.name, pubkey]
                        id: 1
                $http(params).then (response) =>
                    Growl.notify "", "Free registration successful - check your email"
                , (response) =>
                    Growl.error "", "Error connecting with free registration server"
            $location.path("accounts/" + name)
