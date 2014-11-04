angular.module("app").controller "MarketController", ($scope, $state, $stateParams, $modal, $location, $q, $log, $filter, Wallet, WalletAPI, Blockchain, BlockchainAPI, Growl, Utils, MarketService, Observer, MarketGrid) ->
    $scope.showContextHelp "market"
    $scope.account_name = account_name = $stateParams.account
    return if not account_name or account_name == 'no:account'
    $scope.bid = new MarketService.TradeData
    $scope.ask = new MarketService.TradeData
    $scope.short = new MarketService.TradeData
    $scope.accounts = []
    $scope.account = account = {name: account_name, base_balance: 0.0, quantity_balance: 0.0}
    $scope.avg_price = 0
    $scope.advanced = false
    current_market = null
    price_decimals = 4

    $scope.listBuyGrid = MarketGrid.initGrid()
    $scope.listSellGrid = MarketGrid.initGrid()
    $scope.listShortsMarginsLeftGrid = MarketGrid.initGrid()
    $scope.listShortsMarginsRightGrid = MarketGrid.initGrid()
    $scope.listBlockchainOrders = MarketGrid.initGrid()
    $scope.listAccountOrders = MarketGrid.initGrid()

    $scope.tabs = [
        { heading: "market.buy", route: "market.buy", active: true, class: "tab-buy" },
        { heading: "market.sell", route: "market.sell", active: false, class: "tab-sell" },
        { heading: "market.short", route: "market.short", active: false, class: "tab-short" }
    ]

    $scope.goto_tab = (route) ->
        $state.go route
    $scope.active_tab = (route) ->
        $state.is route
    $scope.$on "$stateChangeSuccess", ->
        $scope.tabs.forEach (tab) ->
            tab.active = $scope.active_tab(tab.route)

    Wallet.get_account(account.name).then (acct) ->
        Wallet.set_current_account(acct)

    account_balances_observer =
        name: "account_balances_observer"
        frequency: "each_block"
        update: (data, deferred) ->
            changed = false
            promise = WalletAPI.account_balance(account_name)
            promise.then (result) =>
                #console.log "------ account_balances_observer result ------>", result
                return if !result or result.length == 0
                name_bal_pair = result[0]
                balances = name_bal_pair[1]
                angular.forEach balances, (asset_id_amt_pair) =>
                    asset_id = asset_id_amt_pair[0]
                    asset_record = Blockchain.asset_records[asset_id]
                    symbol = asset_record.symbol
                    if data[symbol] != undefined
                        value = asset_id_amt_pair[1]
                        if data[symbol] != value
                            changed = true
                            data[symbol] = value
            promise.finally ->
                deferred.resolve(changed)


    market_data_observer =
        name: "market_data_observer"
        frequency: "each_block"
        data: {context: MarketService, account_name: account.name}
        update: MarketService.pull_market_data

    market_status_observer =
        name: "market_status_observer"
        frequency: "each_block"
        data: {context: MarketService}
        update: MarketService.pull_market_status


    market_name = $stateParams.name
    promise = MarketService.init(market_name)
    promise.then (market) ->
        $scope.tabs.forEach (tab) ->
            tab.active = $scope.active_tab(tab.route)
        $scope.market = current_market = market
        $scope.actual_market = market.get_actual_market()
        $scope.market_inverted_url = MarketService.inverted_url
        $scope.bids = MarketService.bids
        MarketGrid.setupBidsAsksGrid($scope.listBuyGrid, MarketService.bids, market, "desc")
        MarketGrid.setupBidsAsksGrid($scope.listSellGrid, MarketService.asks, market, "asc")
        MarketGrid.setupAccountOrdersGrid($scope.listAccountOrders, MarketService.my_trades, market)
        if market.inverted
            MarketGrid.setupMarginsGrid($scope.listShortsMarginsLeftGrid, MarketService.covers, market)
            MarketGrid.setupShortsGrid($scope.listShortsMarginsRightGrid, MarketService.shorts, market)
        else
            MarketGrid.setupMarginsGrid($scope.listShortsMarginsRightGrid, MarketService.covers, market)
            MarketGrid.setupShortsGrid($scope.listShortsMarginsLeftGrid, MarketService.shorts, market)
        MarketGrid.setupBlockchainOrdersGrid($scope.listBlockchainOrders, MarketService.trades, market)
        MarketGrid.disableMouseScroll()

        $scope.asks = MarketService.asks
        $scope.shorts = MarketService.shorts
        $scope.covers = MarketService.covers
        $scope.trades = MarketService.trades
        $scope.my_trades = MarketService.my_trades
        $scope.orders = MarketService.orders
        if market.shorts_available
            Wallet.get_setting("market.advanced").then (result) ->
                $scope.advanced = (if result then result.value else false)
        price_decimals = if market.price_precision > 9 then (market.price_precision + "").length - 2 else market.price_precision - 2
        Observer.registerObserver(market_data_observer)
        Observer.registerObserver(market_status_observer)
        balances = {}
        balances[market.asset_base_symbol] = 0.0
        balances[market.asset_quantity_symbol] = 0.0
        account_balances_observer.data = balances
        account_balances_observer.notify = (data) ->
            account.base_balance = data[market.asset_base_symbol] / market.base_precision
            account.quantity_balance = data[market.asset_quantity_symbol] / market.quantity_precision
            account.short_balance = if market.inverted then account.base_balance else account.quantity_balance
        Observer.registerObserver(account_balances_observer)

        Blockchain.get_asset($scope.actual_market.base_asset.id).then (asset) ->
            $scope.asset_total_supply = asset.current_share_supply / asset.precision
        Blockchain.get_info().then (config) ->
            $scope.blockchain_symbol = config.symbol #XTS or BTSX
            WalletAPI.get_transaction_fee($scope.blockchain_symbol).then (blockchain_tx_fee) ->
                Blockchain.get_asset(blockchain_tx_fee.asset_id).then (blockchain_tx_fee_asset) ->
                    $scope.blockchain_tx_fee = Utils.formatDecimal(blockchain_tx_fee.amount / blockchain_tx_fee_asset.precision, blockchain_tx_fee_asset.precision)
        WalletAPI.get_transaction_fee(market.asset_base_symbol).then (tx_fee) ->
            Blockchain.get_asset(tx_fee.asset_id).then (asset) ->
                $scope.tx_fee = Utils.formatDecimal(tx_fee.amount / asset.precision, asset.precision)
                if market.asset_base_symbol == $scope.actual_market.asset_base_symbol
                     $scope.asset_tx_fee = $scope.tx_fee
        if market.asset_base_symbol != $scope.actual_market.asset_base_symbol
            WalletAPI.get_transaction_fee($scope.actual_market.asset_base_symbol).then (tx_fee) ->
                Blockchain.get_asset(tx_fee.asset_id).then (asset) ->
                    $scope.asset_tx_fee = Utils.formatDecimal(tx_fee.amount / asset.precision, asset.precision)

    promise.catch (error) ->
        Growl.error("", error)
    $scope.showLoadingIndicator(promise)

    Wallet.refresh_accounts().then ->
        $scope.accounts.splice(0, $scope.accounts.length)
        for k,a of Wallet.accounts
            $scope.accounts.push a if a.is_my_account

    $scope.excludeOutOfRange = (item) ->
        not item.out_of_range

    $scope.$on "$destroy", ->
        $scope.showContextHelp false
        MarketService.orders = []
        MarketService.my_trades = []
        Observer.unregisterObserver(market_data_observer)
        Observer.unregisterObserver(market_status_observer)
        Observer.unregisterObserver(account_balances_observer)

    $scope.flip_market = ->
        #console.log "flip market"
        $state.go('^.buy', {name: $scope.market.inverted_url})

    $scope.flip_advanced = ->
        $scope.advanced = !$scope.advanced
        Wallet.set_setting("market.advanced", $scope.advanced).then()

    $scope.cancel_order = (id) ->
        res = MarketService.cancel_order(id)
        return unless res
    #res.then -> Growl.notice "", "Your order was canceled."

    get_order = ->
        switch $state.current.name
            when "market.buy" then $scope.bid
            when "market.sell" then $scope.ask
            when "market.short" then $scope.short
            else
                throw Error("Unknown $state.current.name", $state.current.name)

    # About *_change methods...
    # ng-change is used instead of watch because the fields
    # form a loop.  So, updating the cost updates the quantity,
    # updating the quantity updates the cost.  Watch did not allow
    # updating the watched field and suppressing the event.
    #
    # https://github.com/angular/angular.js/issues/834

    $scope.order_change = ->
        order = get_order()
        TradeData = MarketService.TradeData
        quantity = TradeData.helper.to_float(order.quantity)
        price = TradeData.helper.to_float(order.price)
        cost = quantity * price
        order.cost = if cost == 0 then null else
            Utils.formatDecimal(cost, $scope.market.quantity_precision, true)

    $scope.order_total_change = ->
        order = get_order()
        TradeData = MarketService.TradeData
        price = TradeData.helper.to_float(order.price)
        cost = TradeData.helper.to_float(order.cost)
        if price and price > 0
            quantity = cost / price
            order.quantity = if quantity == 0 then null else
                Utils.formatDecimal(quantity, $scope.market.base_precision, true)
        else
            order.quantity = null

    $scope.short_change = ->
        return if !$scope.market.shorts_price or $scope.market.shorts_price == 0.0
        short = $scope.short.clone_and_normalize()
        #shorts_price = $scope.market.shorts_price
        #shorts_price = short.short_price_limit if short.short_price_limit > shorts_price
        short.quantity = short.collateral * $scope.actual_market.shorts_price / 2.0
        $scope.short.quantity = if short.quantity == 0 then null else Utils.formatDecimal(short.quantity, $scope.actual_market.base_precision, true)

    $scope.short_total_change = ->
        short = $scope.short.clone_and_normalize()
        #shorts_price = $scope.market.shorts_price
        #shorts_price = short.short_price_limit if short.short_price_limit > shorts_price
        if short.quantity and short.quantity > 0 and $scope.actual_market.shorts_price > 0.0
            short.collateral = 2.0 * short.quantity / $scope.actual_market.shorts_price
            $scope.short.collateral = if short.collateral == 0 then null else
                Utils.formatDecimal(short.collateral, $scope.actual_market.quantity_precision, true)
        else
            $scope.short.collateral = null

    # Adds .01% to the price so when posted it overlaps and should match market bid/ask
    get_makeweight = ->
        switch $state.current.name
            when "market.buy" then .0001
            when "market.sell" then -.0001
            when "market.short" then -.0001
            else
                throw Error("Unknown $state.current.name", $state.current.name)

    $scope.grid_row_clicked = (row) ->
        if row.type == "ask" or row.type == "bid" or row.type == "short_wall"
            $scope.use_trade_data price: row.price, quantity: row.quantity
            $scope.scroll_buysell()

    $scope.use_trade_data = (data) ->
        #console.log "use_trade_data",$state.current.name
        order = get_order()
        makeweight = get_makeweight()
        coalesce = (new_value, old_value, precision) ->
            return null if !new_value and !old_value
            TradeData = MarketService.TradeData
            ret = if new_value and isFinite(new_value) then new_value else TradeData.helper.to_float(old_value)
            if ret == 0 # TODO, instead of nulls for validation, use (<input min="... )
                return null
            else
                return Utils.formatDecimal(ret, precision)

        order.quantity = coalesce data.quantity, order.quantity, $scope.market.quantity_precision

        order.interest_rate = coalesce data.interest_rate, order.interest_rate, 2

        order.short_price_limit = coalesce data.price_limit, order.short_price_limit, $scope.market.price_precision

        order.collateral = coalesce data.collateral, order.collateral, $scope.actual_market.quantity_precision

        price = data.price + data.price * makeweight if data.price
        order.price = coalesce price, order.price, $scope.market.price_precision

        switch $state.current.name
            when "market.buy" then $scope.order_change()
            when "market.sell" then $scope.order_change()
            when "market.short" then $scope.short_change()

        $scope.scroll_buysell()


    $scope.scroll_buysell = ->
        return null if $("#order_tabs").position().top > 0
        $(".content").animate({ scrollTop: $(".content").scrollTop() + $("#order_tabs").position().top }, "slow")
        return null

    $scope.submit_bid = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        bid = $scope.bid.clone_and_normalize()

        #make sure user sees the correct cost (ng-change vrs watch work-around)
        previous = $scope.bid.cost
        $scope.order_change()
