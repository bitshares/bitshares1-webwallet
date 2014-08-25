angular.module("app").controller "DialogWithDataController", ($scope, $modalInstance, data, action) ->

    $scope.data = data

    $scope.cancel = ->
        $modalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $modalInstance.close("ok")
