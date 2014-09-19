angular.module("app").controller "DialogTransferConfirmationController", ($scope, $modalInstance, title, trx, action, xts_transfer) ->

    $scope.title=title
    $scope.trx = trx

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $modalInstance.close("ok")
        
    $scope.xts_transfer=xts_transfer
        
