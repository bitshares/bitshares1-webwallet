angular.module("app").controller "TransactionsController", ($scope, $attrs, $location, $stateParams, $state, Wallet, Utils, Info, Blockchain) ->
    $scope.name = $stateParams.name || "*"
    $scope.transactions = Wallet.transactions
    $scope.account_transactions = Wallet.transactions[$scope.name]
    $scope.utils = Utils
    $scope.pending_only = false
    $scope.warning = ""

    $scope.showBalances = $location.$$path.indexOf("/accounts/") == 0

    if $attrs.model and $attrs.model = "pending_only"
        $scope.pending_only = true

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        Wallet.refresh_transactions_on_new_block()

    $scope.$watchCollection "transactions", () ->
        $scope.account_transactions = Wallet.transactions[$scope.name]
        console.log('Wallet.transactions[$scope.name]', Wallet.transactions[$scope.name])
        $scope.warning = ""
        if !$scope.account_transactions || $scope.account_transactions.length == 0
            $scope.warning = if $scope.pending_only then "There are no pending transactions!" else "There are no transactions!"
        else if $scope.pending_only
            have_pending = false
            for a in $scope.account_transactions
                if a.block_num == 0
                    have_pending = true
                    break
            if !have_pending
                $scope.warning = "There are no pending trasanctions!"

    $scope.$watch watch_for, on_update, true

    Wallet.refresh_transactions($stateParams.name)
