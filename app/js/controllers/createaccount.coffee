angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
   oldname=$scope.name
   $scope.kd = ->
       oldname=$scope.name
       
   $scope.ku = ->
       console.log('old', oldname)
       console.log('new', $scope.name)
       valid=/[a-z]+(?:\-*[a-z0-9])*$/.test($scope.name)
       console.log('valid', valid)

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
