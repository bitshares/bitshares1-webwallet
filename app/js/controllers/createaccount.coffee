angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gravatar': $scope.gravatarDisplayName}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
