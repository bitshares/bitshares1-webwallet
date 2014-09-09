angular.module("app").controller "AccountController", ($scope, $filter, $location, $stateParams, $q, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain, BlockchainAPI, Info) ->
    
    Info.refresh_info()
    $scope.refresh_addresses=Wallet.refresh_accounts
    name = $stateParams.name
    $scope.account_name = name
    $scope.utils = Utils
    $scope.account = Wallet.accounts[name]
    $scope.formatAsset = Utils.formatAsset
    $scope.model = {}
    $scope.model.rescan = true

    $scope.transfer_info =
        amount : null
        symbol : "Symbol not set"
        payto : ""
        memo : ""
        vote : 'vote_random'

    $scope.memo_size_max = 0
    $scope.private_key = {value : ""}
    $scope.p = { pendingRegistration: Wallet.pendingRegistrations[name] }
    $scope.wallet_info = {file: "", password: "", type: 'Bitcoin/PTS'}
    Blockchain.refresh_delegates().then ->
        $scope.active_delegate = Blockchain.delegate_active_hash_map[name]
    
    # TODO: mixing the wallet account with blockchain account is not a good thing.
    Wallet.get_account(name).then (acct)->
        $scope.account = acct
        if (typeof $scope.account.private_data != 'object' || $scope.account.private_data == null)
            $scope.account.private_data = {}
        vote_stng=$scope.account.private_data.account_vote_setting
        if (vote_stng == 'vote_random' || vote_stng == 'vote_all' || vote_stng == 'vote_none' )
            $scope.transfer_info.vote=vote_stng
        $scope.$watch('transfer_info.vote', (newValue, oldValue) ->
            if (newValue != oldValue)
                $scope.account.private_data.account_vote_setting=$scope.transfer_info.vote
                WalletAPI.account_update_private_data(name, $scope.account.private_data)
        )
        $scope.account_name = acct.name
        Wallet.set_current_account(acct) if acct.is_my_account
        if $scope.account.delegate_info
            Blockchain.get_asset(0).then (asset_type) ->
                $scope.account.delegate_info.pay_balance_asset = Utils.asset($scope.account.delegate_info.pay_balance, asset_type)

        #check if already registered.  this call should be removed when the name conflict info is added to the Wallet.get_account return value
        BlockchainAPI.get_account(name).then (result) ->
            if result and $scope.account.owner_key != result.owner_key
                #Growl.error 'Rename this account to use it', 'Account with the name ' + name + ' is already registered on the blockchian.'
                $modal.open
                    templateUrl: "dialog-rename.html"
                    controller: "DialogRenameController"
                    resolve:
                        oldname: -> name

    Wallet.refresh_account(name)

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply

    $scope.$watch ->
        Wallet.accounts[name]
    , ->
        if Wallet.accounts[name]
            $scope.account = Wallet.accounts[name]
            if $scope.account.delegate_info
                Blockchain.get_asset(0).then (asset_type) ->
                    $scope.account.delegate_info.pay_balance_asset = Utils.asset($scope.account.delegate_info.pay_balance, asset_type)

    $scope.$watch ->
        Wallet.balances[name]
    , ->
        if Wallet.balances[name]
            $scope.balances = Wallet.balances[name]
        if Wallet.open_orders_balances[name]
            $scope.open_orders_balances = Wallet.open_orders_balances[name]
        if Wallet.bonuses[name]
            $scope.bonuses = Wallet.bonuses[name]

    $scope.$watchCollection ->
        Wallet.transactions
    , () ->
        Wallet.refresh_account(name)

    $scope.import_key = ->
        form = @import_key_form
        form.key.$invalid = false
        WalletAPI.import_private_key($scope.private_key.value, $scope.account.name, false, $scope.model.rescan).then (response) ->
            $scope.private_key.value = ""
            if response == name
                Growl.notice "", "Your private key was successfully imported."
            else
                Growl.notice "", "Private key already belongs to another account: \"" + response + "\"."
            Wallet.refresh_transactions_on_update()
        , (response) ->
            form.key.$invalid = true

    $scope.select_file = ->
        $scope.wallet_info.file = magic_unicorn.prompt_user_to_open_file('Please open your wallet')

    $scope.import_wallet = ->
        form = @import_wallet_form
        form.path.$invalid = false
        form.pass.$invalid = false
        promise = null
        switch $scope.wallet_info.type
            when 'Bitcoin/PTS' then promise = WalletAPI.import_bitcoin($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            when 'Multibit' then promise = WalletAPI.import_multibit($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            when 'Electrum' then promise = WalletAPI.import_electrum($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            when 'Armory' then promise = WalletAPI.import_armory($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
        promise?.then (response) ->
            $scope.wallet_info.type = 'Bitcoin/PTS'
            $scope.wallet_info.file = ""
            $scope.wallet_info.password = ""
            $modal.open
                templateUrl: "dialog-ok.html"
                controller: "DialogOKController"
                resolve:
                    title: -> 'Success'
                    message: -> 'Keys from ' + $scope.wallet_info.type +  ' wallet were successfully imported'
                    bsStyle: -> 'success'

            Wallet.refresh_transactions_on_update()
        , (response) ->
            if response.data.error.code == 13 and response.data.error.message.match(/No such file or directory/)
                form.path.error_message = "No such file or directory"
                form.path.$invalid = true
            else if response.data.error.code == 13 and response.data.error.message.match(/Is a directory/)
                form.path.error_message = "This is a directory.  A wallet file is needed."
                form.path.$invalid = true
            else if response.data.error.code == 0 and response.data.error.message.match(/decrypt/)
                form.pass.error_message = "Unable to decrypt wallet"
                form.pass.$invalid = true
            else
                $modal.open
                    templateUrl: "dialog-ok.html"
                    controller: "DialogOKController"
                    resolve:
                        title: -> 'Error'
                        message: -> response.data.error.message
                        bsStyle: -> 'danger'



    $scope.toggleVoteUp = ->
        newApproval=1
        if ($scope.account.approved>0)
            newApproval=-1
        if ($scope.account.approved<0)
            newApproval=0
        Wallet.approve_account(name, newApproval).then ->
            $scope.account.approved=newApproval

    $scope.toggleFavorite = ->
        address = $scope.account.owner_key
        Wallet.wallet_add_contact_account(name, address).then ()->
            WalletAPI.account_set_favorite(name, !Wallet.accounts[name].is_favorite).then ()->
                Wallet.refresh_accounts()

    $scope.regDial = ->
        if Wallet.asset_balances[0]
          $modal.open
            templateUrl: "registration.html"
            controller: "RegistrationController"
            scope: $scope
        else
          Growl.error '','Account registration requires funds.  Please fund one of your accounts.'

    
