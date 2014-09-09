angular.module("app").controller "AccountsController", ($scope, $location, Wallet, Utils, RpcService, Growl) ->
    warnings = {}
    $scope.warnings = warnings
    account_names = []
    Wallet.refresh_accounts().then ->
        angular.forEach Wallet.accounts, (item) =>
            console.log item
            warnings[item.name] = false
            account_names.push([item.name])
        RpcService.request("batch", ["wallet_check_vote_proportion", account_names]).then (response) =>
            for i in [0...account_names.length]
                if response.result[i].utilization < 0.75
                    warnings[account_names[i]] = true
