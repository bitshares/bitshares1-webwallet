# Warning: this is a generated file, any changes made here will be overwritten by the build process

class BlockchainAPI

  constructor: (@q, @log, @rpc) ->
    #@log.info "---- Network API Constructor ----"


  # Returns current blockchain information and parameters
  # parameters: 
  # return_type: `json_object`
  get_info: (error_handler = null) ->
    @rpc.request('blockchain_get_info').then (response) ->
      response.result

  # Calculate the total supply of an asset from the current blockchain database state
  # parameters: 
  #   string `asset` - asset ticker symbol or ID to calculate supply for
  # return_type: `asset`
  calculate_supply: (asset, error_handler = null) ->
    @rpc.request('blockchain_calculate_supply', [asset]).then (response) ->
      response.result

  # Calculate the total amount of a market-issued asset that is owed to the network by open short positions
  # parameters: 
  #   string `asset` - asset ticker symbol or ID to calculate debt for
  # return_type: `asset`
  calculate_debt: (asset, error_handler = null) ->
    @rpc.request('blockchain_calculate_debt', [asset]).then (response) ->
      response.result

  # Returns true if the local blockchain is synced with the network; false otherwise
  # parameters: 
  # return_type: `bool`
  is_synced: (error_handler = null) ->
    @rpc.request('blockchain_is_synced').then (response) ->
      response.result

  # Returns hash of block in best-block-chain at index provided
  # parameters: 
  #   uint32_t `block_number` - index of the block, example: 42
  # return_type: `block_id_type`
  get_block_hash: (block_number, error_handler = null) ->
    @rpc.request('blockchain_get_block_hash', [block_number]).then (response) ->
      response.result

  # Returns the number of blocks in the longest block chain
  # parameters: 
  # return_type: `uint32_t`
  get_block_count: (error_handler = null) ->
    @rpc.request('blockchain_get_block_count').then (response) ->
      response.result

  # Returns information about blockchain security level
  # parameters: 
  # return_type: `blockchain_security_state`
  get_security_state: (error_handler = null) ->
    @rpc.request('blockchain_get_security_state').then (response) ->
      response.result

  # Returns registered accounts starting with a given name upto a the limit provided
  # parameters: 
  #   account_name `first_account_name` - the first account name to include. May be either a name or an index
  #   int32_t `limit` - the maximum number of items to list
  # return_type: `account_record_array`
  list_accounts: (first_account_name, limit, error_handler = null) ->
    @rpc.request('blockchain_list_accounts', [first_account_name, limit]).then (response) ->
      response.result

  # Returns a list of recently registered accounts
  # parameters: 
  # return_type: `account_record_array`
  list_recently_registered_accounts: (error_handler = null) ->
    @rpc.request('blockchain_list_recently_registered_accounts').then (response) ->
      response.result

  # Returns registered assets starting with a given name upto a the limit provided
  # parameters: 
  #   asset_symbol `first_symbol` - the prefix of the first asset symbol name to include
  #   int32_t `limit` - the maximum number of items to list
  # return_type: `asset_record_array`
  list_assets: (first_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_list_assets', [first_symbol, limit]).then (response) ->
      response.result

  # returns all burn records associated with an account
  # parameters: 
  #   account_name `account_name` - the name of the account to fetch the burn records for
  # return_type: `burn_records`
  get_account_wall: (account_name, error_handler = null) ->
    @rpc.request('blockchain_get_account_wall', [account_name]).then (response) ->
      response.result

  # Return a list of transactions that are not yet in a block.
  # parameters: 
  # return_type: `signed_transaction_array`
  list_pending_transactions: (error_handler = null) ->
    @rpc.request('blockchain_list_pending_transactions').then (response) ->
      response.result

  # Get detailed information about an in-wallet transaction
  # parameters: 
  #   string `transaction_id` - the base58 transaction ID to return
  #   bool `exact` - whether or not a partial match is ok
  # return_type: `optional_blockchain_transaction_record`
  get_transaction: (transaction_id, exact, error_handler = null) ->
    @rpc.request('blockchain_get_transaction', [transaction_id, exact]).then (response) ->
      response.result

  # Retrieves the block header for the given block number or ID
  # parameters: 
  #   string `block` - block number or ID to retrieve
  # return_type: `odigest_block`
  get_block: (block, error_handler = null) ->
    @rpc.request('blockchain_get_block', [block]).then (response) ->
      response.result

  # Retrieves the detailed transaction information for a block
  # parameters: 
  #   string `block` - the number or id of the block to get transactions from
  # return_type: `blockchain_transaction_record_map`
  get_block_transactions: (block, error_handler = null) ->
    @rpc.request('blockchain_get_block_transactions', [block]).then (response) ->
      response.result

  # Retrieves the record for the given account name or ID
  # parameters: 
  #   string `account` - account name, ID, or public key to retrieve the record for
  # return_type: `optional_account_record`
  get_account: (account, error_handler = null) ->
    @rpc.request('blockchain_get_account', [account]).then (response) ->
      response.result

  # Retrieves the balance record for the given address
  # parameters: 
  #   address `owner_address` - address of the balance owner
  # return_type: `balance_record`
  get_balance: (owner_address, error_handler = null) ->
    @rpc.request('blockchain_get_balance', [owner_address]).then (response) ->
      response.result

  # Lists balance records starting at the given balance ID
  # parameters: 
  #   string `first_balance_id` - prefix of the first balance id to start at
  #   uint32_t `limit` - the maximum number of items to list
  # return_type: `balance_record_map`
  list_balances: (first_balance_id, limit, error_handler = null) ->
    @rpc.request('blockchain_list_balances', [first_balance_id, limit]).then (response) ->
      response.result

  # Retrieves the record for the given asset ticker symbol or ID
  # parameters: 
  #   string `asset` - asset ticker symbol or ID to retrieve
  # return_type: `optional_asset_record`
  get_asset: (asset, error_handler = null) ->
    @rpc.request('blockchain_get_asset', [asset]).then (response) ->
      response.result

  # Retrieves all current feeds for the given asset
  # parameters: 
  #   string `asset` - asset ticker symbol or ID to retrieve
  # return_type: `feed_entry_list`
  get_feeds_for_asset: (asset, error_handler = null) ->
    @rpc.request('blockchain_get_feeds_for_asset', [asset]).then (response) ->
      response.result

  # Retrieves all current feeds published by the given delegate
  # parameters: 
  #   string `delegate_name` - the name of the delegate to list feeds from
  # return_type: `feed_entry_list`
  get_feeds_from_delegate: (delegate_name, error_handler = null) ->
    @rpc.request('blockchain_get_feeds_from_delegate', [delegate_name]).then (response) ->
      response.result

  # Returns the bid side of the order book for a given market
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   asset_symbol `base_symbol` - the item being bought in this market
  #   uint32_t `limit` - the maximum number of items to return, -1 for all
  # return_type: `market_order_array`
  market_list_bids: (quote_symbol, base_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_market_list_bids', [quote_symbol, base_symbol, limit]).then (response) ->
      response.result

  # Returns the ask side of the order book for a given market
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   asset_symbol `base_symbol` - the item being bought in this market
  #   uint32_t `limit` - the maximum number of items to return, -1 for all
  # return_type: `market_order_array`
  market_list_asks: (quote_symbol, base_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_market_list_asks', [quote_symbol, base_symbol, limit]).then (response) ->
      response.result

  # Returns the short side of the order book for a given market
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   uint32_t `limit` - the maximum number of items to return, -1 for all
  # return_type: `market_order_array`
  market_list_shorts: (quote_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_market_list_shorts', [quote_symbol, limit]).then (response) ->
      response.result

  # Returns the covers side of the order book for a given market
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   uint32_t `limit` - the maximum number of items to return, -1 for all
  # return_type: `market_order_array`
  market_list_covers: (quote_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_market_list_covers', [quote_symbol, limit]).then (response) ->
      response.result

  # Returns the total collateral for an asset of a given type
  # parameters: 
  #   asset_symbol `symbol` - the symbol for the asset to count collateral for
  # return_type: `share_type`
  market_get_asset_collateral: (symbol, error_handler = null) ->
    @rpc.request('blockchain_market_get_asset_collateral', [symbol]).then (response) ->
      response.result

  # Returns the long and short sides of the order book for a given market
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   asset_symbol `base_symbol` - the item being bought in this market
  #   uint32_t `limit` - the maximum number of items to return, -1 for all
  # return_type: `pair<market_order_array,market_order_array>`
  market_order_book: (quote_symbol, base_symbol, limit, error_handler = null) ->
    @rpc.request('blockchain_market_order_book', [quote_symbol, base_symbol, limit]).then (response) ->
      response.result

  # Returns a list of recently filled orders in a given market, in reverse order of execution.
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   asset_symbol `base_symbol` - the item being bought in this market
  #   uint32_t `skip_count` - Number of transactions before head block to skip in listing
  #   uint32_t `limit` - The maximum number of transactions to list
  #   string `owner` - If present, only transactions belonging to this owner key will be returned
  # return_type: `order_history_record_array`
  market_order_history: (quote_symbol, base_symbol, skip_count, limit, owner, error_handler = null) ->
    @rpc.request('blockchain_market_order_history', [quote_symbol, base_symbol, skip_count, limit, owner]).then (response) ->
      response.result

  # Returns a list of price spreads in the given timeframe for the specified market.
  # parameters: 
  #   asset_symbol `quote_symbol` - the symbol name the market is quoted in
  #   asset_symbol `base_symbol` - the item being bought in this market
  #   timestamp `start_time` - The time to begin getting price history for
  #   time_interval_in_seconds `duration` - The maximum time period to get price history for
  #   market_history_key::time_granularity `granularity` - The frequency of price updates (each_block, each_hour, or each_day)
  # return_type: `market_history_points`
  market_price_history: (quote_symbol, base_symbol, start_time, duration, granularity, error_handler = null) ->
    @rpc.request('blockchain_market_price_history', [quote_symbol, base_symbol, start_time, duration, granularity]).then (response) ->
      response.result

  # Returns a list of the current round's active delegates in signing order
  # parameters: 
  #   uint32_t `first` - 
  #   uint32_t `count` - 
  # return_type: `account_record_array`
  list_active_delegates: (first, count, error_handler = null) ->
    @rpc.request('blockchain_list_active_delegates', [first, count]).then (response) ->
      response.result

  # Returns a list of all the delegates sorted by vote
  # parameters: 
  #   uint32_t `first` - 
  #   uint32_t `count` - 
  # return_type: `account_record_array`
  list_delegates: (first, count, error_handler = null) ->
    @rpc.request('blockchain_list_delegates', [first, count]).then (response) ->
      response.result

  # Returns the block headers for blocks in a range
  # parameters: 
  #   uint32_t `first_block_number` - the first block to list. If limit is negative, a first_block_number of 0 indicates the head block; otherwise, 0 indicates the first block
  #   int32_t `limit` - the maximum number of blocks to return. A negative value means to start at the head block and work backwards; a positive value means to start at the first block
  # return_type: `block_record_array`
  list_blocks: (first_block_number, limit, error_handler = null) ->
    @rpc.request('blockchain_list_blocks', [first_block_number, limit]).then (response) ->
      response.result

  # Returns any delegates who were supposed to produce a given block number but didn't
  # parameters: 
  #   uint32_t `block_number` - The block to examine
  # return_type: `account_name_array`
  list_missing_block_delegates: (block_number, error_handler = null) ->
    @rpc.request('blockchain_list_missing_block_delegates', [block_number]).then (response) ->
      response.result

  # dumps the fork data to graphviz format
  # parameters: 
  #   uint32_t `start_block` - the first block number to consider
  #   uint32_t `end_block` - the last block number to consider
  #   string `filename` - the filename to save to
  # return_type: `string`
  export_fork_graph: (start_block, end_block, filename, error_handler = null) ->
    @rpc.request('blockchain_export_fork_graph', [start_block, end_block, filename]).then (response) ->
      response.result

  # returns a list of all blocks for which there is a fork off of the main chain
  # parameters: 
  # return_type: `map<uint32_t, vector<fork_record>>`
  list_forks: (error_handler = null) ->
    @rpc.request('blockchain_list_forks').then (response) ->
      response.result

  # Query the block production slot records for a particular delegate
  # parameters: 
  #   string `delegate_name` - Delegate whose block production slot records to query
  # return_type: `slot_records_list`
  get_delegate_slot_records: (delegate_name, error_handler = null) ->
    @rpc.request('blockchain_get_delegate_slot_records', [delegate_name]).then (response) ->
      response.result

  # Get the delegate that signed a given block
  # parameters: 
  #   string `block` - block number or ID to retrieve the signee for
  # return_type: `string`
  get_block_signee: (block, error_handler = null) ->
    @rpc.request('blockchain_get_block_signee', [block]).then (response) ->
      response.result

  # Returns a list of market transactions executed on a given block.
  # parameters: 
  #   uint32_t `block_number` - Block to get market operations for.
  # return_type: `market_transaction_array`
  list_market_transactions: (block_number, error_handler = null) ->
    @rpc.request('blockchain_list_market_transactions', [block_number]).then (response) ->
      response.result

  # Returns the status of a particular market, including any trading errors.
  # parameters: 
  #   asset_symbol `quote_symbol` - quote symbol
  #   asset_symbol `base_symbol` - base symbol
  # return_type: `market_status`
  market_status: (quote_symbol, base_symbol, error_handler = null) ->
    @rpc.request('blockchain_market_status', [quote_symbol, base_symbol]).then (response) ->
      response.result

  # Returns the total shares in the genesis block which have never been fully or partially claimed.
  # parameters: 
  # return_type: `asset`
  unclaimed_genesis: (error_handler = null) ->
    @rpc.request('blockchain_unclaimed_genesis').then (response) ->
      response.result

  # Verify that the given signature proves the given hash was signed by the given account.
  # parameters: 
  #   string `signing_account` - The account the signature claims to be from
  #   sha256 `hash` - The hash the signature claims to be for
  #   compact_signature `signature` - A signature produced by wallet_sign_hash
  # return_type: `bool`
  verify_signature: (signing_account, hash, signature, error_handler = null) ->
    @rpc.request('blockchain_verify_signature', [signing_account, hash, signature]).then (response) ->
      response.result



angular.module("app").service("BlockchainAPI", ["$q", "$log", "RpcService", BlockchainAPI])
