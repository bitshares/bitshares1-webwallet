angular.module("app").controller "MarketController", ($scope, $state, $stateParams, $modal, $location, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl, Utils, MarketService) ->
    $scope.account_name = account_name = $stateParams.account
    market_name = $stateParams.name.replace('-', '/')

    MarketService.init(market_name).then ->
        MarketService.watch_for_updates()

    $scope.market = MarketService.market
    $scope.bid = new MarketService.TradeData
    $scope.ask = new MarketService.TradeData
    $scope.short = new MarketService.TradeData
    $scope.account = null
    $scope.bids = MarketService.bids
    $scope.asks = MarketService.asks
    $scope.shorts = MarketService.shorts
    $scope.trades = MarketService.trades
    $scope.unconfirmed = { bid: null, ask: null }

    # tabs
    tabsym = $scope.market.quantity_symbol
    $scope.tabs = [ { heading: "Buy #{tabsym}", route: "market.buy", active: true }, { heading: "Sell #{tabsym}", route: "market.sell", active: false }, { heading: "Short #{tabsym}", route: "market.short", active: false } ]
    $scope.goto_tab = (route) -> $state.go route
    $scope.active_tab = (route) -> $state.is route
    $scope.$on "$stateChangeSuccess", ->
        $scope.tabs.forEach (tab) -> tab.active = $scope.active_tab(tab.route)

    promise = Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        if account_name == 'no:account'
            $scope.account = false
            return
        account_balances = Wallet.balances[account_name]
        $scope.account =
            name: account_name
            quantity_balance: Utils.assetValue(account_balances[$scope.market.quantity_symbol])
            base_balance: Utils.assetValue(account_balances[$scope.market.base_symbol])
        #console.log "---- account: ", $scope.account
    $scope.showLoadingIndicator promise, 0

#    $scope.$watch 'tabs', (new_value) ->
#        return if (new_value.reduce (x,y) -> x + y) > 1
#        current_tab = if new_value[0] then 'buy' else if new_value[1] then 'sell' else 'short'
#        $location.search tab: current_tab if $stateParams.tab != current_tab
#    , true

    $scope.submit_bid = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        bid = $scope.bid
        bid.cost = bid.quantity * bid.price
        if bid.cost > $scope.account.base_balance
            form.bid_quantity.$error.message = "Insufficient funds"
            return
        $scope.unconfirmed.bid = bid

    $scope.submit_ask = ->
        form = @sell_form
        $scope.clear_form_errors(form)
        ask = $scope.ask
        ask.cost = ask.quantity * ask.price
#        if ask.cost > $scope.account.quantity_balance
#            form.ask_quantity.$error.message = "Insufficient funds"
#            return
        $scope.unconfirmed.ask = ask

    $scope.confirm_bid = ->
        bid = $scope.unconfirmed.bid
        $scope.unconfirmed.bid = null
        MarketService.add_bid(bid, true)

    $scope.cancel_bid = (id) ->
        if id == 0
            $scope.unconfirmed.bid = null
            return
        MarketService.cancel_bid(id)

    $scope.confirm_ask = ->
        ask = $scope.unconfirmed.ask
        $scope.unconfirmed.ask = null
        MarketService.add_ask(ask, true)

    $scope.cancel_ask = (id) ->
        MarketService.cancel_ask(id)

    $scope.submit_test = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        form.bid_quantity.$error.message = "some field error, please fix me"
        form.bid_price.$error.message = "another field error, please fix me"
        form.$error.message = "some error, please fix me"
