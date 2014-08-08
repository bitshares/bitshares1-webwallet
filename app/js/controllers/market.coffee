angular.module("app").controller "MarketController", ($scope, $state, $stateParams, $modal, $location, $q, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl, Utils, MarketService) ->
    $scope.account_name = account_name = $stateParams.account
    $scope.bid = new MarketService.TradeData
    $scope.ask = new MarketService.TradeData
    $scope.short = new MarketService.TradeData
    $scope.account = null

    market_name = $stateParams.name
    promise = MarketService.init(market_name).then (market) ->
        MarketService.watch_for_updates()
        $scope.market = market
        $scope.actual_market = market.get_actual_market()
        $scope.market_inverted_url = MarketService.inverted_url
        $scope.bids = MarketService.bids
        $scope.asks = MarketService.asks
        $scope.shorts = MarketService.shorts
        $scope.covers = MarketService.covers
        $scope.trades = MarketService.trades
        $scope.orders = MarketService.orders
    , (error) ->
        Growl.error "", error
    $scope.showLoadingIndicator $q.all([promise,MarketService.loading_promise]), 0

    promise = Wallet.refresh_accounts().then ->
        $scope.is_refreshing = false
        $scope.accounts = Wallet.accounts
        if account_name == 'no:account'
            $scope.account = false
            return
        account_balances = Wallet.balances[account_name]
        $scope.account =
            name: account_name
            quantity_balance: Utils.assetValue(account_balances[MarketService.quantity_symbol])
            base_balance: Utils.assetValue(account_balances[MarketService.base_symbol])
    $scope.showLoadingIndicator promise, 0

    # tabs
    tabsym = MarketService.quantity_symbol
    $scope.tabs = [ { heading: "Buy #{tabsym}", route: "market.buy", active: true }, { heading: "Sell #{tabsym}", route: "market.sell", active: false }, { heading: "Short #{tabsym}", route: "market.short", active: false } ]
    $scope.goto_tab = (route) -> $state.go route
    $scope.active_tab = (route) -> $state.is route
    $scope.$on "$stateChangeSuccess", ->
        #$scope.state_name = $state.current.name
        $scope.tabs.forEach (tab) -> tab.active = $scope.active_tab(tab.route)

    $scope.$on "$destroy", ->
        MarketService.stop_updates()

    $scope.flip_market = ->
        console.log "flip market"
        $state.go('^.buy', {name: $scope.market.inverted_url})

    $scope.cancel_order = (id) ->
        res = MarketService.cancel_order(id)
        return unless res
        res.then -> Growl.notice "", "Your order was canceled."

    $scope.submit_bid = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        bid = $scope.bid
        bid.cost = bid.quantity * bid.price
        if bid.cost > $scope.account.base_balance
            form.bid_quantity.$error.message = "Insufficient funds"
            return
        bid.type = "bid_order"
        $scope.account.base_balance -= bid.cost
        MarketService.add_unconfirmed_order(bid)

    $scope.submit_ask = ->
        form = @sell_form
        $scope.clear_form_errors(form)
        ask = $scope.ask
        ask.cost = ask.quantity * ask.price
        if ask.quantity > $scope.account.quantity_balance
            form.ask_quantity.$error.message = "Insufficient balance"
            return
        ask.type = "ask_order"
        MarketService.add_unconfirmed_order(ask)

    $scope.submit_short = ->
        form = @short_form
        $scope.clear_form_errors(form)
        short = $scope.short
        short.cost = short.quantity * short.price
        if short.cost > $scope.account.base_balance
            form.ask_quantity.$error.message = "Insufficient funds"
            return
        short.type = "short_order"
        MarketService.add_unconfirmed_order(short)

    $scope.confirm_order = (id) ->
        MarketService.confirm_order(id, $scope.account).then (order) ->
            if order.type == "bid_order" or order.type == "ask_order"
                $scope.account.base_balance -= order.cost
            else if order.type == "ask_order"
                $scope.account.quantity_balance -= order.cost
            Growl.notice "", "Your order was successfully placed."
        , (error) ->
            console.log "--- $scope.confirm_order error: ", error
            Growl.error "", "Order failed."

    $scope.use_trade_data = (data) ->
        order = switch $state.current.name
            when "market.sell" then $scope.ask
            when "market.short" then $scope.short
            else $scope.bid
        order.price = data.price
        order.quantity = data.quantity

    $scope.submit_test = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        form.bid_quantity.$error.message = "some field error, please fix me"
        form.bid_price.$error.message = "another field error, please fix me"
        form.$error.message = "some error, please fix me"
