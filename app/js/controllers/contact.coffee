angular.module("app").controller "ContactController", ($scope, $location, $stateParams, Wallet, Utils) ->

    $scope.utils = Utils
    Wallet.get_account($stateParams.name).then (acct) ->
        $scope.account = acct

    $scope.toggleVoteUp = (name) ->
        if name not in Wallet.approved_delegates or Wallet.approved_delegates[name] < 1
            Wallet.set_trust(name, true)
        else
            Wallet.set_trust(name, true)
