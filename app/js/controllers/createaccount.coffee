angular.module("app").controller "CreateAccountController", ($scope, $location, Wallet, Growl) ->
   oldname=$scope.name
   $scope.errorShow=false
   $scope.kd = ->
       oldname=$scope.name
       
   $scope.ku = ->
       console.log('old', oldname)
       console.log('new', $scope.name)
       valid=/[a-z]+(?:\-*[a-z0-9])*$/.test($scope.name)
       if(!valid)
           $scope.errorShow=true
           $scope.name=oldname
           setTimeout (->
               $scope.errorShow=false
           ), 3000
       console.log('valid', valid)
       console.log('err', $scope.errorMsg)

    $scope.createAccount = ->
        #gravatarDisplayName is put on the scope from the controller
        console.log($scope.gravatarDisplayName)
        name=$scope.name
        #$scope.notes was removed
        Wallet.create_account(name, {'gui_data':{'gravatarDisplayName': $scope.gravatarDisplayName, 'email': $scope.email}}).then ->
            Growl.notice "", "Account (#{name}) created"
            $location.path("accounts/" + name)
