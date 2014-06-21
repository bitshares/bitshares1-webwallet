angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
