angular.module("app").controller "NewContactController", ($scope, $modalInstance, Wallet, refresh) ->

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
            $modalInstance.close("ok")
            refresh()
