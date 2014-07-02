angular.module("app").controller "AccountController", ($scope, $filter, $location, $stateParams, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain) ->

    $scope.refresh_addresses=Wallet.refresh_accounts
    name = $stateParams.name
    #$scope.accounts = Wallet.receive_accounts
    #$scope.account.balances = Wallet.balances[name]
    $scope.utils = Utils
    $scope.account = Wallet.accounts[name]
    console.log('act')
    console.log(Wallet.accounts[name])

    $scope.balances = Wallet.balances[name]
    $scope.formatAsset = Utils.formatAsset
    $scope.symbol = "XTS"

    #Wallet.refresh_accounts()
    $scope.trust_level = Wallet.approved_delegates[name]
    $scope.wallet_info = {file : "", password : ""}
    
    $scope.private_key = {value : ""}

    refresh_account = ->
        Wallet.get_account(name).then (acct) ->
            $scope.account = acct
            $scope.balances = Wallet.balances[name]
            Wallet.refresh_transactions_on_update()
    refresh_account()

    Blockchain.get_config().then (config) ->
        $scope.memo_size_max = config.memo_size_max

    $scope.import_key = ->
        WalletAPI.import_private_key($scope.private_key.value, $scope.account.name).then (response) ->
            $scope.private_key.value = ""
            Growl.notice "", "Your private key was successfully imported."
            refresh_account()

    $scope.register = ->
        console.log "paying with:"
        console.log $scope.payWith
        WalletAPI.account_register($scope.account.name, $scope.payWith).then (response) ->
            Wallet.refresh_account()

    $scope.import_wallet = ->
        WalletAPI.import_bitcoin($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name).then (response) ->
            $scope.wallet_info.file = ""
            $scope.wallet_info.password = ""
            Growl.notice "The wallet was successfully imported."
            refresh_account()

    $scope.send = ->
        WalletAPI.transfer($scope.amount, $scope.symbol, $scope.account.name, $scope.payto, $scope.memo).then (response) ->
            $scope.payto = ""
            $scope.amount = ""
            $scope.memo = ""
            Growl.notice "", "Transaction broadcasted (#{angular.toJson(response.result)})"
            refresh_account()
            $scope.t_active=true

    $scope.newContactModal = ->
      $modal.open
        templateUrl: "newcontact.html"
        controller: "NewContactController"

    $scope.toggleVoteUp = ->
        if name not of Wallet.approved_delegates or Wallet.approved_delegates[name] < 1
            Wallet.set_trust(name, true)
        else
            Wallet.set_trust(name, false)

    $scope.toggleFavorite = ->
        if (Wallet.accounts[name].private_data)
            private_data=Wallet.accounts[name].private_data
        else
            private_data={}
        if !(private_data.gui_data)
            private_data.gui_data={}
        private_data.gui_data.favorite=!(private_data.gui_data.favorite)
        Wallet.account_update_private_data(name, private_data).then ->
            $scope.account.private_data=Wallet.accounts[name].private_data
            console.log($scope.account.private_data)

    $scope.regDial = ->
        if Wallet.nonZeroBalance
          $modal.open
            templateUrl: "registration.html"
            controller: "RegistrationController"
            scope: $scope
        else
          Growl.error '','Account registration requires funds.  Please fund one of your accounts.'

    $scope.accountSuggestions = (input) ->
        console.log(input)
        Wallet.blockchain_list_accounts(input, 10).then (response) ->
            #code to make local and global accounts data structures consistents
            newresponse=(item.name for item in response)
            console.log(newresponse)
            allAccounts=newresponse.concat(Object.keys(Wallet.accounts))
            console.log(allAccounts)
            $filter('filter')(allAccounts, input)

    
    #Edit section
    $scope.pairs = []

    $scope.addKeyVal = ->
        if $scope.pairs.length is 0 || $scope.pairs[$scope.pairs.length-1].key
            $scope.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty fields first'

    $scope.removeKeyVal = (index) ->
        $scope.pairs.splice(index, 1)
