#angular.module("app").controller "ReferralCodeController", ($scope, $stateParams, $q, $http, Utils, Blockchain, Wallet) ->
#    $scope.referral = { faucet_url: $stateParams.faucet, code: $stateParams.code, success: false }
#    $scope.accounts = []
#
#    Wallet.refresh_accounts().then ->
#        for a, v of Wallet.accounts
#            $scope.accounts.push a if v.is_my_account
#        $scope.referral.to = $scope.accounts[0] if $scope.accounts.length > 0
#        $scope.code_changed()
#
#    get_faucet_url = ->
#        return null unless $scope.referral.faucet_url
#        url = $scope.referral.faucet_url
#        match = /^https?:\/\/(.+)\/?$/.exec(url)
#        url = "http://#{url}" unless match
#        url = url.slice(0,-1) if url[url.length-1] == "/"
#        return url
#
#    jsonp_request = (code, redeem, account_name, account_key) ->
#        url = get_faucet_url()
#        deferred = $q.defer()
#        unless url
#            deferred.reject("nourl")
#            return deferred.promise
#        api_url = "#{url}/api/v1/referral_codes/#{code}"
#        params = callback: 'JSON_CALLBACK'
#        if redeem
#            api_url += "/redeem"
#            params.account_name = account_name
#            params.account_key = account_key
#        $http.jsonp(api_url, params: params)
#        .success (data, status , header, config) ->
#            deferred.resolve(data.referral_code)
#        .error (data, status, headers, config) ->
#            deferred.reject(false)
#        deferred.promise
#
#    update_referral_code_status = (cpn) ->
#        if cpn.status == "ok"
#            $scope.referral.ok = true
#            $scope.referral.error = null
#            Blockchain.get_asset(cpn.asset_id).then (asset) ->
#                asset_amount = angular.extend({amount: cpn.amount}, asset)
#                $scope.referral.amount = Utils.formatAsset(asset_amount)
#        else if cpn.status == "notfound"
#            $scope.referral.ok = false
#            $scope.referral.error = "Referral code not found"
#        else if cpn.status == "expired"
#            $scope.referral.ok = false
#            $scope.referral.error = "Referral code expired"
#        else if cpn.status == "redeemed"
#            $scope.referral.ok = false
#            $scope.referral.error = "Referral code is already redeemed"
#
#    $scope.redeem = ->
#        return unless $scope.referral.to
#        account_name = $scope.referral.to
#        active_key = Wallet.accounts[account_name].active_key
#
#        jsonp_request($scope.referral.code, true, account_name, active_key).then (cpn) ->
#            update_referral_code_status(cpn)
#            $scope.referral.success = (cpn.status == "ok")
#        , (error) ->
#            $scope.referral.ok = false
#            $scope.referral.error = "Faucet Error"
#
#    $scope.code_changed = ->
#        unless $scope.referral.code?.length == 15
#            $scope.referral.ok = false
#            $scope.referral.amount = null
#            return
#        jsonp_request($scope.referral.code, false).then (cpn) ->
#            update_referral_code_status(cpn)
#        , (error) ->
#            unless error == "nourl"
#                $scope.referral.ok = false
#                $scope.referral.error = "Faucet Error"