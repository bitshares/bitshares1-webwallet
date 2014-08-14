angular.module("app").controller "DialogTransferConfirmationController", ($scope, $modalInstance, title, trx, action) ->

    $scope.title=title
    $scope.trx = trx

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $modalInstance.close("ok")
