angular.module("app").controller "ToolbarController", ($scope, $window, $modal, $location) ->

    $scope.back = ->
        $window.history.back()

#    $scope.newContactModal = ->
#        $modal.open
#            templateUrl: "newcontactmodal.html"
#            controller: "NewContactModalController"
#            resolve:
#                addr: -> null
#                action: ->
#                    (contact)->
#                        $location.path "accounts/#{contact}"