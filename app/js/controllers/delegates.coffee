angular.module("app").controller "DelegatesController", ($scope, $location, $state, Growl, Blockchain, Wallet) ->

    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.trust_levels = Wallet.trust_levels

    Wallet.refresh_accounts()
    Blockchain.refresh_delegates()


    $scope.toggleVoteUp = (name) ->
        if name not of Wallet.trust_levels or Wallet.trust_levels[name] < 1
            Wallet.set_trust(name, 1)
        else
            Wallet.set_trust(name, 0)
    
    $scope.toggleVoteDown = (name) ->
        if name not of Wallet.trust_levels or Wallet.trust_levels[name] > -1
            Wallet.set_trust(name, -1)
        else
            Wallet.set_trust(name, 0)
