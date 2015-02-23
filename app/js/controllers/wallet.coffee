angular.module("app").controller "WalletController", ($scope) ->
    
    $scope.brainkey = {}
    $scope.brainkey_submit=()->
        wallet_api = window.wallet_api
        wallet = wallet_api.wallet
        bk = $scope.brainkey
        bk.pw_invalid = not(
            wallet.validate_password bk.password
        )
        if not $scope.brainkey.pw_invalid
            bk.password = ""
            bk.text = wallet_api.get_brainkey()