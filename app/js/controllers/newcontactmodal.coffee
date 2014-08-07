angular.module("app").controller "NewContactModalController", ($scope, $modalInstance, Wallet, contact_name, action) ->
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
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            Wallet.refresh_accounts()
            $modalInstance.close("ok")
            action($scope.name) if action
        , (response) ->
            form.address.$invalid = true
            if response.data.error.code == 10 and response.data.error.message
                message = response.data.error.message.replace(/(\r\n|\n|\r)/gm,'')
                regex_match = message.match(/Assert\sException.+\:\s?(.+)/i)
                if regex_match and regex_match.length > 1
                    message = regex_match[1].trim()
                    if message
                        if message.match(/Account/)
                            form.account_name.error_message = message
                        else
                            form.address.error_message = message
                    else
                        form.address.error_message = "Not valid pulic key"
                else
                    form.address.error_message = message
