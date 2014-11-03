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
