angular.module("app").controller "EditLocalController", ($scope, $filter, $location, $stateParams, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain) ->
    name = $stateParams.name
    $scope.model={}
    $scope.model.newName=$stateParams.name

    $scope.$watch ->
        Wallet.accounts[name]
    , ->
        if Wallet.accounts[name]
            acct = Wallet.accounts[name]
            $scope.edit={}
            if acct.private_data && acct.private_data.gui_data
                $scope.edit.newemail = acct.private_data.gui_data.email
                $scope.edit.newwebsite = acct.private_data.gui_data.website
                if (acct.private_data.gui_custom_data_pairs)
                  $scope.edit.pairs = acct.private_data.gui_custom_data_pairs
                else
                  $scope.edit.pairs=[]

    $scope.submitEditAccount = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            Wallet.account_update_private_data(name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs}).then ->
            Wallet.refresh_account(name)
        else
            Growl.error 'Fill out empty keys first', ''

    $scope.addKeyVal = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            $scope.edit.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty keys first', ''

    $scope.removeKeyVal = (index) ->
        $scope.edit.pairs.splice(index, 1)

    $scope.changeName = (newName) ->
        Wallet.wallet_rename_account(name, $scope.model.newName).then ->
            $location.path("/accounts/"+$scope.model.newName)
