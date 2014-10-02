angular.module("app").controller "AccountsController", ($scope, $location, Wallet, Utils, RpcService) ->
#    RpcService.start_profiler()
#    $scope.$on "$destroy", -> RpcService.stop_profiler()

    warnings = {}
    $scope.warnings = warnings
    account_names = []
    Wallet.refresh_accounts().then ->
        angular.forEach Wallet.accounts, (item) =>
            warnings[item.name] = false
            account_names.push([item.name])
        RpcService.request("batch", ["wallet_check_vote_proportion", account_names]).then (response) =>
            for i in [0...account_names.length]
                name = account_names[i]
                if response.result[i].utilization < 0.75 and Wallet.balances[name] and Wallet.main_asset and Wallet.balances[name][Wallet.main_asset.symbol].amount > 0
                    warnings[name] = true
