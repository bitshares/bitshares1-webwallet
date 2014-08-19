angular.module("app").controller "MarketController", ($scope, $state, $stateParams, $modal, $location, $q, $log, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl, Utils, MarketService, Observer) ->
    $scope.account_name = account_name = $stateParams.account
    return if not account_name or account_name == 'no:account'
    $scope.bid = new MarketService.TradeData
    $scope.ask = new MarketService.TradeData
    $scope.short = new MarketService.TradeData
    $scope.accounts = []
    $scope.account = account = {name: account_name, base_balance: 0.0, quantity_balance: 0.0}
    current_market = null

    # tabs
    $scope.tabs = []
    $scope.tabs.push { heading: "Buy", route: "market.buy", active: true }
    $scope.tabs.push { heading: "Sell", route: "market.sell", active: false }
    $scope.tabs.push { heading: "Short", route: "market.short", active: false }
    $scope.goto_tab = (route) -> $state.go route
    $scope.active_tab = (route) -> $state.is route
    $scope.$on "$stateChangeSuccess", ->
        #$scope.state_name = $state.current.name
        $scope.tabs.forEach (tab) -> tab.active = $scope.active_tab(tab.route)

    $scope.xAxisTickFormat = ->
        return (d) ->
            return d3.time.format('%H:%M')(new Date(d))

    Wallet.get_account(account.name).then (acct)->
        Wallet.current_account = acct

    account_balances_observer =
        name: "account_balances_observer"
        frequency: 2600
        update: (data, deferred) ->
            changed = false
            promise = WalletAPI.account_balance(account_name)
            promise.then (result) =>
                #console.log "------ account_balances_observer result ------>", result
                return if !result or result.length == 0
                name_bal_pair = result[0]
                balances = name_bal_pair[1][0]
                angular.forEach balances, (symbol_amt_pair) =>
                    symbol = symbol_amt_pair[0]
                    if data[symbol] != undefined
                        value = symbol_amt_pair[1]
                        if data[symbol] != value
                            changed = true
                            data[symbol] = value
            promise.finally -> deferred.resolve(changed)

    market_data_observer =
        name: "market_data_observer"
        frequency: 2000
        data: {context: MarketService, account_name: account.name}
        update: MarketService.pull_market_data

    market_status_observer =
        name: "market_status_observer"
        frequency: 3000
        data: {context: MarketService}
        update: MarketService.pull_market_status

    market_name = $stateParams.name
    promise = MarketService.init(market_name)
    promise.then (market) ->
        $scope.market = current_market = market
        $scope.actual_market = market.get_actual_market()
        $scope.market_inverted_url = MarketService.inverted_url
        $scope.bids = MarketService.bids
        $scope.asks = MarketService.asks
        $scope.shorts = MarketService.shorts
        $scope.covers = MarketService.covers
        $scope.trades = MarketService.trades
        $scope.orders = MarketService.orders
        tabsym = market.quantity_symbol
        $scope.tabs[0].heading = "Buy #{tabsym}"
        $scope.tabs[1].heading = "Sell #{tabsym}"
        if market.shorts_available
            $scope.tabs[2].heading = "Short #{tabsym}"
        else
            $scope.tabs.splice(2,1)
        Observer.registerObserver(market_data_observer)
        Observer.registerObserver(market_status_observer)
        balances = {}
        balances[market.base_symbol] = 0.0
        balances[market.quantity_symbol] = 0.0
        account_balances_observer.data = balances
        account_balances_observer.notify = (data) ->
            account.base_balance = data[market.base_symbol] / market.base_precision
            account.quantity_balance = data[market.quantity_symbol] / market.quantity_precision
        Observer.registerObserver(account_balances_observer)
    promise.catch (error) -> Growl.error("", error)
    $scope.showLoadingIndicator(promise)

    Wallet.refresh_accounts().then ->
        $scope.accounts.splice(0, $scope.accounts.lenght)
        for k,a of Wallet.accounts
            $scope.accounts.push a if a.is_my_account

    $scope.$on "$destroy", ->
        Observer.unregisterObserver(market_data_observer)
        Observer.unregisterObserver(market_status_observer)
        Observer.unregisterObserver(account_balances_observer)

    $scope.flip_market = ->
        console.log "flip market"
        $state.go('^.buy', {name: $scope.market.inverted_url})

    $scope.cancel_order = (id) ->
        res = MarketService.cancel_order(id)
        return unless res
        #res.then -> Growl.notice "", "Your order was canceled."

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
        if $scope.market.lowest_ask > 0
            price_diff = 100.0 * bid.price / $scope.market.lowest_ask - 100
            if price_diff > 5
                bid.warning = "Your bid price is #{Utils.formatDecimal(price_diff, 1)}% higher than the lowest ask."
        MarketService.add_unconfirmed_order(bid)
        $scope.bid = new MarketService.TradeData

    $scope.submit_ask = ->
        form = @sell_form
        $scope.clear_form_errors(form)
        ask = $scope.ask
        ask.cost = ask.quantity * ask.price
        if ask.quantity > $scope.account.quantity_balance
            form.ask_quantity.$error.message = "Insufficient balance"
            return
        ask.type = "ask_order"
        if $scope.market.highest_bid > 0
            price_diff = 100 - 100.0 * ask.price / $scope.market.highest_bid
            if price_diff > 5
                ask.warning = "Your ask price is #{Utils.formatDecimal(price_diff, 1)}% lower than the highest bid."
        MarketService.add_unconfirmed_order(ask)
        $scope.ask = new MarketService.TradeData

    $scope.submit_short = ->
        form = @short_form
        $scope.clear_form_errors(form)
        short = $scope.short
        if short.price < $scope.market.min_short_price
            form.short_price.$error.message = "Short price should be above min price"
            return
        short.cost = short.quantity * short.price
        if short.cost > $scope.account.base_balance
            form.short_quantity.$error.message = "Insufficient funds"
            return
        short.type = "short_order"
        if $scope.market.highest_bid > 0
            price_diff = 100 - 100.0 * short.price / $scope.market.highest_bid
            if price_diff > 5
                short.warning = "Your short price is #{Utils.formatDecimal(price_diff, 1)}% lower than the highest bid."
        MarketService.add_unconfirmed_order(short)
        $scope.short = new MarketService.TradeData

    $scope.confirm_order = (id) ->
        MarketService.confirm_order(id, $scope.account).then (order) ->
            if order.type == "bid_order" or order.type == "ask_order"
                $scope.account.base_balance -= order.cost
            else if order.type == "ask_order"
                $scope.account.quantity_balance -= order.cost
            #Growl.notice "", "Your order was successfully placed."
        , (error) ->
            Growl.error "", "Order failed: " + error.data.error.message

    $scope.use_trade_data = (data) ->
        order = switch $state.current.name
            when "market.sell" then $scope.ask
            when "market.short" then $scope.short
            else $scope.bid
        order.price = Utils.formatDecimal(data.price, $scope.market.price_precision) if data.price
        order.quantity = data.quantity if data.quantity

    $scope.submit_test = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        form.bid_quantity.$error.message = "some field error, please fix me"
        form.bid_price.$error.message = "another field error, please fix me"
        form.$error.message = "some error, please fix me"

    $scope.cover_order = (order) ->
        $modal.open
            template: '''
                <div class="modal-header bg-danger">
                    <h3 class="modal-title">Cover short position</h3>
                </div>
                <form name="cover_form" class="form-horizontal" role="form" novalidate>
                <div class="modal-body">
                    <div form-hgroup label="Quantity" addon="{{market.base_symbol}}" class="col-sm-8">
                      <input-positive-number name="quantity" ng-model="order.quantity" required="true" />
                    </div>
                </div></br></br>
                <div class="modal-footer">
                    <button class="btn btn-primary" ng-click="submit(order)">Cover</button>
                    <button class="btn btn-warning" ng-click="cancel()" translate>cancel</button>
                </div>
                </form>
            '''
            controller: ["$scope", "$modalInstance", (scope, modalInstance) ->
                scope.market = current_market.actual_market or current_market
                if !current_market.inverted
                    order = order.invert()
                scope.order = order
                scope.cancel = ->
                    modalInstance.dismiss "cancel"
                scope.submit = (order) ->
                    form = @cover_form
                    MarketService.cover_order(order, account).then ->
                        modalInstance.dismiss "ok"
                    , (error) ->
                        form.quantity.$error.message = error.data.error.message
            ]
