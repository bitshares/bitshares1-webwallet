angular.module("app").controller "UpdateRegAccountController", ($scope, $stateParams, $modal, Wallet, Shared, RpcService, Blockchain, Info, Utils, md5, WalletAPI, Growl) ->
    name = $stateParams.name

    $scope.$watch ->
        Wallet.accounts[name]
    , ->
        if Wallet.accounts[name]
            acct = Wallet.accounts[name]
            $scope.edit={}
            if acct.private_data
                $scope.edit.newemail = acct.private_data.gui_data?.email
                $scope.edit.newwebsite = acct.private_data.gui_data?.website
                if (acct.private_data.gui_custom_data_pairs)
                  $scope.edit.pairs = acct.private_data.gui_custom_data_pairs
                else
                  $scope.edit.pairs=[]


    $scope.symbolOptions = []

    $scope.$watch ->
        Info.info.delegate_reg_fee
    , ->
        Blockchain.get_asset(0).then (v)->
            $scope.delegate_reg_fee = Utils.formatAsset(Utils.asset( Info.info.delegate_reg_fee, v) )
            $scope.transaction_fee = Utils.formatAsset(Utils.asset(Wallet.info.transaction_fee.amount, v))
    $scope.m={}
    $scope.m.payrate=50
    $scope.m.delegate=false

    #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
    $scope.symbol = Info.symbol

    refresh_accounts = ->
        $scope.accounts = []
        angular.forEach Wallet.balances, (balances, name) ->
            bals = []
            angular.forEach balances, (asset, symbol) ->
                if asset.amount
                    bals.push asset
            if bals.length
                $scope.accounts.push([name, bals])

        $scope.m.payfrom= $scope.accounts[0]

    Wallet.get_accounts().then ->
        refresh_accounts()

    $scope.updateRegAccount = ->
        delegate_pay_rate_info = ""
        if !$scope.account.delegate_info and $scope.m.delegate
            # TODO: check that the payrate can not be decreased
            delegate_pay_rate_info = ", update account to a delegate costs extra " + $scope.delegate_reg_fee

        if $scope.edit.newemail
            gravatarMD5 = md5.createHash($scope.edit.newemail)
        else
            gravatarMD5 = ""

        public_info_tip = ""

        if gravatarMD5
            public_info_tip = ", the gravatar md5 \"" + gravatarMD5 + "\" hash of your email will be publish to everyone."
            
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will update your account's private and public info, need to pay fee " + $scope.transaction_fee + delegate_pay_rate_info + public_info_tip
                action: ->
                    ->
                        Wallet.account_update_private_data(name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs}).then ->
                            console.log('submitted', name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs})

                            payrate = if $scope.m.delegate then $scope.m.payrate else 255
                            console.log($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate)
                            WalletAPI.account_update_registration($scope.account.name, $scope.m.payfrom[0], {'gravatarID': gravatarMD5}, payrate).then (response) ->
                                Wallet.refresh_transactions_on_update()
                                Growl.notice "", "Account update transaction broadcasted"


    $scope.addKeyVal = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            $scope.edit.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty fields first'

    $scope.removeKeyVal = (index) ->
        $scope.edit.pairs.splice(index, 1)

