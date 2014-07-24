angular.module("app").controller "AccountVoteController", ($scope, Wallet, WalletAPI, Info, $modal, Blockchain) ->
    $scope.votes=[]
    balMinusFee=0
    WalletAPI.account_vote_summary($scope.account.name).then (data) ->
        console.log('account_vote_summary', data)
        console.log($scope.balances)
        $scope.votes=data

    yesSend = ->
        WalletAPI.transfer(balMinusFee, Info.symbol, $scope.account.name, $scope.account.name, 'Transfer for voting', 'vote_all').then (response) ->
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
        balMinusFee=myBal.amount / myBal.precision - Info.info.priority_fee.split(' ')[0]
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + balMinusFee + " " + Info.symbol + " to " + $scope.account.name + ". It will charge a fee of " + Info.info.priority_fee + " " + "."
                action: -> yesSend
        