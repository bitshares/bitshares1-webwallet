angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
    $scope.createAccount = ->
        name=$scope.name
        Wallet.create_account(name, $scope.notes).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
