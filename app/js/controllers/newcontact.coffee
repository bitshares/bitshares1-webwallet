angular.module("app").controller "NewContactController", ($scope, $location, $stateParams, Wallet, Utils) ->
    $scope.account_name = $stateParams.name
    $scope.address = $stateParams.key

    $scope.createContact = ->
        form = @newcontact
        form.account_name.$invalid = false
        form.account_name.error_message = null
        form.address.$invalid = false
        form.address.error_message = null
        error_handler = (error) ->
            form.address.$invalid = true
            message = Utils.formatAssertException(error.data.error.message)
            form.address.error_message = if message and message.length > 2 then message else "Not valid public key"
        Wallet.wallet_add_contact_account($scope.account_name, $scope.address, error_handler).then (response) ->
            Wallet.refresh_accounts()
            $location.path "accounts/#{$scope.account_name}"
