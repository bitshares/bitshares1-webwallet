angular.module("app").controller "DialogConfirmationController", ($scope, $modalInstance, title, message, action) ->

    $scope.title=title
    $scope.message = message

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $modalInstance.close("ok")
