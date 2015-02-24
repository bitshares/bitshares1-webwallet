angular.module("app").controller "WalletController", ($scope, Growl) ->
    
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
    
    $scope.delete_confirmed = no
    $scope.delete_submit=()->
        wallet_api = window.wallet_api
        wallet = wallet_api.wallet
        bk = $scope.brainkey
        bk.delete_confirmed = (
            wallet.validate_password bk.delete_password
        )
    $scope.deleteWallet= ()->
        wallet_api = window.wallet_api
        wallet = wallet_api.wallet
        WalletDb = window.bts.wallet.WalletDb
        wallet_name = wallet_api.wallet.wallet_db.wallet_name
        try
            wallet.delete()
            Growl.notice "","Wallet deleted"
            wallet_api.lock()
        catch error
            Growl.notice "","Error deleting wallet #{error}"
    $scope.cancelDelete= ()->
        bk = $scope.brainkey
        bk.delete_password = undefined
        bk.delete_confirmed = no