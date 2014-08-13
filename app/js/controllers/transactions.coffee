angular.module("app").controller "TransactionsController", ($scope, $filter, $attrs, $location, $stateParams, $state, Wallet, Utils, Info, Blockchain) ->
    $scope.name = $stateParams.name || "*"
    $scope.transactions = Wallet.transactions
    $scope.account_transactions = Wallet.transactions[$scope.name]
    $scope.utils = Utils
    $scope.pending_only = false
    $scope.warning = ""

    $scope.p = 
        currentPage : 0
        pageSize : 20
        numberOfPages : 0
    $scope.q = {}

    $scope.$watch('q.q', ->
        $scope.p.numberOfPages = Math.ceil(($filter("filter")($scope.account_transactions,  $scope.q.q)).length/$scope.p.pageSize)
        $scope.p.currentPage = 0
    )
    if(!$stateParams.name)
        $scope.accounts=Wallet.accounts
        Wallet.refresh_accounts().then ->
            $scope.accounts=Wallet.accounts

    $scope.showBalances = $location.$$path.indexOf("/accounts/") == 0

    if $attrs.model and $attrs.model = "pending_only"
        $scope.pending_only = true

    watch_for = ->
        Info.info.last_block_time

    on_update = (last_block_time) ->
        Wallet.refresh_transactions_on_new_block()

    $scope.$watchCollection "transactions", () ->
        $scope.account_transactions = Wallet.transactions[$scope.name]
        $scope.p.numberOfPages = Math.ceil($scope.account_transactions.length/$scope.p.pageSize)
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

    Wallet.refresh_transactions($stateParams.name).then () ->
        console.log('Wallet.transactions', Wallet.transactions)
