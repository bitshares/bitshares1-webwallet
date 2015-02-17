angular.module("app").controller "DelegatesController", ($scope, $location, $state, $window, $q, Growl, Blockchain, Wallet, RpcService, Info) ->
    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
    $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate || '50.00 BTS'
    $scope.p =
        currentPage: 0
        pageSize: 100
        numberOfPages: 0
    $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)
    $scope.accounts = Wallet.accounts

    $scope.activeTab = "all"
    $scope.delegatesTab = "active"

    $scope.orderByField = "rank";
    $scope.reverseSort = false;
    $scope.orderByFieldStandby = "rank";
    $scope.reverseSortStandby = false;
    $scope.orderByFieldVotes = "votes_for";
    $scope.reverseSortVotes = true;

    $q.all([Wallet.refresh_accounts(), Blockchain.refresh_delegates()]).then ->
        $scope.active_delegates = Blockchain.active_delegates
        $scope.inactive_delegates = Blockchain.inactive_delegates
        $scope.accounts = Wallet.accounts
        $scope.sort_accounts = []
        for key of $scope.accounts
            if $scope.accounts[key].delegate_info
                $scope.sort_accounts.push(
                        name: key,
                        votes_for: $scope.accounts[key].delegate_info.votes_for,
                        pay_rate: $scope.accounts[key].delegate_info.pay_rate
                    )
        $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate  || '50.00 BTS'
        $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)

    $scope.$watch ()->
        Info.info
    , ()->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate || '50.00 BTS'
        $scope.delegate_pay_rate = $scope.blockchain_delegate_pay_rate.split(' ')[0];
    ,true
    ###
    Info.refresh_info().then ->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        console.log('Info.info.blockchain_delegate_pay_rate',Info.info.blockchain_delegate_pay_rate)
    ###

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply



    $scope.toggleVoteUp = (name) ->
        newApproval = 1
        if ($scope.accounts[name] && $scope.accounts[name].approved > 0)
            newApproval = -1
        if ($scope.accounts[name] && $scope.accounts[name].approved < 0)
            newApproval = 0
        Wallet.approve_account(name, newApproval).then (res) ->
            if (!Wallet.accounts[name])
                Wallet.accounts[name] = Blockchain.all_delegates[name]
            Wallet.accounts[name].approved = newApproval

    $scope.unvoteAll = ->
        for key, value of Wallet.accounts
            if (value.delegate_info && value.approved!=0)
                Wallet.approve_account(key, 0).then ->
                    Wallet.accounts[key].approved=0

    $scope.link = (address) ->
        if address.indexOf('http://') == -1 and address.indexOf('https://') == -1
            address = 'http://' + address
        $window.open(address)
        return true
