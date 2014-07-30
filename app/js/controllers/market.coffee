class TradeData
    constructor: ->
        @balance = null
        @quantity = null
        @price = null

angular.module("app").controller "MarketController", ($scope, $stateParams, $modal, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl, Utils) ->
    formatMoney = Utils.formatMoney
    account_name = $stateParams.account
    market_url_name = $stateParams.name
    market_name = market_url_name.replace(':', '/')
    market_symbols = market_name.split('/')
    quote_symbol = market_symbols[0]
    base_symbol = market_symbols[1]
    quote_asset = null
    base_asset = null

    buy = new TradeData
    sell = new TradeData
    short = new TradeData

    $scope.quote_symbol = quote_symbol
    $scope.base_symbol = base_symbol
    $scope.market_url_name = market_url_name
    $scope.market_name = market_name
    $scope.buy = buy
    $scope.sell = sell
    $scope.short = short
    $scope.balances = {}
    $scope.market_name = market_name

    $scope.sell_orders = []

    clear_form = (form) ->
        form.$error.message = null if form.$error.message
        for key of form
            continue if /^(\$|_)/.test key
            control = form[key]
            control.$setPristine true
            control.$valid = true
            control.$error.message = null if control.$error.message

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.account = false
        $scope.account_selector_title = 'Select Account'
        if account_name != 'no:account'
            $scope.account = true
            $scope.account_selector_title = account_name
            account_balances = Wallet.balances[account_name]
            buy.balance = account_balances[base_symbol]
            short.balance = account_balances[base_symbol]
            sell.balance = account_balances[quote_symbol]

    Blockchain.refresh_asset_records().then ->
        quote_asset = Blockchain.get_asset(quote_symbol)
        base_asset = Blockchain.get_asset(base_symbol)
        #console.log "Assets", quote_asset, base_asset

        BlockchainAPI.market_list_asks(quote_symbol, base_symbol, 10).then (results)->
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

        BlockchainAPI.market_list_bids(quote_symbol, base_symbol, 10).then (results)->
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

        BlockchainAPI.market_list_shorts(quote_symbol, 10).then (results)->
            shorts = []
            console.log results
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
                shorts.push o
            $scope.short_orders = shorts

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
        form = @buy_form
        buy = $scope.buy
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will place a request to buy #{formatMoney(buy.quantity)} #{quote_symbol} for #{formatMoney(buy.quantity * buy.price)} #{base_symbol}"
                action: ->
                    ->
                        WalletAPI.market_submit_bid(account_name, buy.quantity, quote_symbol, buy.price, base_symbol).then ->
                            buy.quantity = buy.price = ''
                            clear_form(form)
                            Growl.notice "", "Your bid request was successfully placed."
                        , (error) ->
                            form.$error.message = error.data.error.message

    $scope.submit_sell_form = ->
        sell = $scope.sell
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will place a request to sell #{formatMoney(sell.quantity)} #{quote_symbol} for #{formatMoney(sell.quantity * sell.price)} #{base_symbol}"
                action: ->
                    ->
                        WalletAPI.market_submit_ask(account_name, sell.quantity, quote_symbol, sell.price, base_symbol).then ->
                            Growl.notice "", "Your ask was successfully placed."
                            
    $scope.submit_short_form = ->
        short = $scope.short
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will place a request to short #{formatMoney(short.quantity)} #{quote_symbol} for #{formatMoney(short.quantity * short.price)} #{base_symbol}"
                action: ->
                    ->
                        WalletAPI.market_submit_ask(account_name, sell.quantity, quote_symbol, sell.price, base_symbol).then ->
                            Growl.notice "", "Your ask was successfully placed."
