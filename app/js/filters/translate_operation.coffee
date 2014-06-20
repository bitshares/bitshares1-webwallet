angular.module("app").filter "translateOperation", (Blockchain, $filter, Utils)->
    (op) ->
        switch op.type
            when "withdraw_op_type" then ("Withdraw " + op.data.amount + " satoshi amount of asset")
            when "deposit_op_type" then ("Deposit " + Utils.formatAsset( $filter('toAsset') { "amount": op.data.amount, "asset_id" : op.data.condition.asset_id } ))
            when "register_account_op_type" then ("Register account name: " + op.data.name + " \nwith public data: " + op.data.public_data + ( if op.data.is_delegate then "\nThis account is registered as a delegate" else ""))
            else op
