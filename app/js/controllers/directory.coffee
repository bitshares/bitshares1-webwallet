angular.module("app").controller "DirectoryController", ($scope, $state, $location, $rootScope, $filter, $modal, Blockchain, Wallet, WalletAPI, Utils) ->
    $scope.alphabet = "abcdefghijklmnopqrstuvwxyz"
    $scope.first_letter = ""

    # tabs
    $scope.tabs = []
    $scope.tabs.push { heading: "directory.favorites", route: "directory.favorites", active: true }
    $scope.tabs.push { heading: "directory.unregistered", route: "directory.unregistered", active: false }
    $scope.tabs.push { heading: "directory.registered", route: "directory.registered", active: false }
    $scope.tabs.push { heading: "directory.assets", route: "directory.assets", active: false }
    $scope.goto_tab = (route) ->
        params = {letter: $scope.first_letter}
        $state.go route, params
    $scope.active_tab = (route) -> $state.is route
    $scope.$on "$stateChangeSuccess", ->
        if $state.current.name == "directory.registered"
            $scope.first_letter = $state.params.letter or "a"
        $scope.tabs.forEach (tab) ->
            tab.active = $scope.active_tab(tab.route)

    $scope.$watch ->
        $scope.first_letter
    , (value) ->
        return unless value
        $scope.q.name = ""
        promise = Blockchain.list_accounts(value, 10000)
        promise.then (reg) ->
            fl_accounts = []
            for a in reg
                continue if a.name.lastIndexOf(value, 0) != 0
                fl_accounts.push a
            $scope.reg = fl_accounts
            $scope.p.numberOfPages = Math.ceil(fl_accounts.length / $scope.p.pageSize)
        $rootScope.showLoadingIndicator promise

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

    $scope.toggleFavorite = (name) ->
        is_favorite=true
        if (Wallet.accounts[name] && Wallet.accounts[name].is_favorite)
            is_favorite=false
        WalletAPI.account_set_favorite(name, is_favorite).then ()->
            Wallet.refresh_accounts()