#        if previous != $scope.bid.cost
#            # This can happen if code forgets to update the cost
#            form.bid_total.$error.message = 'market.tip.total_cost_updated'
#            return

        if bid.cost > $scope.account.base_balance
            form.bid_quantity.$error.message = 'market.tip.insufficient_balances'
            return

        bid.type = "bid_order"
        bid.display_type = "Bid"
        # TODO re-poll api for balance instead (see account_balances_observer below)
        $scope.account.base_balance -= bid.cost
        if $scope.market.lowest_ask > 0
            price_diff = 100.0 * bid.price / $scope.market.lowest_ask - 100
            if price_diff > 5
                bid.warning = "market.tip.bid_price_too_high"
                bid.price_diff = Utils.formatDecimal(price_diff, 1)
        $("#orders_table").animate({ scrollTop: 0 }, "slow")
        MarketService.add_unconfirmed_order(bid)

    $scope.submit_ask = ->
        form = @sell_form
        $scope.clear_form_errors(form)
        ask = $scope.ask.clone_and_normalize()

        #make sure user sees the correct cost (ng-change vrs watch work-around)
        previous = $scope.ask.cost
        $scope.order_change()
#        if previous != $scope.ask.cost
#            # This can happen if code forgets to update the cost
#            form.ask_total.$error.message = 'market.tip.total_cost_updated'
#            return

        if ask.quantity > $scope.account.quantity_balance
            form.ask_quantity.$error.message = 'market.tip.insufficient_balances'
            return
        ask.type = "ask_order"
        ask.display_type = "Ask"
        if $scope.market.highest_bid > 0
            price_diff = 100 - 100.0 * ask.price / $scope.market.highest_bid
            if price_diff > 5
                ask.warning = "market.tip.ask_price_too_low"
                ask.price_diff = Utils.formatDecimal(price_diff, 1)
        MarketService.add_unconfirmed_order(ask)

    $scope.submit_short = ->
        form = @short_form
        $scope.clear_form_errors(form)
        short = $scope.short.clone_and_normalize()
        short.price = $scope.market.shorts_price

        #make sure user sees the correct cost (ng-change vrs watch work-around)
        previous = $scope.short.cost
        $scope.short_change()
