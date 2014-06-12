angular.module("app").controller "ContactController", ($scope, $location, $stateParams, Wallet, Utils) ->

    $scope.utils = Utils
    Wallet.get_account($stateParams.name).then (acct) ->
        $scope.account = acct

    $scope.toggleVoteUp = (name) ->
        if name not in Wallet.trust_levels or Wallet.trust_levels[name] < 1
            Wallet.set_trust(name, 1)
        else
            Wallet.set_trust(name, 0)
    
    $scope.toggleVoteDown = (name) ->
        if name not in Wallet.trust_levels or Wallet.trust_levels[name] > -1
            Wallet.set_trust(name, -1)
        else
            Wallet.set_trust(name, 0)
