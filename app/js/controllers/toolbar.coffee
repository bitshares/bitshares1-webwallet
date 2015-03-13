angular.module("app").controller "ToolbarController", ($scope, $state, $rootScope, Shared, Wallet) ->

    $scope.current_account = null
    $scope.accounts = []

    $scope.$watch ->
        Wallet.current_account
    , (value) ->
        return unless value
        $rootScope.current_account = $scope.current_account = value.name

    $scope.$watch ->
        Wallet.accounts
    , (all_accounts) ->
        return unless all_accounts
        $scope.accounts.splice(0, $scope.accounts.length)
        $scope.accounts.push(name) for name, a of all_accounts #when a.is_my_account #and name != $scope.current_account
    , true

    $scope.back = ->
        $scope.history_back()

    $scope.forward = ->
        $scope.history_forward()

    $scope.open_context_help = ->
        $scope.context_help.open = true

    errors = $scope.errors = Shared.errors

    $scope.error_notifier_toggled = (open) ->
        if open
            e.details = null for e in errors.list
        else
            errors.new_error = false

    $scope.lock = ->
        Wallet.wallet_lock().finally ->
            unless is_bitshares_js
                navigate_to('unlockwallet')

    $scope.switch_account = (account) ->
        if $state.params?.account
            params = angular.copy($state.params)
            params.account = account
            $state.go($state.current.name, params)
        else if $state.current?.name and $state.current.name.indexOf("account.") == 0
            $state.go($state.current.name, {name: account})
        else
            $state.go("account.transactions", {name: account})
        return null
