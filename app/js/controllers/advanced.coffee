angular.module("app").controller "AdvancedController", ($scope, $state) ->
    # tabs
    $scope.tabs = []
    $scope.tabs.push { heading: "", route: "advanced.preferences", active: true }
    $scope.tabs.push { heading: "", route: "advanced.console", active: false }
    $scope.goto_tab = (route) ->
        $state.go route
    $scope.active_tab = (route) -> $state.is route
    $scope.$on "$stateChangeSuccess", ->
        $scope.tabs.forEach (tab) ->
            tab.active = $scope.active_tab(tab.route)

    $scope.open_block_explorer = ->
        open_external_url("http://bitsharesblocks.com/home")
        return null
