angular.module("app").controller "UpdateRegAccountController", ($scope, $stateParams, $modal, Wallet, Shared, RpcService, Blockchain, Info, Utils, md5, WalletAPI) ->
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


    $scope.symbolOptions = []
    $scope.delegate_reg_fee = Info.info.delegate_reg_fee
    $scope.priority_fee = Info.info.priority_fee
    $scope.m={}
    $scope.m.payrate=50
    $scope.m.delegate=false

    #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
    $scope.symbol = 'XTS'

    refresh_accounts = ->
    RpcService.request('wallet_account_balance').then (response) ->
      $scope.accounts = []

      Blockchain.refresh_asset_records().then ()->
          $scope.formated_balances = []
          angular.forEach response.result, (account) ->
            balances = (Utils.newAsset(balance[1], balance[0], Blockchain.symbol2records[balance[0]].precision) for balance in account[1][0])
            $scope.accounts.push([account[0], balances])
          $scope.m.payfrom= $scope.accounts[0]

    refresh_accounts()

    $scope.updateRegAccount = ->
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will update your account's private and public info"
                action: ->
                    ->
                        Wallet.account_update_private_data(name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs}).then ->
                            console.log('submitted', name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs})

                            payrate = if $scope.m.delegate then $scope.m.payrate else 255
                            if $scope.edit.newemail
                                gravatarMD5 = md5.createHash($scope.edit.newemail)
                            else
                                gravatarMD5 = ""
                            console.log($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate)
                            WalletAPI.account_update_registration($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate).then (response) ->
                                Wallet.refresh_account(name)


    $scope.addKeyVal = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            $scope.edit.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty fields first'

    $scope.removeKeyVal = (index) ->
        $scope.edit.pairs.splice(index, 1)

