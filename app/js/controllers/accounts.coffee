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
