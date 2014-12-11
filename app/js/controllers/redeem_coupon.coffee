angular.module("app").controller "RedeemCouponController", ($scope, $stateParams, $q, $http, Utils, Blockchain, Wallet) ->
    $scope.coupon = { faucet_url: $stateParams.faucet, code: $stateParams.code}
    $scope.accounts = []

    Wallet.refresh_accounts().then ->
        for a, v of Wallet.accounts
            $scope.accounts.push a if v.is_my_account
        $scope.coupon.to = $scope.accounts[0] if $scope.accounts.length > 0
        $scope.code_changed()

    get_faucet_url = ->
        return null unless $scope.coupon.faucet_url
        url = $scope.coupon.faucet_url
        match = /^https?:\/\/(.+)\/?$/.exec(url)
        url = "http://#{url}" unless match
        url = url.slice(0,-1) if url[url.length-1] == "/"
        return url

    jsonp_request = (code, redeem, account_name, account_key) ->
        url = get_faucet_url()
        return unless url
        api_url = "#{url}/api/v1/coupons/#{code}"
        deferred = $q.defer()
        params = callback: 'JSON_CALLBACK'
        if redeem
            api_url += "/redeem"
            params.account_name = account_name
            params.account_key = account_key
        $http.jsonp(api_url, params: params)
        .success (data, status , header, config) ->
            #console.log "------ coupon success ------>", data, status
            deferred.resolve(data.coupon)
        .error (data, status, headers, config) ->
            #console.log "------ coupon error ------>"
            deferred.reject(false)
        deferred.promise

    update_coupon_status = (cpn) ->
        if cpn.status == "ok"
            $scope.coupon.ok = true
            $scope.coupon.error = null
            Blockchain.get_asset(cpn.asset_id).then (asset) ->
                asset_amount = angular.extend({amount: cpn.amount}, asset)
                $scope.coupon.amount = Utils.formatAsset(asset_amount)
        else if cpn.status == "notfound"
            $scope.coupon.ok = false
            $scope.coupon.error = "Coupon not found"
        else if cpn.status == "expired"
            $scope.coupon.ok = false
            $scope.coupon.error = "Coupon expired"
        else if cpn.status == "redeemed"
            $scope.coupon.ok = false
            $scope.coupon.error = "Coupon is already redeemed"

    $scope.redeem = ->
        return unless $scope.coupon.to
        account_name = $scope.coupon.to
        active_key = Wallet.accounts[account_name].active_key

        jsonp_request($scope.coupon.code, true, account_name, active_key).then (cpn) ->
            update_coupon_status(cpn)
        , (error) ->
            $scope.coupon.ok = false
            $scope.coupon.error = "Faucet Error"

    $scope.code_changed = ->
        unless $scope.coupon.code?.length == 15
            $scope.coupon.ok = false
            $scope.coupon.amount = null
            return
        jsonp_request($scope.coupon.code, false).then (cpn) ->
            update_coupon_status(cpn)
        , (error) ->
            $scope.coupon.ok = false
            $scope.coupon.error = "Faucet Error"