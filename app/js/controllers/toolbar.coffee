angular.module("app").controller "ToolbarController", ($scope, $rootScope, Shared, Wallet) ->

    $scope.current_account = null
    $scope.accounts = []

    $scope.$watch ->
        Wallet.current_account
    , (value) ->
        console.log "------ current_account ------>", value
        return unless value
        $scope.current_account = value.name

    $scope.$watch ->
        Wallet.accounts
    , (all_accounts) ->
        return unless all_accounts
        $scope.accounts.splice(0, $scope.accounts.length)
        $scope.accounts.push(name) for name, a of all_accounts when a.is_my_account and name != $scope.current_account
        console.log "------ Wallet.accounts ------>", all_accounts, $scope.accounts
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
        Wallet.wallet_lock().then ->
            navigate_to('unlockwallet')
