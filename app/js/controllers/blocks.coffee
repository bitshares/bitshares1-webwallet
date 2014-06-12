angular.module("app").controller "BlocksController", ($scope, $location, $state, Growl, Wallet) ->
  $scope.blocks=[]

  #TODO make this more efficient by using parllel, and updating realtime
  refresh_blocks = ->
    Wallet.blockchain_list_blocks(1, 20).then (blocks) ->
      $scope.blocks=blocks
    refresh_blocks()
  
