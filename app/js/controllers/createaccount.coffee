angular.module("app").controller "CreateAccountController", ($scope, Wallet, $location) ->
    $scope.createAccount = ->
        Wallet.create_account($scope.name, $scope.notes)