angular.module("app").controller "NewContactController", ($scope, $modalInstance, Wallet, addr, action) ->
    $scope.address = addr if addr

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        form = @newcontact
        form.address.$invalid = false
        form.account_name.$invalid = false
        form.address.error_message = null
        form.account_name.error_message = null
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            Wallet.refresh_accounts()
            action($scope.name) if action
            $modalInstance.close("ok")
        , (response) ->
            form.address.$invalid = true
            if response.data.error.code == 10 and response.data.error.message
                message = response.data.error.message.replace(/(\r\n|\n|\r)/gm,'')
                regex_match = message.match(/Assert\sException.+\:\s?(.+)/i)
                if regex_match and regex_match.length > 1 && regex_match[1]
                    if message.match(/Account/)
                        form.account_name.error_message = regex_match[1]
                    else
                        form.address.error_message = regex_match[1]
                else
                    form.address.error_message = message
