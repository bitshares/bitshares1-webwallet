angular.module("app").controller "ToolbarController", ($scope, $window, $modal, $location) ->
    $scope.back = ()->
        $window.history.back()

    $scope.newContactModal = ->
        $modal.open
            templateUrl: "newcontact.html"
            controller: "NewContactController"
            resolve:
                addr: -> null
                action: ->
                    (contact)->
                        $location.path "accounts/#{contact}"