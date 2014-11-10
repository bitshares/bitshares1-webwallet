angular.module("app").controller "NewContactModalController", ($scope, $modalInstance, Wallet, Utils, contact_name, action) ->
    $scope.name = contact_name if contact_name
    $scope.address = ''

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        form = @newcontact
        form.address.$invalid = false
        form.account_name.$invalid = false
        form.address.error_message = null
        form.account_name.error_message = null
        error_handler = (error) ->
            form.address.$invalid = true
            message = Utils.formatAssertException(error.data.error.message)
            form.address.error_message = if message and message.length > 2 then message else "Not valid public key"
        Wallet.wallet_add_contact_account($scope.name, $scope.address, error_handler).then (response) ->
            Wallet.refresh_accounts()
            $modalInstance.close("ok")
            action($scope.name) if action
