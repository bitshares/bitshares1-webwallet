angular.module("app").controller "EditLocalController", ($scope, $filter, $location, $stateParams, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain) ->
    name = $stateParams.name

    $scope.$watch ->
        Wallet.accounts[name]
    , ->
        if Wallet.accounts[name]
            acct = Wallet.accounts[name]
            $scope.edit={}
            if acct.private_data
                $scope.edit.newemail = acct.private_data.gui_data.email
                $scope.edit.newwebsite = acct.private_data.gui_data.website
                if (acct.private_data.gui_custom_data_pairs)
                  $scope.edit.pairs = acct.private_data.gui_custom_data_pairs
                else
                  $scope.edit.pairs=[]

    $scope.submitEditAccount = ->
        Wallet.account_update_private_data(name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs}).then ->
            console.log('submitted', name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs})
            Wallet.refresh_account(name)

    $scope.addKeyVal = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            $scope.edit.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty fields first'

    $scope.removeKeyVal = (index) ->
        $scope.edit.pairs.splice(index, 1)
