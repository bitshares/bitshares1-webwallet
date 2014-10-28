angular.module("app").controller "ToolbarController", ($scope, $rootScope, Shared, Wallet) ->

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
