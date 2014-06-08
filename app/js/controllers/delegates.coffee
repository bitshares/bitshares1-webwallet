angular.module("app").controller "DelegatesController", ($scope, $location, $state, Growl, Wallet) ->
  $scope.delegates=[]
  refresh_delegates = ->
    Wallet.blockchain_list_delegates().then (delegates) ->
      $scope.delegates=delegates
      console.log(delegates)
  refresh_delegates()

  $scope.voteUp = (index)->
    Wallet.wallet_set_delegate_trust_level($scope.delegates[index].name, 1).then (trx) ->
      $scope.delegates[index].vote_up = !$scope.delegates[index].vote_up
      $scope.delegates[index].vote_down = false


  $scope.voteDown = (index)->
    Wallet.wallet_set_delegate_trust_level($scope.delegates[index].name, -1).then (trx) ->
      $scope.delegates[index].vote_down = !$scope.delegates[index].vote_down
      $scope.delegates[index].vote_up = false
