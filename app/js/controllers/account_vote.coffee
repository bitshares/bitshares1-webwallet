angular.module("app").controller "AccountVoteController", ($scope, Wallet, WalletAPI, Info, $modal, Blockchain) ->
    $scope.votes=[]
    
    console.log('bllll', Blockchain.asset_records[Object.keys(Blockchain.asset_records)[0]])
    WalletAPI.account_vote_summary().then (data) ->
        console.log('account_vote_summary', data)
        console.log($scope.balances)
        $scope.votes=data

    yesSend = ->
        WalletAPI.transfer(Number($scope.balances[Info.symbol]-Info.info.priority_fee), Info.symbol, $scope.account.name, $scope.account.name, 'Transfer for voting', 'vote_all').then (response) ->
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
        console.log('sym', Info.symbol)
        console.log(Info.info.priority_fee)
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + ($scope.balances[Info.symbol.symbol]-Info.info.priority_fee) + " " + Info.symbol + " to " + $scope.account.name + ". It will charge a fee of " + Info.info.priority_fee + " " + Info.symbol + "."
                action: -> yesSend
        