angular.module("app").controller "AccountController", ($scope, $filter, $location, $stateParams, $q, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain, RpcService, Info) ->
    
    Info.refresh_info()
    $scope.refresh_addresses=Wallet.refresh_accounts
    name = $stateParams.name
    $scope.account_name = name
    $scope.utils = Utils
    $scope.account = Wallet.accounts[name]
    #$scope.balances = Wallet.balances[name]
    $scope.formatAsset = Utils.formatAsset
    $scope.model = {}
    $scope.model.rescan = true
    $scope.magic_unicorn = magic_unicorn?

    $scope.trust_level = false

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
        Wallet.current_account = acct
        if $scope.account.delegate_info
            Blockchain.get_asset(0).then (asset_type) ->
                $scope.account.delegate_info.pay_balance_asset = Utils.asset($scope.account.delegate_info.pay_balance, asset_type)

    Wallet.refresh_account(name).then ->
        $scope.trust_level = Wallet.approved_delegates[name]

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
            Growl.notice "","The wallet was successfully imported."
            Wallet.refresh_transactions_on_update()
        , (response) ->
            if response.data.error.code == 13
                form.path.error_message = "No such file or directory"
                form.path.$invalid = true
            else if response.data.error.code == 0 and response.data.error.message.match(/decrypt/)
                form.pass.error_message = "Unable to decrypt wallet"
                form.pass.$invalid = true

    $scope.toggleVoteUp = ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve

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

