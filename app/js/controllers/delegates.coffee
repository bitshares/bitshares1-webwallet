angular.module("app").controller "DelegatesController", ($scope, $location, $state, $q, Growl, Blockchain, Wallet, RpcService, Info) ->
    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
    $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
    $scope.p =
        currentPage: 0
        pageSize: 100
        numberOfPages: 0
    $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)
    $scope.accounts = Wallet.accounts


    $q.all([Wallet.refresh_accounts(), Blockchain.refresh_delegates()]).then ->
        $scope.active_delegates = Blockchain.active_delegates
        $scope.inactive_delegates = Blockchain.inactive_delegates
        $scope.accounts = Wallet.accounts
        $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)

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

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply

    $scope.toggleVoteUp = (name) ->
        newApproval=1
        if ($scope.accounts[name] && $scope.accounts[name].approved>0)
            newApproval=-1
        if ($scope.accounts[name] && $scope.accounts[name].approved<0)
            newApproval=0
        Wallet.approve_account(name, newApproval).then (res) ->
            if (!Wallet.accounts[name])
                Wallet.accounts[name]=Blockchain.all_delegates[name]
            Wallet.accounts[name].approved=newApproval

    $scope.unvoteAll = ->
        angular.forEach Wallet.accounts, (value, key) ->
            if (value.delegate_info && value.approved!=0)
                Wallet.approve_account(key, 0).then ->
                    Wallet.accounts[key].approved=0
