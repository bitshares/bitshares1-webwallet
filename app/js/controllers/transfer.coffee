angular.module("app").controller "TransferController", ($scope, $stateParams, $modal, $q, Wallet, WalletAPI, Blockchain, Utils, Info, Growl) ->
    Info.refresh_info()
    $scope.utils = Utils
    $scope.balances = []
    $scope.show_from_section = true
    $scope.account_from_name = account_from_name = $stateParams.from
    if $scope.account_name
        $scope.show_from_section = false
        $scope.account_from_name = account_from_name = $scope.account_name
    $scope.gravatar_account_name = null
    $scope.transfer_info = { payto: $stateParams.to, memo: '', symbol: Info.symbol}
    $scope.memo_size_max = 19
    $scope.addr_symbol = null
    my_transfer_form = null
    $scope.no_account = false

    Wallet.refresh_accounts().then ->
        $scope.accounts = {}

        angular.forEach Wallet.accounts, (acct, name) ->
            if acct.is_my_account
                $scope.accounts[name] = acct

        if account_from_name
            if $scope.accounts[account_from_name]
                $scope.balances = Wallet.balances[account_from_name]
                $scope.transfer_info.symbol = Object.keys($scope.balances)[0]
            else
                scope.no_account = true
        else
            Wallet.get_current_or_first_account().then (account)->
                if account
                    $scope.account_from_name = account_from_name = account.name
                    $scope.balances = Wallet.balances[account_from_name]
                    $scope.transfer_info.symbol = Object.keys($scope.balances)[0]
                else
                    $scope.no_account = true

    Blockchain.get_info().then (config) ->
        $scope.memo_size_max = config.memo_size_max
        $scope.addr_symbol = config.symbol

    $scope.$watch ->
        $scope.transfer_info.payto
    , ->
        $scope.gravatar_account_name = $scope.transfer_info.payto

    $scope.transfer_info =
        amount : $stateParams.amount
        symbol: $stateParams.currency || Info.symbol
        payto : $stateParams.to
        memo :  $stateParams.memo
        vote : 'vote_random'

    $scope.vote_options =
        vote_none: "Vote None"
        vote_all: "Vote All"
        vote_random: "Vote Random Subset"

    yesSend = ->
        WalletAPI.transfer($scope.transfer_info.amount, $scope.transfer_info.symbol, account_from_name, $scope.transfer_info.payto, $scope.transfer_info.memo, $scope.transfer_info.vote).then (response) ->
            $scope.transfer_info.payto = ""
            my_transfer_form.payto.$setPristine()
            $scope.transfer_info.amount = ""
            my_transfer_form.amount.$setPristine()
            $scope.transfer_info.memo = ""
            Growl.notice "", "Transfer transaction broadcasted"
            Wallet.refresh_transactions_on_update()
            $scope.t_active=true
        ,
        (error) ->
            if (error.data.error.code==20005)
                my_transfer_form.payto.error_message = "Unknown receive account"
            if (error.data.error.code==20010)
                my_transfer_form.amount.error_message = "Insufficient funds"

    $scope.send = ->
        my_transfer_form = @my_transfer_form
        my_transfer_form.amount.error_message = null
        my_transfer_form.payto.error_message = null
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + $scope.transfer_info.amount + " " + $scope.transfer_info.symbol + " to " + $scope.transfer_info.payto + ". It will charge a fee of " + Info.info.priority_fee + "."
                action: -> yesSend

    $scope.newContactModal = ->
        $modal.open
            templateUrl: "newcontactmodal.html"
            controller: "NewContactModalController"
            resolve:
                addr: ->
                    ""
                action: ->
                    (contact)->
                        $scope.transfer_info.payto = contact

#    $scope.addContactFromTo = ->
#        if payto and payto.value and $scope.addr_symbol and (payto.value.indexOf $scope.addr_symbol) == 0 and payto.value.length == $scope.addr_symbol.length + 50
#            $modal.open
#                templateUrl: "newcontact.html"
#                controller: "NewContactController"
#                resolve:
#                    addr: ->
#                        payto.value
#                    action: ->
#                        (contact)->
#                            $scope.transfer_info.payto = contact

    $scope.accountSuggestions = (input) ->
        deferred = $q.defer()
        ret = Object.keys(Wallet.accounts)
        angular.forEach ret, (name) ->
            if Wallet.accounts[name].is_favorite || Wallet.accounts[name].is_my_account
                ret.push name
        deferred.resolve(ret)
        return deferred.promise
