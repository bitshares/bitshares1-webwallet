angular.module("app").controller "AddressBookModalController", ($scope, $modalInstance, Wallet, WalletAPI, Utils, contact_name, action) ->
    $scope.account = {name: contact_name, key: ''}
    $scope.data = {}
    $scope.data.add_contact_mode = false
    $scope.data.favorites = Object.keys(Wallet.favorites)
    $scope.data.contact_name_filter = ""

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.selectAccount = (name) ->
        index = $scope.data.favorites.indexOf(name)
        if index >= 0
            $modalInstance.close("ok")
            action(name) if action

    $scope.removeContact = (name) ->
        index = $scope.data.favorites.indexOf(name)
        if index >= 0
            $scope.data.favorites.splice(index, 1)
            delete Wallet.favorites[name]
            Wallet.accounts[name].is_favorite = false
            WalletAPI.account_set_favorite(name, false)

    $scope.ok = ->
        form = @newcontact
        form.account_key.$invalid = false
        form.account_name.$invalid = false
        form.account_key.$error.message = null
        form.account_name.$error.message = null
        error_handler = (error) ->
            form.account_key.$invalid = true
            message = Utils.formatAssertException(error.data.error.message)
            form.account_key.$error.message = if message and message.length > 2 then message else "Not valid public key"
        Wallet.wallet_add_contact_account($scope.account.name, $scope.account.key, error_handler).then (response) ->
            WalletAPI.account_set_favorite($scope.account.name, true)
            Wallet.refresh_accounts()
            $modalInstance.close("ok")
            action($scope.account.name) if action
