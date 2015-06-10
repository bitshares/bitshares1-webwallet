angular.module("app").controller "CreateAccountController", (
    $scope, $location, $translate, Wallet, WalletAPI, Utils, Info
) ->
    $scope.f = { fully_synced: true }

    $scope.fully_synced = true
    $scope.$watch ()->
        Info.info.seconds_behind
    , (seconds_behind) ->
        $scope.f.fully_synced = seconds_behind <= Info.FULL_SYNC_SECS if seconds_behind

    $scope.createAccount = ->
        form = @createaccount
        form.account_name.$error.message = ""
        name = $scope.f.name
        return unless name
        if name.indexOf('.') isnt -1
            $translate('directive.input_name.dot_not_supported').then (message)->
                form.account_name.$error.message = message
            return
        
        if not is_cheap_name name
            $translate('directive.input_name.please_use_cheap_name').then (message)->
                form.account_name.$error.message = message
            return
        
        error_handler = (response) ->
            if response.data.error
                message = Utils.formatAssertException response.data.error.message
                form.account_name.$error.message = message
                return true
            else
                return false

        Wallet.create_account(name, error_handler).then ->
            $location.path("accounts/" + name)
    
    is_cheap_name=(account_name)->
        account_name.length > 8 or
        /[0-9]/.test(account_name) or
        not /[aeiouy]/.test(account_name) or
        /[\.\-/]/.test(account_name)
