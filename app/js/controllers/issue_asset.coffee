angular.module("app").controller "IssueAssetController", ($scope, $location, $stateParams, RpcService, Wallet, Growl, Shared) ->
    $scope.issue_asset = 
        amount : 0.0
        symbol : ""
        to : Shared.contactName
        memo : ""

    $scope.issue = ->
        RpcService.request('wallet_asset_issue', [$scope.issue_asset.amount, $scope.issue_asset.symbol, $scope.issue_asset.to, $scope.issue_asset.memo]).then (response) ->
          $scope.issue_asset.amount = 0.0
          $scope.issue_asset.symbol = ""
          $scope.issue_asset.to = Shared.contactName
          $scope.issue_asset.memo = ""
          Growl.notice "", "Transaction broadcasted (#{JSON.stringify(response.result)})"
