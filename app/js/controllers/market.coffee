angular.module("app").controller "MarketController", ($scope, $stateParams, Wallet, Blockchain) ->

    $scope.current_account = null
    $scope.current_account_selector_title = 'Select Account'
    $scope.current_account_name = $stateParams.account
    $scope.buy_balance = 0.0
    $scope.buy_quantity = 0
    $scope.quantity_symbol = ''
    $scope.buy_quote_price = 0
    $scope.buy_quote_symbol = ''
    $scope.current_market = null
    $scope.balances = {}
    $scope.current_market_url_name = $stateParams.name
    $scope.current_market = $stateParams.name.replace(':', '/')
    $scope.quantity_symbol = $scope.current_market.split('/')[0]
    $scope.buy_quote_symbol = $scope.current_market.split('/')[1]

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.balances = Wallet.balances
        if $scope.current_account_name != 'no:account'
            console.log "balances----------", $scope.current_account_name, $scope.balances[$scope.current_account_name]
            $scope.current_account = Wallet.accounts[$scope.current_account_name]
            $scope.current_account_selector_title = $scope.current_account.name
            $scope.buy_balance = $scope.balances[$scope.current_account_name][$scope.buy_quote_symbol]

    Blockchain.refresh_asset_records().then ->
        #console.log 'asset_records', Blockchain.asset_records

    $scope.$watch 'current_account', (value) ->
        #console.log '-------current-account->', value
#        if newVal and newVal != oldVal
#            $scope.buy_balance = $scope.balances[newVal]
#            $scope.buy_balance = 111.0
