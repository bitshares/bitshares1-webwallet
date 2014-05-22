angular.module("app").controller "TransactionsController", ($scope, $location, RpcService) ->
  $scope.transactions = []

  fromat_address = (addr) ->
    return "-" if !addr or addr.length == 0
    res = ""
    angular.forEach addr, (a) ->
      res += ", " if res.length > 0
      res += a[1]
    res
  format_amount = (delta_balance) ->
  	# TO DO: search for all deposit_op_type with asset_id 0 and sum them
    return "-" if !delta_balance or delta_balance.length == 0
    first_asset = delta_balance[0]
    return "-" if !first_asset or first_asset.length < 2
    first_asset[1]

  $scope.load_transactions = ->
    RpcService.request("wallet_rescan_blockchain_state").then (response) ->
      RpcService.request("wallet_get_transaction_history").then (response) ->
        #console.log "--- transactions = ", response
        $scope.transactions.splice(0, $scope.transactions.length)
        angular.forEach response.result, (val) ->
          $scope.transactions.push
            block_num: val.location.block_num
            trx_num: val.location.trx_num
            time: val.received
            amount: val.trx.operations[0].data.amount
            from: val.trx.operations[0].data.balance_id.slice(-5)
            to: val.trx.operations[1].data.condition.data.owner.slice(-5)
            memo: val.memo

  $scope.load_transactions()

  $scope.rescan = ->
    $scope.load_transactions()
