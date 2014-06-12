angular.module("app").controller "DelegatesController", ($scope, $location, $state, Growl, Wallet) ->
  $scope.delegates=[]
  trustLevels={}

  #Make this more efficient by executing HTTP calls in parallel
  refresh_delegates = ->
    Wallet.blockchain_list_delegates().then (delegates) ->
      #$scope.inactiveDelegates=delegates
      #$scope.delegates=$scope.inactiveDelegates.splice(0, $scope.activeDels)
      $scope.delegates=delegates
      #Make this more efficient by executing HTTP calls in parallel
      refresh_trust()
  refresh_delegates()
  
  refresh_trust = ->
    Wallet.wallet_list_contact_accounts().then (contacts) ->
      angular.forEach contacts, (val) =>
        trustLevels[val.name]=val.trust_level
      i = 0
      while i < $scope.delegates.length
        $scope.delegates[i].vote_up = (if trustLevels[$scope.delegates[i].name] > 0 then true else false)
        $scope.delegates[i].vote_down = (if trustLevels[$scope.delegates[i].name] < 0 then true else false)
        i++
  
  $scope.voteUp = (index)->
    vote=if $scope.delegates[index].vote_up is true then 0 else 1
    Wallet.wallet_set_delegate_trust_level($scope.delegates[index].name, vote).then (trx) ->
      $scope.delegates[index].vote_up = !$scope.delegates[index].vote_up
      $scope.delegates[index].vote_down = false


  $scope.voteDown = (index)->
    vote=if $scope.delegates[index].vote_down is true then 0 else -1
    Wallet.wallet_set_delegate_trust_level($scope.delegates[index].name, vote).then (trx) ->
      $scope.delegates[index].vote_down = !$scope.delegates[index].vote_down
      $scope.delegates[index].vote_up = false
    
