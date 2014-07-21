angular.module("app").controller "FavoriteController", ($scope, $state, $location, $modal, $q, $http, $rootScope, WalletAPI, Utils, Wallet) ->
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
      account.is_favorite

    $scope.toggleFavorite = (name) ->
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will remove " + name + " from favorites"
                action: -> -> yesToggleFavorite(name)

    yesToggleFavorite = (name)->
        WalletAPI.account_set_favorite(name, !Wallet.accounts[name].is_favorite).then ()->
            Wallet.refresh_accounts()
