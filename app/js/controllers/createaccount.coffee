angular.module("app").controller "CreateAccountController", ($scope, $location, $http, Wallet, Growl) ->
    $scope.f={}

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then (pubkey)=>
            $location.path("accounts/" + name)
