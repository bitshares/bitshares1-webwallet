angular.module("app").controller "NewContactAddrController", ($scope, $modalInstance, Wallet, addr, action) ->
    if addr
        $scope.address = addr

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            Wallet.refresh_accounts()
            action($scope.name)
            $modalInstance.close("ok")

