angular.module("app").controller "ContactController", ($scope, $location, $stateParams, Wallet, Utils) ->

    $scope.utils = Utils
    Wallet.get_account($stateParams.name).then (acct) ->
        $scope.account = acct

    $scope.toggleVoteUp = (name) ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve
