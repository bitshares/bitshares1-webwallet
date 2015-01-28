angular.module("app").controller "NewContactModalController", ($scope, $modalInstance, Wallet, Utils, contact_name, action) ->
    $scope.account = {name: contact_name, key: ''}

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

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
            Wallet.refresh_accounts()
            $modalInstance.close("ok")
            action($scope.account.name) if action
