angular.module("app").controller "HomeController", ($scope, $modal, Shared, $log, RpcService, Wallet, Blockchain, Growl, Info, Utils) ->
    Info.refresh_info().then ->
        # TODO this code sucks
        satoshi_income = Info.info.income_per_block * (60 * 60 * 24 / 15) #TODO from config
        Blockchain.get_asset(0).then (asset_type)->
            $scope.daily_income = Utils.formatAsset(Utils.asset(satoshi_income, asset_type)) #TODO
            $scope.income_apr = satoshi_income * 365 * 100 / Info.info.share_supply

            Blockchain.refresh_delegates().then ->
                round_pay_rate = 0
                angular.forEach Blockchain.active_delegates, (del) ->
                    round_pay_rate += del.delegate_info.pay_rate
                satoshi_expenses = satoshi_income * (round_pay_rate / (101 * 100))
                $scope.daily_expenses = Utils.formatAsset(Utils.asset(satoshi_expenses, asset_type))
                $scope.expenses_apr = satoshi_expenses * 365 * 100 / Info.info.share_supply
                $scope.daily_burn = Utils.formatAsset(Utils.asset(satoshi_income - satoshi_expenses, asset_type))
                $scope.burn_apr = (satoshi_income - satoshi_expenses) * 365 * 100 / Info.info.share_supply


###
    $scope.transactions = []
    $scope.balance_amount = 0.0
    $scope.balance_asset_type = ''

    watch_for = ->
        Info.info

    on_update = (info) ->
        $scope.balance_amount = info.balance if info.wallet_open

    $scope.$watch(watch_for, on_update, true)

    Wallet.get_balance().then (balance)->
        $scope.balance_amount = balance.amount
        $scope.balance_asset_type = balance.asset_type
        Wallet.get_transactions().then (trs) ->
            $scope.transactions = trs

# Merge: this duplicates the code in transactions.coffee
    $scope.viewAccount = (name)->
        Shared.accountName  = name
        Shared.accountAddress = "TODO:  Look the address up somewhere"
        Shared.trxFor = name

    $scope.viewContact = (name)->
        Shared.contactName  = name
        Shared.contactAddress = "TODO:  Look the address up somewhere"
        Shared.trxFor = name
###


