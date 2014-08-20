angular.module("app").controller "DialogOKController", ($scope, $modalInstance, title, message, bsStyle) ->

    $scope.title=title
    $scope.message = message
    $scope.bsStyle = bsStyle

    $scope.ok = ->
        $modalInstance.close("ok")
