angular.module("app").controller "AccountVoteController", ($scope, Wallet, WalletAPI, Info, $modal, Blockchain, Growl) ->
    $scope.votes=[]
    balMinusFee=0
    $scope.accounts = Wallet.accounts

    $scope.vote_options =
        vote_none: "vote_none"
        vote_all: "vote_all"
        vote_random: "vote_random_subset"
        vote_recommended: "vote_as_delegates_recommended"

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts

    $scope.toggleVoteUp = (name) ->
        newApproval=1
        if ($scope.accounts[name] && $scope.accounts[name].approved>0)
            newApproval=-1
        if ($scope.accounts[name] && $scope.accounts[name].approved<0)
            newApproval=0
        Wallet.approve_account(name, newApproval).then (res)->
            if (!$scope.accounts[name])
                $scope.accounts[name]={}
            $scope.accounts[name].approved=newApproval

    Wallet.balances[$scope.account_name][Info.symbol] = 0.0
    $scope.$watch ->
        Wallet.balances[$scope.account_name][Info.symbol].amount
    , (cur, old) ->
        if (cur>0)
            WalletAPI.account_vote_summary($scope.account_name).then (data) ->
                $scope.votes=data

    yesSend = ->
        WalletAPI.transfer(balMinusFee, Info.symbol, $scope.account_name, $scope.account_name, $scope.transfer_info.vote, $scope.transfer_info.vote).then (response) ->
            console.log response
            Growl.notice "", "Transfer transaction broadcasted"
            Wallet.refresh_transactions_on_update()
            $scope.t_active=true
        ,
        (error) ->
            if (error.data.error.code==20005)
                Growl.error "Unknown receive account",""
            if (error.data.error.code==20010)
                Growl.error "Insufficient funds",""

    $scope.updateVotes = ->
        myBal=$scope.balances[Info.symbol]
        balMinusFee=myBal.amount / myBal.precision - Wallet.info.transaction_fee.amount / myBal.precision
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + balMinusFee + " " + Info.symbol + " to " + $scope.account_name + ". It will charge a fee of " + Wallet.info.transaction_fee.amount / myBal.precision + " " + Info.symbol + "."
                action: -> yesSend
