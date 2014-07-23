angular.module("app").controller "NewContactController", ($scope, $modalInstance, Wallet, addr, action) ->
    $scope.address = addr if addr

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        form = @newcontact
        form.address.$invalid = false
        form.address.error_message = null
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            Wallet.refresh_accounts()
            action($scope.name) if action
            $modalInstance.close("ok")
        , (response) ->
            form.address.$invalid = true
            if response.data.error.code == 10
                regex_match = response.data.error.message?.match(/\: ([\w\s\d]+)\./)
                if regex_match and regex_match.length > 1
                    form.address.error_message = regex_match[1]
                else
                    form.address.error_message = response.data.error.message
