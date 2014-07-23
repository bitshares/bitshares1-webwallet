angular.module("app").controller "DelegatesController", ($scope, $location, $state, $q, Growl, Blockchain, Wallet, RpcService) ->

    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.approved_delegates = Wallet.approved_delegates

    $q.all([Wallet.refresh_accounts(), Blockchain.refresh_delegates()]).then ->
        $scope.approved_delegates_list = []
        angular.forEach Wallet.approved_delegates, (value, key) ->
            d = Blockchain.all_delegates[key]
            if d
                $scope.approved_delegates_list.push d
            else
                console.log "cannot find approved delegate #{key}"

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply

    $scope.toggleVoteUp = (name) ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve

    $scope.unvoteAll = ->
        angular.forEach Wallet.approved_delegates, (value, key) ->
            Wallet.approve_delegate(key, false)
