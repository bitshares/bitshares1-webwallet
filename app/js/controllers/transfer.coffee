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
    tx_fee = null
    tx_fee_asset = null
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
    refresh_accounts_promise = Wallet.refresh_accounts()
    refresh_accounts_promise.then ->
        $scope.accounts = Wallet.accounts
        $scope.my_accounts.splice(0, $scope.my_accounts.length)
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

    #$scope.showLoadingIndicator(refresh_accounts_promise)
    
    Blockchain.get_info().then (config) ->
        $scope.memo_size_max = config.memo_size_max
    
    $scope.setForm = (form) ->
        my_transfer_form = form
    
    # Validation and display prior to form submit
    $scope.hot_check_send_amount = ->
        return unless $scope.balances
        return unless $scope.balances[$scope.transfer_info.symbol]
        return unless my_transfer_form.amount
        
        my_transfer_form.amount.error_message = null
        
        if tx_fee.asset_id != tx_fee_asset.id
            console.log "ERROR hot_check[_send_amount] encountered unlike transfer and fee assets"
            return
        
        fee=tx_fee.amount/tx_fee_asset.precision
        transfer_amount=$scope.transfer_info.amount
        _bal=$scope.balances[$scope.transfer_info.symbol]
        balance = _bal.amount/_bal.precision
        balance_after_transfer = balance - transfer_amount - fee
        
        #display "New Balance 999 (...)"
        $scope.transfer_asset = Blockchain.symbol2records[$scope.transfer_info.symbol]
        $scope.balance_after_transfer = balance_after_transfer
        $scope.balance = balance
        $scope.balance_precision = _bal.precision
        #transfer_amount -> already available as $scope.transfer_info.amount
        $scope.fee = fee
        
        my_transfer_form.$setValidity "funds", balance_after_transfer >= 0
        if balance_after_transfer < 0
            my_transfer_form.amount.error_message = "Insufficent funds"

    #call to initialize and on symbol change
    $scope.$watch ->
        $scope.transfer_info.symbol
    , ->
        return if not $scope.transfer_info.symbol or $scope.transfer_info.symbol == "Symbol not set"
        #Load the tx_fee and its asset object for pre form submit validation
        WalletAPI.get_transaction_fee($scope.transfer_info.symbol).then (_tx_fee) ->
            tx_fee = _tx_fee
            Blockchain.get_asset(tx_fee.asset_id).then (_tx_fee_asset) ->
                tx_fee_asset = _tx_fee_asset
                $scope.hot_check_send_amount()
    
    yesSend = ->
        WalletAPI.transfer($scope.transfer_info.amount, $scope.transfer_info.symbol, account_from_name, $scope.transfer_info.payto, $scope.transfer_info.memo, $scope.transfer_info.vote).then (response) ->
            $scope.transfer_info.payto = ""
            my_transfer_form.payto.$setPristine()
            $scope.transfer_info.amount = ""
            my_transfer_form.amount.$setPristine()
            $scope.transfer_info.memo = ""
            Growl.notice "", "Transfer transaction broadcasted"
            $scope.model.t_active=true
        ,
        (error) ->
            if (error.data.error.code==20005)
                my_transfer_form.payto.error_message = "Unknown receive account"
            if (error.data.error.code==20010)
                my_transfer_form.amount.error_message = "Insufficient funds"

    $scope.send = ->
        my_transfer_form.amount.error_message = null
        my_transfer_form.payto.error_message = null
        amount_asset = $scope.balances[$scope.transfer_info.symbol]
        transfer_amount = Utils.formatDecimal($scope.transfer_info.amount, amount_asset.precision)
        WalletAPI.get_transaction_fee($scope.transfer_info.symbol).then (tx_fee) ->
            transfer_asset = Blockchain.symbol2records[$scope.transfer_info.symbol]
            Blockchain.get_asset(tx_fee.asset_id).then (tx_fee_asset) ->
                transaction_fee = Utils.formatAsset(Utils.asset(tx_fee.amount, tx_fee_asset))
                trx = {to: $scope.transfer_info.payto, amount: transfer_amount + ' ' + $scope.transfer_info.symbol, fee: transaction_fee, memo: $scope.transfer_info.memo, vote: $scope.vote_options[$scope.transfer_info.vote]}
                $modal.open
                    templateUrl: "dialog-transfer-confirmation.html"
                    controller: "DialogTransferConfirmationController"
                    resolve:
                        title: -> "Transfer Authorization"
                        trx: -> trx
                        action: -> yesSend
                        xts_transfer: -> 
                            $scope.transfer_info.symbol == 'XTS' || $scope.transfer_info.symbol == 'BTSX'

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
