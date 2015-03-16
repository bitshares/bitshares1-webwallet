angular.module("app").controller "TransactionsController", ($scope, $filter, $location, $stateParams, $rootScope, $q, Wallet, Utils, Info, WalletAPI) ->
    $scope.name = $stateParams.name || "*"
    #$scope.transactions = Wallet.transactions
    $scope.account_transactions = Wallet.transactions[$scope.name]

    $scope.utils = Utils
    $scope.pending_only = false
    $scope.warning = ""

    $scope.p = {currentPage : 0, pageSize : 20, numberOfPages : 0}
    $scope.q = {}

    refresh_data = ->
        return unless $scope.account_transactions
        $scope.p.numberOfPages = Math.ceil($scope.account_transactions.length / $scope.p.pageSize)
        $scope.warning = ""
        if !$scope.account_transactions || $scope.account_transactions.length == 0
            $scope.warning = if $scope.pending_only then "tip.no_pending_trxs" else "tip.no_trxs"
        else if $scope.pending_only
            have_pending = false
            for a in $scope.account_transactions
                if a.block_num == 0
                    have_pending = true
                    break
            if !have_pending
                $scope.warning = "tip.no_pending_trxs"


    refresh_transactions_deferred = $q.defer()
    if $scope.accounts
        Wallet.refresh_transactions().then ->
            refresh_transactions_deferred.resolve()
    else
        Wallet.refresh_accounts(true).then ->
            $scope.accounts = Wallet.accounts
            Wallet.refresh_transactions().then ->
                refresh_transactions_deferred.resolve()

    #refresh_transactions_deferred.promise.then ->
    $scope.account_transactions = Wallet.transactions[$scope.name]

    $scope.$watch ( -> Info.info.last_block_time ), ( -> Wallet.refresh_transactions() ), true

    $scope.$watchCollection "account_transactions", -> refresh_data()

    $scope.$watch 'q.q', ->
        if $scope.account_transactions
            $scope.p.numberOfPages = Math.ceil(($filter("filter")($scope.account_transactions,  $scope.q.q)).length/$scope.p.pageSize)
            $scope.p.currentPage = 0


    $scope.showBalances = $location.$$path.indexOf("/accounts/") == 0

    if $stateParams.pending_only
        $scope.pending_only = true

    refresh_data()

    $scope.rebroadcastTransaction = (t) ->
        WalletAPI.rebroadcast_transaction(t.id)
        t.status = "rebroadcasted"
