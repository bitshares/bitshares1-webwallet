angular.module("app").controller "DirectoryController", ($scope, $location, $filter, $modal, Blockchain, Wallet, WalletAPI, Utils) ->
    $scope.reg = []
    $scope.genesis_date = ""
    $scope.p =
        currentPage: 0
        pageSize: 20
        numberOfPages: 0
    $scope.q =
        name: ""
    $scope.delegate_active_hash_map = Blockchain.delegate_active_hash_map
    $scope.delegate_inactive_hash_map = Blockchain.delegate_inactive_hash_map


    $scope.accounts = Wallet.accounts
    Wallet.refresh_accounts().then ->
        $scope.accounts = Wallet.accounts

    $scope.$watch ()->
        $scope.q.name
    , ()->
        $scope.p.numberOfPages = Math.ceil(($filter("filter") $scope.reg, $scope.q).length / $scope.p.pageSize)
        $scope.p.currentPage = 0

    Blockchain.get_info().then (config) ->
        $scope.genesis_date = config.genesis_timestamp

    Blockchain.list_accounts(null, 1776).then (reg) ->
        $scope.reg = reg
        $scope.p.numberOfPages = Math.ceil($scope.reg.length / $scope.p.pageSize)

    $scope.contacts = {}
    $scope.refresh_contacts = ->
        $scope.contacts = {}
        angular.forEach Wallet.accounts, (v, k) ->
            if Utils.is_registered(v)
                $scope.contacts[k] = v

    Wallet.refresh_accounts().then ->
        $scope.refresh_contacts()

    $scope.$watchCollection ->
        Wallet.accounts
    , ->
        $scope.refresh_contacts()


    $scope.isFavorite = (r)->
        $scope.contacts[r.name] && $scope.contacts[r.name].is_favorite

    $scope.formatRegDate = (d) ->
        if d == $scope.genesis_date
            "Genesis"
        else
            $filter("prettyDate")(d)

    $scope.addToContactsAndToggleFavorite = (name, address) ->
        Wallet.wallet_add_contact_account(name, address).then ()->
            # TODO: move to wallet service
            Wallet.refresh_accounts().then ()->
                WalletAPI.account_set_favorite(name, !Wallet.accounts[name].is_favorite).then ()->
                    Wallet.refresh_accounts()
