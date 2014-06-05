angular.module("app").controller "TransactionsController", ($scope, $location, $state, Shared, Wallet) ->
  $scope.transactions = []

  Wallet.get_transactions(Shared.trxFor).then (trs) ->
    $scope.transactions = trs

  $scope.rescan = ->
    $scope.load_transactions()

  $scope.viewAccount = (name)->
    Shared.accountName  = name
    Shared.accountAddress = "TODO:  Look the address up somewhere"
    Shared.trxFor = name


  $scope.viewContact = (name)->
    Shared.contactName  = name
    Shared.contactAddress = "TODO:  Look the address up somewhere"
    Shared.trxFor = name

