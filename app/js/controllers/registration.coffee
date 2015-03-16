angular.module("app").controller "RegistrationController", ($scope, $modalInstance, $window, Wallet, WalletAPI, Shared, RpcService, Blockchain, Info, Utils, Observer) ->
    $scope.symbolOptions = []

    $scope.m = { subaccount: $scope.account.name.indexOf(".") > -1 }
    $scope.m.payrate = 50
    $scope.m.delegate = false
    $scope.available_faucets = [
        {id: 1, name: "faucet.bitshares.org", url: "https://faucet.bitshares.org/"},
        {id: 1000, name: "Add faucet", url: "add"}
    ]
    $scope.m.faucet = $scope.available_faucets[0]

    $scope.$watch ->
        Wallet.info.transaction_fee
    , ->
        Blockchain.get_asset(0).then (v)->
            $scope.delegate_reg_fee = Utils.formatAsset(Utils.asset(Info.info.delegate_reg_fee, v))
            $scope.transaction_fee = Utils.formatAsset(Utils.asset(Wallet.info.transaction_fee.amount, v))

    #this can be a dropdown instead of being hardcoded when paying for registration with multiple assets is possilbe
    $scope.symbol = Info.symbol


    refresh_accounts = ->
        $scope.accounts = {}
        for name, balances of Wallet.balances
            bals = []
            for symbol, asset of balances
                bals.push asset if asset.amount
            $scope.accounts[name] = [name, bals] if bals.length
            $scope.m.payfrom = if $scope.accounts[$scope.account.name] then $scope.accounts[$scope.account.name] else $scope.accounts[Object.keys($scope.accounts)[0]]

    Wallet.get_accounts().then ->
        refresh_accounts()

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.register = ->
        if !$scope.m.payfrom and $scope.m.faucet?.url and $scope.m.faucet.url != 'add'
            app_id = "0"
            app_id = magic_unicorn.get_app_id() if magic_unicorn? and magic_unicorn.get_app_id
            url = "#{$scope.m.faucet.url}?account_name=#{$scope.account.name}&active_key=#{$scope.account.active_key}&owner_key=#{$scope.account.owner_key}&app_id=#{app_id}"
            open_external_url(url)
            $modalInstance.close("ok")
            return

        payrate = if $scope.m.delegate then $scope.m.payrate else -1
        website = ""
        if $scope.account.private_data?.gui_data?.website
            website = $scope.account.private_data.gui_data.website

        Wallet.wallet_account_register($scope.account.name, $scope.m.payfrom[0], null, payrate, "public_account").then (response) ->
            $scope.p.pendingRegistration = Wallet.pendingRegistrations[$scope.account.name] = "pending"
            $modalInstance.close("ok")

    $scope.addCustomFaucet = ->
        faucets = $scope.available_faucets
        url = $scope.m.faucet_url
        match = /^https?:\/\/(.+)\/?$/.exec(url)
        if match
            new_faucet = {id: faucets.length, name: match[1], url: url}
        else
            new_faucet = {id: faucets.length, name: url, url: "https://#{url}"}
        faucets.push new_faucet
        faucets.sort (a, b) -> a.id - b.id
        $scope.m.faucet = new_faucet
