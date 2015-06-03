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

    $scope.my_approvals = {positive: 0, negative: 0, neutral: 0};

    $q.all([Wallet.refresh_accounts(), Blockchain.refresh_delegates()]).then ->
        $scope.active_delegates = Blockchain.active_delegates
        $scope.inactive_delegates = Blockchain.inactive_delegates
        $scope.id_delegates = Blockchain.id_delegates
        $scope.accounts = Wallet.accounts
        $scope.approvals = Wallet.approvals
        $scope.sort_accounts = []

        updateApprovals()

        $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate  || '50.00 BTS'
        $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)

    updateApprovals = () =>
        my_approvals = {positive: 0, negative: 0, neutral: 0};
        sort_accounts = []
        for key of $scope.approvals
            del_found = false;
            if $scope.approvals[key].approval == 1
                my_approvals.positive++
            else if $scope.approvals[key].approval == 0
                my_approvals.neutral++
            else if $scope.approvals[key].approval == -1
                my_approvals.negative++
            # Search through active delegates first for reduced search space
            for del in $scope.active_delegates            
                if del.name == $scope.approvals[key].name
                    del_found = true
                    del.approval = $scope.approvals[key].approval
                    sort_accounts.push(
                        name: del.name,
                        votes_for: del.delegate_info.votes_for,
                        pay_rate: del.delegate_info.pay_rate,
                        approval: $scope.approvals[key].approval
                    )
                    break;
            # if not found in active delegates, search inactive delegates
            if not del_found
                for del in $scope.inactive_delegates
                    if del.name == $scope.approvals[key].name
                        del.approval = $scope.approvals[key].approval
                        sort_accounts.push(
                            name: del.name,
                            votes_for: del.delegate_info.votes_for,
                            pay_rate: del.delegate_info.pay_rate,
                            approval: $scope.approvals[key].approval
                        )
                        break;

        $scope.my_approvals = my_approvals
        $scope.sort_accounts = sort_accounts

    $scope.$watch ()->
        Info.info
    , ()->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate || '50.00 BTS'
        $scope.delegate_pay_rate = $scope.blockchain_delegate_pay_rate.split(' ')[0];
    ,true

    $scope.$watch ()->
        Wallet.approvals
    , ()->
        updateApprovals()
    ,true

    ###
    Info.refresh_info().then ->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        console.log('Info.info.blockchain_delegate_pay_rate',Info.info.blockchain_delegate_pay_rate)
    ###

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_supply



    $scope.toggleVoteUp = (name) ->
        newApproval = 1
        if ($scope.approvals[name] && $scope.approvals[name].approval > 0)
            newApproval = -1
        if ($scope.approvals[name] && $scope.approvals[name].approval < 0)
            newApproval = 0
        Wallet.approve_account(name, newApproval).then (res) ->
            if (!Wallet.approvals[name])
                Wallet.approvals[name] = Blockchain.all_delegates[name]
            Wallet.approvals[name].approval = newApproval

    $scope.unvoteAll = ->
        for key, value of Wallet.approvals
            if (value.delegate_info && value.approval!=0)
                Wallet.approve_account(key, 0).then ->
                    Wallet.approvals[key].approval=0

    $scope.link = (address) ->
        if address.indexOf('http://') == -1 and address.indexOf('https://') == -1
            address = 'http://' + address
        $window.open(address)
        return true
