angular.module("app").controller "AccountEditController", ($scope, $filter, $location, $state, $stateParams, Growl, Wallet, Utils, WalletAPI, Blockchain) ->
    name = $stateParams.name
    $scope.model = {}
    $scope.model.newName = $stateParams.name
    $scope.model.trx_fee = Wallet.info.transaction_fee

    account = Wallet.accounts[name]

    $scope.$watch ->
        Wallet.info.transaction_fee
    , (value) ->
        main_asset = Blockchain.asset_records[0]
        return unless (value and main_asset)
        $scope.model.trx_fee = value.amount / main_asset.precision
        $scope.model.trx_fee_symbol = main_asset.symbol

    read_account_data = ->
        $scope.public_data = []
        if $scope.account.public_data
            for k,v of $scope.account.public_data
                $scope.public_data.push({key: k, value: v}) if typeof v is 'string'
        $scope.private_data = []
        if $scope.account.private_data
            for k,v of $scope.account.private_data
                $scope.private_data.push({key: k, value: v}) if typeof v is 'string'

    if $scope.account
        read_account_data()
    else
        cancel_watch = $scope.$watch ->
            Wallet.accounts[name]
        , (account) ->
            return unless account
            $scope.account = account
            cancel_watch()
            read_account_data()

    $scope.savePublicData = ->
        $scope.account.public_data ||= {}
        $scope.account.public_data[d.key] = d.value for d in $scope.public_data when d.key and d.key.length > 0
        WalletAPI.account_update_registration(name, name, $scope.account.public_data, -1).then ->
            Growl.notice '', 'Public data was successfully updated'

    $scope.addPublicDataRecord = ->
        $scope.public_data.push {key: '', value: ''}

    $scope.removePublicDataRecord = (index) ->
        key = $scope.public_data[index].key
        delete $scope.account.public_data[key] if key and $scope.account.public_data
        $scope.public_data.splice(index, 1)

    $scope.savePrivateData = ->
        $scope.account.private_data ||= {}
        $scope.account.private_data[d.key] = d.value for d in $scope.private_data when d.key and d.key.length > 0
        Wallet.account_update_private_data(name, $scope.account.private_data).then ->
            Growl.notice '', 'Private data was successfully updated'

    $scope.addPrivateDataRecord = ->
        $scope.private_data.push {key: '', value: ''}

    $scope.removePrivateDataRecord = (index) ->
        key = $scope.private_data[index].key
        delete $scope.account.private_data[key] if key and $scope.account.private_data
        $scope.private_data.splice(index, 1)

    $scope.changeName = ->
        Wallet.wallet_rename_account(name, $scope.model.newName).then ->
            $state.go("account.edit", {name: $scope.model.newName})
