angular.module("app").controller "AssetsController", ($scope, $location) ->

    $scope.assets = Blockchain.assets
    $scope.my_assets = Wallet.assets

