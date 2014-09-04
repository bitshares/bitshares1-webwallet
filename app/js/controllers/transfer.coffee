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

    $scope.memo_size_max = 19
    my_transfer_form = null
    $scope.no_account = false
    $scope.model ||= {}
    $scope.model.autocomplete = Wallet.autocomplete

    $scope.$watch ->
        Wallet.autocomplete
    , ->
        $scope.model.autocomplete = Wallet.autocomplete

    if (!$scope.transfer_info)
        $scope.transfer_info =
            amount : $stateParams.amount
            symbol: $stateParams.asset || Info.symbol
            payto : $stateParams.to
            memo :  $stateParams.memo
            vote : 'vote_random'

    $scope.vote_options =
        vote_none: "vote_none"
        vote_all: "vote_all"
        vote_random: "vote_random_subset"
        vote_recommended: "vote_as_delegates_recommended"

    $scope.my_accounts = []
    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts
        $scope.my_accounts.splice(0, $scope.my_accounts.lenght)
        for k,a of Wallet.accounts
            $scope.my_accounts.push a if a.is_my_account

        angular.forEach Wallet.accounts, (acct, name) ->
            if acct.is_my_account
                $scope.accounts[name] = acct

        if account_from_name
            if $scope.accounts[account_from_name]
                $scope.balances = Wallet.balances[account_from_name]
                $scope.transfer_info.symbol = Object.keys($scope.balances)[0] if $scope.balances and !$stateParams.asset
            else
                $scope.no_account = true
        else
            Wallet.get_current_or_first_account().then (account)->
                if account
                    $scope.account_from_name = account_from_name = account.name
                    $scope.balances = Wallet.balances[account_from_name]
                    $scope.transfer_info.symbol = Object.keys($scope.balances)[0] if $scope.balances and !$stateParams.asset
                else
                    $scope.no_account = true

    Blockchain.get_info().then (config) ->
        $scope.memo_size_max = config.memo_size_max

    yesSend = ->
        WalletAPI.transfer($scope.transfer_info.amount, $scope.transfer_info.symbol, account_from_name, $scope.transfer_info.payto, $scope.transfer_info.memo, $scope.transfer_info.vote).then (response) ->
            $scope.transfer_info.payto = ""
            my_transfer_form.payto.$setPristine()
            $scope.transfer_info.amount = ""
            my_transfer_form.amount.$setPristine()
            $scope.transfer_info.memo = ""
            Growl.notice "", "Transfer transaction broadcasted"
            Wallet.refresh_transactions_on_update()
            $scope.model.t_active=true
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
        amount_asset = $scope.balances[$scope.transfer_info.symbol]
        transfer_amount = Utils.formatDecimal($scope.transfer_info.amount, amount_asset.precision)
        Blockchain.get_asset(0).then (fee_asset)->
            transaction_fee = Utils.formatAsset(Utils.asset(Wallet.info.transaction_fee.amount, fee_asset))
            trx = {to: $scope.transfer_info.payto, amount: transfer_amount + ' ' + $scope.transfer_info.symbol, fee: transaction_fee, memo: $scope.transfer_info.memo, vote: $scope.vote_options[$scope.transfer_info.vote]}
            $modal.open
                templateUrl: "dialog-transfer-confirmation.html"
                controller: "DialogTransferConfirmationController"
                resolve:
                    title: -> "Transfer Authorization"
                    trx: -> trx
                    action: -> yesSend

    $scope.newContactModal = ->
        $modal.open
            templateUrl: "newcontactmodal.html"
            controller: "NewContactModalController"
            resolve:
                contact_name: ->
                    $scope.transfer_info.payto
                action: ->
                    (contact)->
                        $scope.transfer_info.payto = contact

    $scope.onSelect = ($item, $model, $label) ->
        console.log('selected!',$item, $model, $label)
        $scope.transfer_info.payto=$label.name
        $scope.gravatar_account_name = $scope.transfer_info.payto

    $scope.accountSuggestions = (input) ->
        nItems=10
        deferred = $q.defer()
        ret = []
        regHash={}
        $scope.gravatar_account_name = ""
        Blockchain.list_accounts(input, nItems).then (response) ->
            angular.forEach response, (val) ->
                if val.name.substring(0, input.length) == input
                    regHash[val.name]=true
                    if !Wallet.accounts[val.name]
                        ret.push {'name': val.name}
            angular.forEach Wallet.accounts, (val) ->
                if val.name.substring(0, input.length) == input
                    if (regHash[val.name])
                        ret.push {'name': val.name, 'is_favorite': val.is_favorite, 'approved': val.approved}
                    else
                        ret.push {'name': val.name, 'is_favorite': val.is_favorite, 'approved': val.approved, 'unregistered': true}
            ret.sort(compare)

            deferred.resolve(ret)
        return deferred.promise

    compare = (a, b) ->
        return -1  if a.name < b.name
        return 1  if a.name > b.name
        0

    $scope.toggleVoteUpContact = (name) ->
        newApproval=1
        if ($scope.accounts[name] && $scope.accounts[name].approved>0)
            newApproval=-1
        if ($scope.accounts[name] && $scope.accounts[name].approved<0)
            newApproval=0
        Wallet.approve_account(name, newApproval).then (res)->
            Wallet.refresh_account(name).then () ->
                $scope.accounts=Wallet.accounts

    $scope.toggleFavoriteContact = (name) ->
        is_favorite=true
        if (Wallet.accounts[name] && Wallet.accounts[name].is_favorite)
            is_favorite=false
        WalletAPI.account_set_favorite(name, is_favorite).then () ->
            Wallet.refresh_account(name).then () ->
                $scope.accounts=Wallet.accounts
