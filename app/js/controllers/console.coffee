angular.module("app").controller "ConsoleController", ($scope, $location, RpcService) ->
    $scope.outputs=[]
	#  here for testing typeahead. remove later
    $scope.states = ['about','blockchain_get_account_record','blockchain_get_account_record_by_id','blockchain_get_asset_record','blockchain_get_asset_record_by_id','blockchain_get_block','blockchain_get_block_by_number','blockchain_get_blockcount','blockchain_get_blockhash','blockchain_get_config','blockchain_get_pending_transactions','blockchain_get_proposal_votes','blockchain_get_security_state','blockchain_get_transaction','blockchain_list_blocks','blockchain_list_current_round_active_delegates','blockchain_list_delegates','blockchain_list_proposals','blockchain_list_registered_accounts','blockchain_list_registered_assets','blockchain_market_list_bids','execute_command_line','get_info','help','network_add_node','network_broadcast_transaction','network_get_advanced_node_parameters','network_get_block_propagation_data', 'network_get_connection_count','network_get_info','network_get_peer_info','network_get_transaction_propagation_data','network_set_advanced_node_parameters','wallet_account_balance','wallet_account_export_private_key','wallet_account_list_public_keys','wallet_account_rename','wallet_account_transaction_history','wallet_asset_issue','wallet_clear_pending_transactions','wallet_close','wallet_create','wallet_create_from_json','wallet_export_to_json','wallet_get_info','wallet_get_name','wallet_get_pretty_transaction','wallet_import_bitcoin','wallet_import_electrum','wallet_import_keyhotee','wallet_import_multibit','wallet_import_private_key','wallet_list','wallet_list_contact_accounts','wallet_list_receive_accounts','wallet_list_unspent_balances','wallet_lock','wallet_market_cancel_order','wallet_market_order_list','wallet_open','wallet_remove_contact_account','wallet_rescan_blockchain','wallet_set_priority_fee','wallet_transfer','wallet_withdraw_delegate_pay']
	
    $scope.command = ""

    $scope.submit = ->
        RpcService.request('execute_command_line', [$scope.command]).then (response) =>  #TODO replace when CommonAPI is added
            $scope.outputs.unshift(">> " + $scope.command + "\n\n" + response.result)
            $scope.command=""

