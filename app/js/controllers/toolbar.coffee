angular.module("app").controller "ToolbarController", ($scope) ->

    $scope.back = ->
        $scope.history_back()

    $scope.forward = ->
        $scope.history_forward()
