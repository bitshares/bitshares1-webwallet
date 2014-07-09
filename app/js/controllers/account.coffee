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
    $scope.p={}
    $scope.p.pendingRegistration = Wallet.pendingRegistrations[name]

    refresh_account = ->
        Wallet.get_account(name).then (acct) ->
            $scope.account = acct
            $scope.balances = Wallet.balances[name]
            Wallet.refresh_transactions_on_update()
            $scope.edit={}
            $scope.edit.newemail = acct.private_data.gui_data.email
            $scope.edit.newwebsite = acct.private_data.gui_data.website
            if (acct.private_data.gui_custom_data_pairs)
              $scope.edit.pairs = acct.private_data.gui_custom_data_pairs
            else
              $scope.edit.pairs=[]
    refresh_account()

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
            refresh_account()

    yesSend = ->
        WalletAPI.transfer($scope.amount, $scope.symbol, $scope.account.name, $scope.payto, $scope.memo).then (response) ->
            $scope.payto = ""
            $scope.amount = ""
            $scope.memo = ""
            Growl.notice "", "Transaction broadcasted (#{angular.toJson(response.result)})"
            refresh_account()
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


    #Edit section

    $scope.addKeyVal = ->
        if $scope.edit.pairs.length is 0 || $scope.edit.pairs[$scope.edit.pairs.length-1].key
            $scope.edit.pairs.push {'key': null, 'value': null}
        else
            Growl.error 'Fill out empty fields first'

    $scope.removeKeyVal = (index) ->
        $scope.edit.pairs.splice(index, 1)
    
    $scope.submitEditAccount = ->
        Wallet.account_update_private_data(name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs}).then ->
            console.log('submitted', name,{'gui_data':{'email':$scope.edit.newemail,'website':$scope.edit.newwebsite},'gui_custom_data_pairs':$scope.edit.pairs})
            refresh_account()