#        if previous != $scope.short.cost
#            # This can happen if code forgets to update the cost
#            form.short_total.$error.message = 'market.tip.total_cost_updated'
#            return

        short.type = "short_order"
        short.display_type = "Short"
        console.log "------ submit_short ------>", $scope.market.inverted, short
        $(".content").animate({ scrollTop: $("#short_orders_row").offset().top - 40 }, "slow")
        $("#orders_table").animate({ scrollTop: 0 }, "slow")
        MarketService.add_unconfirmed_order(short)

    $scope.confirm_order = (id) ->
        MarketService.confirm_order(id, $scope.account).then () ->
            # TODO trigger account_balances_observer instead
            console.log "------ order confirmed ------>", id
        , (error) ->
            Growl.error "", "Order failed: " + error.data.error.message


    $scope.submit_test = ->
        form = @buy_form
        $scope.clear_form_errors(form)
        form.bid_quantity.$error.message = "some field error, please fix me"
        form.bid_price.$error.message = "another field error, please fix me"
        form.$error.message = "some error, please fix me"


    MAX_SHORT_PERIOD_SEC = 2*60*60 #30*24*60*60
    SEC_PER_YEAR = 365 * 24 * 60 * 60

    $scope.cover_order = (order) ->
        $modal.open
            templateUrl: "market/cover_order_confirmation.html"
            controller: ["$scope", "$modalInstance", (scope, modalInstance) ->
                scope.market = current_market.get_actual_market()
                scope.asset_symbol = scope.market.base_symbol
                scope.base_precision = scope.market.base_precision
                original_order = order
                order = angular.copy(order)

                start_time = Utils.toDate(order.expiration) - MAX_SHORT_PERIOD_SEC*1000
                age_sec = (Date.now() + 2 * 3600 * 1000 - start_time) / 1000.0
                age_sec = 0 if age_sec < 0
                age_sec = MAX_SHORT_PERIOD_SEC if age_sec > MAX_SHORT_PERIOD_SEC
                percent_of_year = age_sec / SEC_PER_YEAR

                principal_due = order.cost
                fee_paid = Number($scope.asset_tx_fee)
                total_due = principal_due * ( 1 + (order.interest_rate / 100.0) * percent_of_year )
                interest_due = total_due - principal_due
                total_due += fee_paid

                principal_remaining = 0.0
                interest_remaining = 0.0

                scope.cover =
                    total_due: total_due
                    principal_due: principal_due
                    interest_due: interest_due
                    total_paid: total_due
                    principal_paid: principal_due
                    interest_paid: interest_due
                    fee_paid: fee_paid
                    interest_rate: order.interest_rate
                    principal_remaining: principal_remaining
                    interest_remaining: interest_remaining
                    changed: false
                    has_error: false

                scope.payment_changed = ->
                    scope.cover.changed = true
                    #$scope.clear_form_errors(@cover_form)
                    @cover_form.total_paid.$error.message = ''
                    scope.cover.has_error = false
                    total_paid = scope.cover.total_paid
                    if total_paid <= fee_paid
                        @cover_form.total_paid.$error.message = "The payment should exceed transaction fee"
                        scope.cover.has_error = true
                        return
                    principal_paid = (total_paid - fee_paid) / ( 1 + (scope.cover.interest_rate / 100.0) * percent_of_year )
                    if principal_paid > scope.cover.principal_due
                        @cover_form.total_paid.$error.message = "The payment should not exceed total due amount"
                        scope.cover.has_error = true
                        return
                    scope.cover.principal_paid = principal_paid
                    scope.cover.interest_paid = (total_paid - fee_paid) - scope.cover.principal_paid

                    scope.cover.principal_remaining = scope.cover.principal_due - scope.cover.principal_paid
                    scope.cover.interest_remaining = scope.cover.interest_due - scope.cover.interest_paid

                scope.total_clicked = ->
                    scope.cover.total_paid = scope.cover.total_due
                    scope.cover.principal_paid = scope.cover.principal_due
                    scope.cover.interest_paid = scope.cover.interest_due
                    scope.cover.principal_remaining = 0.0
                    scope.cover.interest_remaining = 0.0

                scope.cancel = ->
                    modalInstance.dismiss "cancel"

                scope.submit = ->
                    amount = scope.cover.total_paid - fee_paid
                    if Utils.formatDecimal(scope.cover.total_paid, scope.base_precision) == Utils.formatDecimal(scope.cover.total_due, scope.base_precision)
                        amount = 0 # pay in full
                    console.log  "------ submit cover ------>", amount
                    form = @cover_form
                    error_handler = (error) ->
                        form.total_paid.$error.message = Utils.formatAssertExceptionWithAssets(error.data.error.message, Blockchain.asset_records)
                    MarketService.cover_order(order, amount, account, error_handler).then ->
                        original_order.status = "pending"
                        modalInstance.dismiss "ok"
            ]
