class TradeData
    constructor: ->
        @balance = null
        @quantity = null
        @quantity_symbol = null
        @price = null
        @price_symbol = null

angular.module("app").controller "MarketController", ($scope, $stateParams, $modal, Wallet, WalletAPI, Blockchain, BlockchainAPI) ->
    $scope.current_account_selector_title = 'Select Account'
<<<<<<< HEAD
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
=======
    account_name = $stateParams.account
    market_url_name = $stateParams.name
    market_name = market_url_name.replace(':', '/')
    market_legs = market_name.split('/')

    $scope.market_url_name = market_url_name
    $scope.market_name = market_name

    buy = new TradeData
    buy.quantity_symbol = market_legs[0]
    buy.price_symbol = market_legs[1]
    $scope.buy = buy

    $scope.balances = {}
    $scope.market_name = market_name

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.account = false
        $scope.account_selector_title = 'Select Account'
        if account_name != 'no:account'
            $scope.account = true
            $scope.account_selector_title = account_name
            account_balances = Wallet.balances[account_name]
            buy.balance = account_balances[buy.price_symbol]

#    Blockchain.price_history($scope.quote_symbol, $scope.quantity_symbol, '20140101T213806', 10000000, 'each_block').then (result)->
#        console.log '------->', result

    $scope.submit_buy_form = ->
        console.log $scope.buy
        buy = $scope.buy
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will place a request to buy #{buy.quantity} #{buy.quantity_symbol} for #{buy.quantity * buy.price} #{buy.price_symbol}"
                action: ->
                    ->
                        WalletAPI.market_submit_bid(account_name, buy.quantity, buy.quantity_symbol, buy.price, buy.price_symbol).then ->
                            Growl.notice "", "Your bid was successfully placed."
>>>>>>> FETCH_HEAD

