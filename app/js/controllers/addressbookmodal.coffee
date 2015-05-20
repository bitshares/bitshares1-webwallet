angular.module("app").controller "AddressBookModalController", ($scope, $modalInstance, Wallet, WalletAPI, Utils, Info, contact_name, add_contact_mode, action) ->
    regexp = new RegExp("^#{Info.info.address_prefix}[a-zA-Z0-9]+")
    match = regexp.exec(contact_name)
    if match
        $scope.account = {name: '', key: contact_name}
    else
        $scope.account = {name: contact_name, key: ''}
    $scope.data = {}
    $scope.data.add_contact_mode = add_contact_mode
    $scope.data.contact_accounts = Wallet.contacts
    $scope.data.contacts = Object.keys(Wallet.contacts)
    $scope.data.contact_name_filter = ""

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.selectAccount = (name) ->
        index = $scope.data.contacts.indexOf(name)
        if index >= 0
            $modalInstance.close("ok")
            action(name) if action

    $scope.removeContact = (name) ->
        index = $scope.data.contacts.indexOf(name)
        if index >= 0
            contact_account = Wallet.contacts[name]
            name_to_remove = if contact_account?.contact_type == "public_key" then contact_account.data else name
            WalletAPI.remove_contact(name_to_remove)
            delete Wallet.contacts[name]
            $scope.data.contacts.splice(index, 1)
        return false

    $scope.isMyAccount = (name) ->
        !!Wallet.accounts[name]

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
        WalletAPI.add_contact($scope.account.key, $scope.account.name, error_handler).then ->
            Wallet.refresh_contact_data($scope.account.name).then ->
                $modalInstance.close("ok")
                action($scope.account.name) if action
