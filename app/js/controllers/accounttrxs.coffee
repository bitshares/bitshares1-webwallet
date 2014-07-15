angular.module("app").controller "AccountTrxsController", ($scope, $location, $stateParams, $state, $filter, Wallet, Utils, Info, Blockchain) ->
    $scope.transactions = Wallet.transactions["*"] || []
    $scope.utils = Utils

    $scope.p = 
        currentPage : 0
        pageSize : 20
        numberOfPages : 0
    $scope.q =
        from: ""

    $scope.$watch ()->
        $scope.q.from
    , ()->
        $scope.p.numberOfPages = Math.ceil(($filter("filter") $scope.transactions,  $scope.q).length/$scope.p.pageSize)
        $scope.p.currentPage = 0
    
    Wallet.refresh_transactions().then ->
        $scope.transactions = Wallet.transactions["*"] || []
        $scope.p.numberOfPages = Math.ceil($scope.transactions.length/$scope.p.pageSize)

