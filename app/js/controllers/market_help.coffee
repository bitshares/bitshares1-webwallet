angular.module("app").controller "MarketHelpController", ($scope, $state, MarketService) ->
    $scope.market = MarketService.market
    