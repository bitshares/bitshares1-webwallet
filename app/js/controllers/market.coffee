class TradeData
    constructor: ->
        @balance = null
        @quantity = null
        @quantity_symbol = null
        @price = null
        @price_symbol = null

angular.module("app").controller "MarketController", ($scope, $stateParams, $modal, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl) ->
    account_name = $stateParams.account
    market_url_name = $stateParams.name
    market_name = market_url_name.replace(':', '/')
    market_symbols = market_name.split('/')
    quote_symbol = market_symbols[0]
    base_symbol = market_symbols[1]
    quote_asset = null
    base_asset = null

    buy = new TradeData
    buy.quantity_symbol = quote_symbol
    buy.price_symbol = base_symbol

    sell = new TradeData
    sell.quantity_symbol = base_symbol
    sell.price_symbol = quote_symbol

    $scope.market_url_name = market_url_name
    $scope.market_name = market_name
    $scope.buy = buy
    $scope.sell = sell
    $scope.balances = {}
    $scope.market_name = market_name

    $scope.sell_orders = []

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.account = false
        $scope.account_selector_title = 'Select Account'
        if account_name != 'no:account'
            $scope.account = true
            $scope.account_selector_title = account_name
            account_balances = Wallet.balances[account_name]
            buy.balance = account_balances[buy.price_symbol]

    Blockchain.refresh_asset_records().then ->
        quote_asset = Blockchain.get_asset(quote_symbol)
        base_asset = Blockchain.get_asset(base_symbol)
        #console.log "Assets", quote_asset, base_asset

        BlockchainAPI.market_list_asks(buy.quantity_symbol, buy.price_symbol, 10).then (results)->
            orders = []
            for order in results
                o = {}
                o.quantity = {}
                o.quantity.amount = order.state.balance
                o.quantity.precision = base_asset.precision
                o.price = {}
                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
                o.price.precision = quote_asset.precision
                o.cost = {}
                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
                o.cost.precision = quote_asset.precision
                orders.push o
            $scope.sell_orders = orders

        BlockchainAPI.market_list_bids(buy.quantity_symbol, buy.price_symbol, 10).then (results)->
            orders = []
            for order in results
                o = {}
                o.quantity = {}
                o.quantity.amount = order.state.balance
                o.quantity.precision = base_asset.precision
                o.price = {}
                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
                o.price.precision = quote_asset.precision
                o.cost = {}
                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
                o.cost.precision = quote_asset.precision
                orders.push o
            $scope.buy_orders = orders

        BlockchainAPI.market_price_history(quote_symbol, base_symbol, '20140715T000000', 10000000, 'each_block').then (results)->
            console.log 'price_history ------->', results
            trades = []
            for trade in results
                t = {}
                t.timestamp = trade.timestamp
                t.highest_bid = trade.highest_bid
                t.lowest_ask = trade.lowest_ask
                t.volume = {}
                t.volume.amount = trade.volume
                t.volume.precision = quote_asset.precision
                trades.push t
            $scope.trade_history = trades



    $scope.submit_buy_form = ->
        if !@buy_form.$valid
            Growl.error "", "Your bid cannot be placed. Please fix errors on the buy form."
            return
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
                            Growl.notice "", "Your bid request was successfully placed."

    $scope.submit_sell_form = ->
        if !@sell_form.$valid
            Growl.error "", "Your ask cannot be placed. Please fix errors on the sell form."
            return
        sell = $scope.sell
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will place a request to sell #{sell.quantity} #{sell.quantity_symbol} for #{sell.quantity * sell.price} #{sell.price_symbol}"
                action: ->
                    ->
                        WalletAPI.market_submit_ask(account_name, sell.quantity, sell.quantity_symbol, sell.price, sell.price_symbol).then ->
                            Growl.notice "", "Your ask was successfully placed."
