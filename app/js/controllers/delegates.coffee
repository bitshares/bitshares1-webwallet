angular.module("app").controller "DelegatesController", ($scope, $location, $state, Growl, Blockchain, Wallet) ->

    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.approved_delegates = Wallet.approved_delegates

    Wallet.refresh_accounts()
    Blockchain.refresh_delegates()


    $scope.toggleVoteUp = (name) ->
        if name not of Wallet.approved_delegates or Wallet.approved_delegates[name] < 1
            Wallet.set_trust(name, 1)
        else
            Wallet.set_trust(name, 0)
