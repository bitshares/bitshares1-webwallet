angular.module("app").controller "AddressBookModalController", ($scope, $modalInstance, Wallet, WalletAPI, Utils, Info, contact_name, add_contact_mode, action) ->
    regexp = new RegExp("^#{Info.info.address_prefix}[a-zA-Z0-9]+")
    match = regexp.exec(contact_name)
    if match
        $scope.account = {name: '', key: contact_name}
    else
        $scope.account = {name: contact_name, key: ''}
    $scope.data = {}
    $scope.data.add_contact_mode = add_contact_mode
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
            $scope.data.contacts.splice(index, 1)
            delete Wallet.contacts[name]
            WalletAPI.remove_contact(name, false)
            Wallet.refresh_contacts()

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
        WalletAPI.add_contact($scope.account.key, $scope.account.name, error_handler).then (response) ->
            Wallet.refresh_contacts()
            $modalInstance.close("ok")
            action($scope.account.name) if action
