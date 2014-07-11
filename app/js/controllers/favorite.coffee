angular.module("app").controller "FavoriteController", ($scope, $state, $location, $modal, $q, $http, $rootScope, RpcService, WalletAPI, Shared, Utils, Wallet) ->
    $scope.contacts = []

    $scope.refresh_contacts = ->
        $scope.contacts = []

        for n, c of Wallet.accounts
            if !c.is_my_account and @isFavorite(c)
                $scope.contacts.push c

    Wallet.refresh_accounts().then -> 
        $scope.refresh_contacts()

    $scope.$watchCollection ->
        Wallet.accounts
    , ->
        $scope.refresh_contacts()

    $scope.isFavorite = (account)->
      account.private_data && account.private_data.gui_data.favorite

    $scope.toggleFavorite = (name) ->
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will remove " + name + " from favorites"
                action: -> -> yesToggleFavorite(name)

    yesToggleFavorite = (name)->
        Wallet.refresh_accounts().then ()->
            if (Wallet.accounts[name].private_data)
                private_data=Wallet.accounts[name].private_data
            else
                private_data={}
            if !(private_data.gui_data)
                private_data.gui_data={}
            private_data.gui_data.favorite=!(private_data.gui_data.favorite)
            Wallet.account_update_private_data(name, private_data).then ->
                Wallet.refresh_accounts()
