angular.module("app").controller "DialogTransferConfirmationController", ($scope, $translate, $modalInstance, trx, action, transfer_type) ->

    $scope.trx = trx
    if transfer_type == 'burn'
        $translate("account.wall.burn_confirmation").then (value) -> $scope.title = value
        $translate("account.wall.receiver").then (value) -> $scope.account_to = value
        $translate("account.wall.message").then (value) -> $scope.account_memo = value
    else
        $translate("account.transfer_authorization").then (value) -> $scope.title = value
        $translate("account.to").then (value) -> $scope.account_to = value
        $translate("account.memo").then (value) -> $scope.account_memo = value


    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $modalInstance.close("ok")
        
    $scope.transfer_type = transfer_type
        
