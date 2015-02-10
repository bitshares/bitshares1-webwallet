angular.module("app").controller "IssueAssetController", ($scope, $location, $stateParams, RpcService, Wallet, Growl, Shared, BlockchainAPI, Utils, $modal, Blockchain) ->

    $scope.issue_asset =
        amount : ""
        asset : null
        to : $stateParams.name
        memo : ""

    $scope.issue = ->
        $modal.open
            templateUrl: "dialog-confirmation.html"
            controller: "DialogConfirmationController"
            resolve:
                title: -> "Are you sure?"
                message: -> "This will issue " + Utils.formatDecimal($scope.issue_asset.amount) + " " + $scope.issue_asset.asset.symbol + " to " + $scope.issue_asset.to
                action: -> 
                    ->
                        RpcService.request('wallet_asset_issue', [$scope.issue_asset.amount, $scope.issue_asset.asset.symbol, $scope.issue_asset.to, $scope.issue_asset.memo]).then (response) ->
                          $scope.issue_asset.amount = 0.0
                          $scope.issue_asset.to = $stateParams.name
                          $scope.issue_asset.memo = ""
                          Growl.notice "", "Transaction broadcasted"

    $scope.utils = Utils

    Blockchain.get_info().then (config) ->
        $scope.memo_size_max = config.memo_size_max

    $scope.newContactModal = ->
        $modal.open
            templateUrl: "addressbookmodal.html"
            controller: "AddressBookModalController"
            resolve:
                contact_name: ->
                    $scope.issue_asset.to
                add_contact_mode: ->
                    false
                action: ->
                    (contact)->
                        $scope.issue_asset.to = contact