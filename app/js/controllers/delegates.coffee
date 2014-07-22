angular.module("app").controller "DelegatesController", ($scope, $location, $state, Growl, Blockchain, Wallet, RpcService, Info) ->

    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.approved_delegates = Wallet.approved_delegates
    $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
    $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate

    $scope.$watch ()->
        Info.info
    , ()->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
    ,true
    ###
    Info.refresh_info().then ->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        console.log('Info.info.blockchain_delegate_pay_rate',Info.info.blockchain_delegate_pay_rate)
    ###
    Wallet.refresh_accounts()
    Blockchain.refresh_delegates().then ->
        $scope.active_delegates = Blockchain.active_delegates
        $scope.inactive_delegates = Blockchain.inactive_delegates
        $scope.approved_delegates = Wallet.approved_delegates
        $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
        


    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply

    $scope.toggleVoteUp = (name) ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve

    $scope.unvoteAll = ->
        angular.forEach Wallet.approved_delegates, (value, key) ->
            Wallet.approve_delegate(key, false)
