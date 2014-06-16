angular.module("app").controller "AssetsController", ($scope, $location, Blockchain, Wallet) ->

    $scope.assets = Blockchain.assets
    $scope.my_assets = Wallet.assets

