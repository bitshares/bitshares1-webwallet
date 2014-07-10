angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
   $scope.f={}
   oldname=$scope.f.name
   $scope.kd = ->
       oldname=$scope.f.name
       
   $scope.ku = ->
       console.log('old', oldname)
       console.log('new', $scope.f.name)
       valid=/[a-z]+(?:\-*[a-z0-9])*$/.test($scope.f.name)
       if(!valid)
           $scope.f.name=oldname
       console.log('valid', valid)
       console.log('err', $scope.errorMsg)

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