#
#    Blockchain.refresh_asset_records().then ->
#        quote_asset = Blockchain.get_asset(quote_symbol)
#        base_asset = Blockchain.get_asset(base_symbol)
#        #console.log "Assets", quote_asset, base_asset
#
#        BlockchainAPI.market_list_asks(quote_symbol, base_symbol, 10).then (results)->
#            orders = []
#            for order in results
#                o = {}
#                o.quantity = {}
#                o.quantity.amount = order.state.balance
#                o.quantity.precision = base_asset.precision
#                o.price = {}
#                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
#                o.price.precision = quote_asset.precision
#                o.cost = {}
#                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
#                o.cost.precision = quote_asset.precision
#                orders.push o
#            $scope.sell_orders = orders
#
#        BlockchainAPI.market_list_bids(quote_symbol, base_symbol, 10).then (results)->
#            orders = []
#            for order in results
#                o = {}
#                o.quantity = {}
#                o.quantity.amount = order.state.balance
#                o.quantity.precision = base_asset.precision
#                o.price = {}
#                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
#                o.price.precision = quote_asset.precision
#                o.cost = {}
#                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
#                o.cost.precision = quote_asset.precision
#                orders.push o
#            $scope.buy_orders = orders
#
#        BlockchainAPI.market_list_shorts(quote_symbol, 10).then (results)->
#            shorts = []
#            console.log results
#            for order in results
#                o = {}
#                o.quantity = {}
#                o.quantity.amount = order.state.balance
#                o.quantity.precision = base_asset.precision
#                o.price = {}
#                o.price.amount = order.market_index.order_price.ratio * base_asset.precision
#                o.price.precision = quote_asset.precision
#                o.cost = {}
#                o.cost.amount = order.state.balance * order.market_index.order_price.ratio
#                o.cost.precision = quote_asset.precision
#                shorts.push o
#            $scope.short_orders = shorts
#
#        BlockchainAPI.market_price_history(quote_symbol, base_symbol, '20140715T000000', 10000000, 'each_block').then (results)->
#            console.log 'price_history ------->', results
#            trades = []
#            for trade in results
#                t = {}
#                t.timestamp = trade.timestamp
#                t.highest_bid = trade.highest_bid
#                t.lowest_ask = trade.lowest_ask
#                t.volume = {}
#                t.volume.amount = trade.volume
#                t.volume.precision = quote_asset.precision
#                trades.push t
#            $scope.trade_history = trades
#
#
#
#    $scope.submit_buy_form = ->
#        form = @buy_form
#        buy = $scope.buy
#        $modal.open
#            templateUrl: "dialog-confirmation.html"
#            controller: "DialogConfirmationController"
#            resolve:
#                title: -> "Are you sure?"
#                message: -> "This will place a request to buy #{Utils.formatMoney(buy.quantity)} #{quote_symbol} for #{Utils.formatMoney(buy.quantity * buy.price)} #{base_symbol}"
#                action: ->
#                    ->
#                        WalletAPI.market_submit_bid(account_name, buy.quantity, quote_symbol, buy.price, base_symbol).then ->
#                            buy.quantity = buy.price = ''
#                            clear_form(form)
#                            Growl.notice "", "Your bid request was successfully placed."
#                        , (error) ->
#                            form.$error.message = error.data.error.message
#
#    $scope.submit_sell_form = ->
#        sell = $scope.sell
#        $modal.open
#            templateUrl: "dialog-confirmation.html"
#            controller: "DialogConfirmationController"
#            resolve:
#                title: -> "Are you sure?"
#                message: -> "This will place a request to sell #{Utils.formatMoney(sell.quantity)} #{quote_symbol} for #{Utils.formatMoney(sell.quantity * sell.price)} #{base_symbol}"
#                action: ->
#                    ->
#                        WalletAPI.market_submit_ask(account_name, sell.quantity, quote_symbol, sell.price, base_symbol).then ->
#                            Growl.notice "", "Your ask was successfully placed."
#
#    $scope.submit_short_form = ->
#        short = $scope.short
#        $modal.open
#            templateUrl: "dialog-confirmation.html"
#            controller: "DialogConfirmationController"
#            resolve:
#                title: -> "Are you sure?"
#                message: -> "This will place a request to short #{Utils.formatMoney(short.quantity)} #{quote_symbol} for #{Utils.formatMoney(short.quantity * short.price)} #{base_symbol}"
#                action: ->
#                    ->
#                        WalletAPI.market_submit_ask(account_name, sell.quantity, quote_symbol, sell.price, base_symbol).then ->
#                            Growl.notice "", "Your ask was successfully placed."
