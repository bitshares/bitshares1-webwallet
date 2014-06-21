angular.module("app").filter "translateOperation", (Blockchain, $filter, Utils)->
    (op) ->
        switch op.type
            when "withdraw_op_type" then ("Withdraw " + op.data.amount + " satoshi amount of asset")
            when "deposit_op_type" then ("Deposit " + Utils.formatAsset( $filter('toAsset') { "amount": op.data.amount, "asset_id" : op.data.condition.asset_id } ))
            when "register_account_op_type" then ("Register account name: " + op.data.name + " \nwith public data: " + (if op.data.public_data then angular.toJson(op.data.public_data) else "") + ( if op.data.is_delegate then "\nThis account is registered as a delegate" else ""))
            when "create_asset_op_type" then ("Create new asset with symbol " + op.data.symbol + " , the name of this asset is " + op.data.name + ", the detail is " + angular.toJson(op))
            else op
