angular.module("app").controller "AccountController", ($scope, $filter, $location, $stateParams, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain) ->

    $scope.refresh_addresses=Wallet.refresh_accounts
    name = $stateParams.name
    $scope.utils = Utils
    $scope.account = Wallet.accounts[name]
    $scope.balances = Wallet.balances[name]
    $scope.formatAsset = Utils.formatAsset
    $scope.symbol = "XTS"

    $scope.trust_level = Wallet.approved_delegates[name]
    $scope.wallet_info = {file : "", password : ""}
    
    $scope.private_key = {value : ""}
    $scope.p={}
    $scope.p.pendingRegistration = Wallet.pendingRegistrations[name]

    Wallet.refresh_account(name)
    Wallet.refresh_balances()

    $scope.$watch ->
        Wallet.accounts[name]
    , ->
        if Wallet.accounts[name]
            acct = Wallet.accounts[name]
            $scope.account = Wallet.accounts[name]
            $scope.balances = Wallet.balances[name]
            Wallet.refresh_transactions_on_update()

    $scope.$watch ->
        Wallet.balances[name]
    , ->
        if Wallet.balances[name]
            $scope.balances = Wallet.balances[name]

    Blockchain.get_config().then (config) ->
        $scope.memo_size_max = config.memo_size_max
        $scope.addr_symbol = config.symbol

    $scope.import_key = ->
        WalletAPI.import_private_key($scope.private_key.value, $scope.account.name).then (response) ->
            $scope.private_key.value = ""
            Growl.notice "", "Your private key was successfully imported."
            refresh_account()

    $scope.import_wallet = ->
        WalletAPI.import_bitcoin($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name).then (response) ->
            $scope.wallet_info.file = ""
            $scope.wallet_info.password = ""
            Growl.notice "The wallet was successfully imported."
            Wallet.refresh_account(name)

    yesSend = ->
        WalletAPI.transfer($scope.amount, $scope.symbol, $scope.account.name, $scope.payto, $scope.memo).then (response) ->
            $scope.payto = ""
            $scope.amount = ""
            $scope.memo = ""
            Growl.notice "", "Transaction broadcasted (#{angular.toJson(response.result)})"
            Wallet.refresh_account(name)
            $scope.t_active=true

    $scope.send = ->
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will send " + $scope.amount + " " + $scope.symbol + " to " + $scope.payto
                action: -> yesSend

    $scope.newContactModal = ->
      $modal.open
        templateUrl: "newcontact.html"
        controller: "NewContactController"

    $scope.addContactFromTo = ->
      if payto and payto.value and $scope.addr_symbol and (payto.value.indexOf $scope.addr_symbol) == 0 and payto.value.length == $scope.addr_symbol.length + 50
          $modal.open
            templateUrl: "newcontact.html"
            controller: "NewContactAddrController"
            resolve:
                addr: ->
                    payto.value
                action: ->
                    (contact)->
                        $scope.payto = contact
                    

    $scope.toggleVoteUp = ->
        if name not of Wallet.approved_delegates or Wallet.approved_delegates[name] < 1
            console.log "setting trust..."
            Wallet.set_trust(name, true).then (approved) =>
                console.log "TODO if setting trust failed then alert user"
                #if trust == false then do stuff
                $scope.trust_level = true
        else
            # TODO see above
            Wallet.set_trust(name, false).then (approved) =>
                $scope.trust_level = false

    $scope.toggleFavorite = ->
        address = $scope.account.owner_key
        Wallet.wallet_add_contact_account(name, address).then ()->
            # TODO: move to wallet service
            Wallet.refresh_accounts().then ()->
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

    #x-editable
    $scope.updateUser = (newName) ->
        Wallet.wallet_rename_account(name, newName).then ->
            $location.path("/accounts/"+newName)

