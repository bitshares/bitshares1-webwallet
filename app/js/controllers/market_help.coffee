angular.module("app").controller "MarketHelpController", ($scope, MarketService) ->
    $scope.market = MarketService.market
