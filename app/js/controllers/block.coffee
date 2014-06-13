angular.module("app").controller "BlockController", ($scope, $location, $stateParams, $state, Blockchain, Utils) ->
    
    $scope.number = $stateParams.number
