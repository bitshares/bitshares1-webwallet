angular.module("app").controller "AccountVoteController", ($scope, $translate, Wallet, WalletAPI, Info, $modal, Blockchain, Growl, Utils, Observer) ->
    $scope.votes = []
    balMinusFee = 0
    $scope.accounts = Wallet.accounts
    $scope.has_balance = Info.symbol and $scope.balances?[Info.symbol] and $scope.balances[Info.symbol].amount > 0

    $scope.vote_options =
        vote_none: "vote_none"
        vote_all: "vote_all"
        vote_random: "vote_random_subset"
        vote_recommended: "vote_as_delegates_recommended"

    $scope.data = {}
    $scope.data.vote = if Wallet.default_vote == "vote_per_transfer" then "vote_all" else Wallet.default_vote
    $scope.data.main_asset_precision = if Wallet.main_asset then Wallet.main_asset.precision else 10000
    $scope.data.main_asset_symbol = if Wallet.main_asset then Wallet.main_asset.symbol else ''

    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts

    $scope.toggleVoteUp = (name) ->
        newApproval = 1
        if ($scope.accounts[name] && $scope.accounts[name].approved > 0)
            newApproval = -1
        if ($scope.accounts[name] && $scope.accounts[name].approved < 0)
            newApproval = 0
        Wallet.approve_account(name, newApproval).then (res)->
            if (!$scope.accounts[name])
                $scope.accounts[name] = {}
            $scope.accounts[name].approved = newApproval

    account_votes_observer =
        name: "account_votes_observer"
        frequency: 4000
        update: (data, deferred) ->
            $scope.has_balance = Info.symbol and $scope.balances?[Info.symbol] and $scope.balances[Info.symbol].amount > 0
            WalletAPI.account_vote_summary($scope.account_name).then (res) ->
                $scope.votes = res
                deferred.resolve(true)
            , (error) ->
                deferred.reject(error)

    Observer.registerObserver(account_votes_observer)

    $scope.$on "$destroy", ->
        Observer.unregisterObserver(account_votes_observer)

    yesSend = ->
        balMinusFee = Math.floor(balMinusFee * 100000) / 100000;
        WalletAPI.transfer(balMinusFee, Info.symbol, $scope.account_name, $scope.account_name, $scope.data.vote, $scope.data.vote).then (response) ->
            Growl.notice "", "Transfer transaction broadcasted"
            $scope.t_active = true
        , (error) ->
            if (error.data.error.code == 20005)
                Growl.error "Unknown receive account", ""
            if (error.data.error.code == 20010)
                Growl.error "Insufficient funds", ""

    $scope.updateVotes = ->
        myBal = $scope.balances[Info.symbol]
        balMinusFee = myBal.amount / myBal.precision - Wallet.info.transaction_fee.amount / myBal.precision
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> $translate("account.vote.vote_confirmation_title")
                message: ->
                    $translate "account.vote.vote_confirmation_text",
                        balance: Utils.formatDecimal(balMinusFee, myBal.precision, true)
                        symbol: Info.symbol
                        fee: Wallet.info.transaction_fee.amount / myBal.precision
                        fee_symbol: Info.symbol
            #"Vote with your #{Utils.formatDecimal(balMinusFee,myBal.precision,true)} #{Info.symbol} balance. It will charge a fee of #{Wallet.info.transaction_fee.amount / myBal.precision} #{Info.symbol}."
                action: -> yesSend
