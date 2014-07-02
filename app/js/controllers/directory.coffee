angular.module("app").controller "DirectoryController", ($scope, $location, Blockchain, Wallet, WalletAPI, Utils) ->
  $scope.reg = []
  Blockchain.list_accounts().then (reg) ->
    $scope.reg = reg

  $scope.contacts = {}
  $scope.refresh_contacts = ->
      Wallet.refresh_accounts().then () ->
          $scope.contacts = {}
          angular.forEach Wallet.accounts, (v, k) ->
              if Utils.is_registered(v)
                  $scope.contacts[k] = v

  $scope.refresh_contacts()

  $scope.isFavorite = (r)->
      $scope.contacts[r.name] && $scope.contacts[r.name].private_data && $scope.contacts[r.name].private_data.gui_data.favorite

  $scope.addToContactsAndToggleFavorite = (name, address) ->
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
                $scope.refresh_contacts()
