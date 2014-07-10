angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
   $scope.f={}
   oldname=$scope.f.name
   $scope.kd = ->
       oldname=$scope.f.name
       
   $scope.ku = ->
       valid=/[a-z]+(?:\-*[a-z0-9])*$/.test($scope.f.name) && $scope.f.name.length<63 || $scope.f.name is ""
       if(!valid)
           $scope.f.name=oldname

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.f.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
