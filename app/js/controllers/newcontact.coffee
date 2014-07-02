angular.module("app").controller "NewContactController", ($scope, $modalInstance, Wallet) ->

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            Wallet.refresh_accounts()
            $modalInstance.close("ok")
            
