angular.module("app").controller "MarketController", ($scope, $stateParams, Wallet, Blockchain) ->

    $scope.current_account = null
    $scope.current_account_selector_title = 'Select Account'
    $scope.current_account_name = $stateParams.account
    $scope.buy_balance = 0.0
    $scope.buy_quantity = 0
    $scope.buy_quote_price = 0
    $scope.current_market = null
    $scope.balances = {}
    $scope.current_market_url_name = $stateParams.name
    $scope.current_market = $stateParams.name.replace(':', '/')
    $scope.quantity_symbol = $scope.current_market.split('/')[0]
    $scope.quote_symbol = $scope.current_market.split('/')[1]

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.balances = Wallet.balances
        if $scope.current_account_name != 'no:account'
            $scope.current_account = Wallet.accounts[$scope.current_account_name]
            $scope.current_account_selector_title = $scope.current_account.name
            $scope.buy_balance = $scope.balances[$scope.current_account_name][$scope.quote_symbol]

#    Blockchain.price_history($scope.quote_symbol, $scope.quantity_symbol, '20140101T213806', 10000000, 'each_block').then (result)->
#        console.log '------->', result
#
#    Blockchain.refresh_asset_records().then ->
#        #console.log 'asset_records', Blockchain.asset_records

