angular.module("app").controller "AccountVoteController", ($scope, Wallet, WalletAPI, Info, $modal, Blockchain, Growl) ->
    $scope.votes=[]
    balMinusFee=0
    $scope.approved_delegates = Wallet.approved_delegates

    Wallet.refresh_accounts().then ->
        $scope.approved_delegates = Wallet.approved_delegates

    $scope.toggleVoteUp = (name) ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve
    $scope.$watch('$scope.balances[Info.symbol]', ->
        WalletAPI.account_vote_summary($scope.account_name).then (data) ->
            $scope.votes=data
    )

    yesSend = ->
        WalletAPI.transfer(balMinusFee, Info.symbol, $scope.account_name, $scope.account_name, 'Transfer for voting', $scope.transfer_info.vote).then (response) ->
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
        balMinusFee=myBal.amount / myBal.precision - Info.info.priority_fee / myBal.precision
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + balMinusFee + " " + Info.symbol + " to " + $scope.account_name + ". It will charge a fee of " + Info.info.priority_fee / myBal.precision + " " + Info.symbol + "."
                action: -> yesSend
        