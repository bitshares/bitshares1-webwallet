angular.module("app").controller "ToolbarController", ($scope, $rootScope) ->

    $scope.back = ->
        $scope.history_back()

    $scope.forward = ->
        $scope.history_forward()

    $scope.open_context_help = ->
        $scope.context_help.open = true
