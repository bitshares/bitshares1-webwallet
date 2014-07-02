angular.module("app").controller "FavoriteController", ($scope, $state, $location, $modal, $q, $http, $rootScope, RpcService, WalletAPI, Shared, Utils, Wallet) ->
    $scope.contacts = []

    $scope.refresh_contacts = ->
        WalletAPI.list_accounts().then (contacts) =>
            $scope.contacts = []

            for c in contacts
                if !c.is_my_account and @isFavorite(c)
                    $scope.contacts.push c

    $scope.refresh_contacts()

    $scope.isFavorite = (account)->
      account.private_data && account.private_data.gui_data.favorite
    

    $scope.toggleFavorite = (name)->
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
