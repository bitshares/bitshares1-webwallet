# Warning: this is a generated file, any changes made here will be overwritten by the build process

class WalletAPI

  constructor: (@q, @log, @rpc, @interval) ->
    #@log.info "---- WalletAPI Constructor ----"


  # Extra information about the wallet.
  # parameters: 
  # return_type: `json_object`
  get_info:  ->
    @rpc.request('wallet_get_info').then (response) ->
      response.result

  # Opens the wallet of the given name
  # parameters: 
  #   wallet_name `wallet_name` - the name of the wallet to open
  # return_type: `void`
  open: (wallet_name) ->
    @rpc.request('wallet_open', [wallet_name]).then (response) ->
      response.result

  # Creates a wallet with the given name
  # parameters: 
  #   wallet_name `wallet_name` - name of the wallet to create
  #   new_passphrase `new_passphrase` - a passphrase for encrypting the wallet
  #   brainkey `brain_key` - a strong passphrase that will be used to generate all private keys, defaults to a large random number
  # return_type: `void`
  create: (wallet_name, new_passphrase, brain_key) ->
    @rpc.request('wallet_create', [wallet_name, new_passphrase, brain_key]).then (response) ->
      response.result

  # Returns the wallet name passed to wallet_open
  # parameters: 
  # return_type: `optional_wallet_name`
  get_name:  ->
    @rpc.request('wallet_get_name').then (response) ->
      response.result

  # Loads the private key into the specified account. Returns which account it was actually imported to.
  # parameters: 
  #   wif_private_key `wif_key` - A private key in bitcoin Wallet Import Format (WIF)
  #   account_name `account_name` - the name of the account the key should be imported into, if null then the key must belong to an active account
  #   bool `create_new_account` - If true, the wallet will attempt to create a new account for the name provided rather than import the key into an existing account
  #   bool `rescan` - If true, the wallet will rescan the blockchain looking for transactions that involve this private key
  # return_type: `account_name`
  import_private_key: (wif_key, account_name, create_new_account, rescan) ->
    @rpc.request('wallet_import_private_key', [wif_key, account_name, create_new_account, rescan]).then (response) ->
      response.result

  # Imports a Bitcoin Core or BitShares PTS wallet
  # parameters: 
  #   filename `wallet_filename` - the Bitcoin/PTS wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `void`
  import_bitcoin: (wallet_filename, passphrase, account_name) ->
    @rpc.request('wallet_import_bitcoin', [wallet_filename, passphrase, account_name]).then (response) ->
      response.result

  # Imports an Armory wallet
  # parameters: 
  #   filename `wallet_filename` - the Armory wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `void`
  import_armory: (wallet_filename, passphrase, account_name) ->
    @rpc.request('wallet_import_armory', [wallet_filename, passphrase, account_name]).then (response) ->
      response.result

  # Imports an Electrum wallet
  # parameters: 
  #   filename `wallet_filename` - the Electrum wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `void`
  import_electrum: (wallet_filename, passphrase, account_name) ->
    @rpc.request('wallet_import_electrum', [wallet_filename, passphrase, account_name]).then (response) ->
      response.result

  # Imports a Multibit wallet
  # parameters: 
  #   filename `wallet_filename` - the Multibit wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `void`
  import_multibit: (wallet_filename, passphrase, account_name) ->
    @rpc.request('wallet_import_multibit', [wallet_filename, passphrase, account_name]).then (response) ->
      response.result

  # Create the key from keyhotee config and import it to the wallet, creating a new account using this key
  # parameters: 
  #   name `firstname` - first name in keyhotee profile config, for salting the seed of private key
  #   name `middlename` - middle name in keyhotee profile config, for salting the seed of private key
  #   name `lastname` - last name in keyhotee profile config, for salting the seed of private key
  #   brainkey `brainkey` - brainkey in keyhotee profile config, for salting the seed of private key
  #   keyhoteeid `keyhoteeid` - using keyhotee id as account name
  # return_type: `void`
  import_keyhotee: (firstname, middlename, lastname, brainkey, keyhoteeid) ->
    @rpc.request('wallet_import_keyhotee', [firstname, middlename, lastname, brainkey, keyhoteeid]).then (response) ->
      response.result

  # Closes the curent wallet if one is open
  # parameters: 
  # return_type: `void`
  close:  ->
    @rpc.request('wallet_close').then (response) ->
      response.result

  # Exports the current wallet to a JSON file
  # parameters: 
  #   filename `json_filename` - the full path and filename of JSON file to generate, example: /path/to/exported_wallet.json
  # return_type: `void`
  backup_create: (json_filename) ->
    @rpc.request('wallet_backup_create', [json_filename]).then (response) ->
      response.result

  # Creates a new wallet from an exported JSON file
  # parameters: 
  #   filename `json_filename` - the full path and filename of JSON wallet to import, example: /path/to/exported_wallet.json
  #   wallet_name `wallet_name` - name of the wallet to create
  #   passphrase `imported_wallet_passphrase` - passphrase of the imported wallet
  # return_type: `void`
  backup_restore: (json_filename, wallet_name, imported_wallet_passphrase) ->
    @rpc.request('wallet_backup_restore', [json_filename, wallet_name, imported_wallet_passphrase]).then (response) ->
      response.result

  # Enables or disables automatic wallet backups
  # parameters: 
  #   bool `enabled` - true to enable and false to disable
  # return_type: `bool`
  set_automatic_backups: (enabled) ->
    @rpc.request('wallet_set_automatic_backups', [enabled]).then (response) ->
      response.result

  # Lists transaction history for the specified account
  # parameters: 
  #   string `account_name` - the name of the account for which the transaction history will be returned, "" for all accounts, example: alice
  #   string `asset_symbol` - only include transactions involving the specified asset, or "" to include all
  #   int32_t `limit` - limit the number of returned transactions; negative for most recent and positive for least recent. 0 does not limit
  #   uint32_t `start_block_num` - the earliest block number to list transactions from; 0 to include all transactions starting from genesis
  #   uint32_t `end_block_num` - the latest block to list transaction from; -1 to include all transactions ending at the head block
  # return_type: `pretty_transactions`
  account_transaction_history: (account_name, asset_symbol, limit, start_block_num, end_block_num) ->
    @rpc.request('wallet_account_transaction_history', [account_name, asset_symbol, limit, start_block_num, end_block_num]).then (response) ->
      response.result

  # Removes the specified transaction record from your transaction history. USE WITH CAUTION! Rescan cannot reconstruct all transaction details
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction record
  # return_type: `void`
  transaction_remove: (transaction_id) ->
    @rpc.request('wallet_transaction_remove', [transaction_id]).then (response) ->
      response.result

  # Return any errors for your currently pending transactions
  # parameters: 
  #   string `filename` - filename to save pending transaction errors to
  # return_type: `map<transaction_id_type, fc::exception>`
  get_pending_transaction_errors: (filename) ->
    @rpc.request('wallet_get_pending_transaction_errors', [filename]).then (response) ->
      response.result

  # Lock the private keys in wallet, disables spending commands until unlocked
  # parameters: 
  # return_type: `void`
  lock:  ->
    @rpc.request('wallet_lock').then (response) ->
      response.result

  # Unlock the private keys in the wallet to enable spending operations
  # parameters: 
  #   uint32_t `timeout` - the number of seconds to keep the wallet unlocked
  #   passphrase `passphrase` - the passphrase for encrypting the wallet
  # return_type: `void`
  unlock: (timeout, passphrase) ->
    @rpc.request('wallet_unlock', [timeout, passphrase]).then (response) ->
      response.result

  # Change the password of the current wallet
  # parameters: 
  #   passphrase `passphrase` - the passphrase for encrypting the wallet
  # return_type: `void`
  change_passphrase: (passphrase) ->
    @rpc.request('wallet_change_passphrase', [passphrase]).then (response) ->
      response.result

  # Return a list of wallets in the current data directory
  # parameters: 
  # return_type: `wallet_name_array`
  list:  ->
    @rpc.request('wallet_list').then (response) ->
      response.result

  # Add new account for receiving payments
  # parameters: 
  #   account_name `account_name` - the name you will use to refer to this receive account
  #   json_variant `private_data` - Extra data to store with this account record
  # return_type: `public_key`
  account_create: (account_name, private_data) ->
    @rpc.request('wallet_account_create', [account_name, private_data]).then (response) ->
      response.result

  # Updates the favorited status of the specified account
  # parameters: 
  #   account_name `account_name` - the name of the account to set favorited status on
  #   bool `is_favorite` - true if account should be marked as a favorite; false otherwise
  # return_type: `void`
  account_set_favorite: (account_name, is_favorite) ->
    @rpc.request('wallet_account_set_favorite', [account_name, is_favorite]).then (response) ->
      response.result

  # Updates your approval of the specified account
  # parameters: 
  #   account_name `account_name` - the name of the account to set approval for
  #   int8_t `approval` - 1, 0, or -1 respectively for approve, neutral, or disapprove
  # return_type: `int8_t`
  account_set_approval: (account_name, approval) ->
    @rpc.request('wallet_account_set_approval', [account_name, approval]).then (response) ->
      response.result

  # Add new account for sending payments
  # parameters: 
  #   account_name `account_name` - the name you will use to refer to this sending account
  #   public_key `account_key` - the key associated with this sending account
  # return_type: `void`
  add_contact_account: (account_name, account_key) ->
    @rpc.request('wallet_add_contact_account', [account_name, account_key]).then (response) ->
      response.result

  # Sends given amount to the given account, with the from field set to the payer.  This transfer will occur in a single transaction and will be cheaper, but may reduce your privacy.
  # parameters: 
  #   real_amount `amount_to_transfer` - the amount of shares to transfer
  #   asset_symbol `asset_symbol` - the asset to transfer
  #   sending_account_name `from_account_name` - the source account to draw the shares from
  #   receive_account_name `to_account_name` - the account to transfer the shares to
  #   string `memo_message` - a memo to store with the transaction
  #   vote_selection_method `vote_method` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  # return_type: `transaction_record`
  transfer: (amount_to_transfer, asset_symbol, from_account_name, to_account_name, memo_message, vote_method) ->
    @rpc.request('wallet_transfer', [amount_to_transfer, asset_symbol, from_account_name, to_account_name, memo_message, vote_method]).then (response) ->
      response.result

  # Sends given amount to the given name, with the from field set to a different account than the payer.  This transfer will occur in a single transaction and will be cheaper, but may reduce your privacy.
  # parameters: 
  #   real_amount `amount_to_transfer` - the amount of shares to transfer
  #   asset_symbol `asset_symbol` - the asset to transfer
  #   sending_account_name `paying_account_name` - the source account to draw the shares from
  #   sending_account_name `from_account_name` - the account to show the recipient as being the sender (requires account's private key to be in wallet). Leave empty to send anonymously.
  #   receive_account_name `to_account_name` - the account to transfer the shares to
  #   string `memo_message` - a memo to store with the transaction
  #   vote_selection_method `vote_method` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  # return_type: `transaction_record`
  transfer_from: (amount_to_transfer, asset_symbol, paying_account_name, from_account_name, to_account_name, memo_message, vote_method) ->
    @rpc.request('wallet_transfer_from', [amount_to_transfer, asset_symbol, paying_account_name, from_account_name, to_account_name, memo_message, vote_method]).then (response) ->
      response.result

  # Scans the blockchain history for operations relevant to this wallet.
  # parameters: 
  #   uint32_t `first_block_number` - the first block to scan
  #   uint32_t `num_blocks` - the number of blocks to scan
  # return_type: `void`
  rescan_blockchain: (first_block_number, num_blocks) ->
    @rpc.request('wallet_rescan_blockchain', [first_block_number, num_blocks]).then (response) ->
      response.result

  # Scans the specified transaction
  # parameters: 
  #   uint32_t `block_num` - the block containing the transaction
  #   string `transaction_id` - the id (or id prefix) of the transaction
  # return_type: `void`
  transaction_scan: (block_num, transaction_id) ->
    @rpc.request('wallet_transaction_scan', [block_num, transaction_id]).then (response) ->
      response.result

  # Rebroadcasts the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  # return_type: `void`
  transaction_rebroadcast: (transaction_id) ->
    @rpc.request('wallet_transaction_rebroadcast', [transaction_id]).then (response) ->
      response.result

  # Updates the data published about a given account
  # parameters: 
  #   account_name `account_name` - the account that will be updated
  #   account_name `pay_from_account` - the account from which fees will be paid
  #   json_variant `public_data` - public data about the account
  #   uint32_t `delegate_pay_rate` - A value between 0 and 100 for delegates, 255 for non delegates
  # return_type: `signed_transaction`
  account_register: (account_name, pay_from_account, public_data, delegate_pay_rate) ->
    @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, delegate_pay_rate]).then (response) ->
      response.result

  # Updates the local private data for an account
  # parameters: 
  #   account_name `account_name` - the account that will be updated
  #   json_variant `private_data` - private data about the account
  # return_type: `void`
  account_update_private_data: (account_name, private_data) ->
    @rpc.request('wallet_account_update_private_data', [account_name, private_data]).then (response) ->
      response.result

  # Updates the data published about a given account
  # parameters: 
  #   account_name `account_name` - the account that will be updated
  #   account_name `pay_from_account` - the account from which fees will be paid
  #   json_variant `public_data` - public data about the account
  #   uint8_t `delegate_pay_rate` - delegate pay rate: 0 to 100 if updating or upgrading to a delegate, and 255 for a normal account
  # return_type: `signed_transaction`
  account_update_registration: (account_name, pay_from_account, public_data, delegate_pay_rate) ->
    @rpc.request('wallet_account_update_registration', [account_name, pay_from_account, public_data, delegate_pay_rate]).then (response) ->
      response.result

  # Updates the specified account's active key and broadcasts the transaction.
  # parameters: 
  #   account_name `account_to_update` - The name of the account to update the active key of.
  #   account_name `pay_from_account` - The account from which fees will be paid.
  #   string `new_active_key` - WIF private key to update active key to. If empty, a new key will be generated.
  # return_type: `signed_transaction`
  account_update_active_key: (account_to_update, pay_from_account, new_active_key) ->
    @rpc.request('wallet_account_update_active_key', [account_to_update, pay_from_account, new_active_key]).then (response) ->
      response.result

  # Lists all accounts associated with this wallet
  # parameters: 
  # return_type: `wallet_account_record_array`
  list_accounts:  ->
    @rpc.request('wallet_list_accounts').then (response) ->
      response.result

  # Lists all accounts which have been marked as favorites.
  # parameters: 
  # return_type: `wallet_account_record_array`
  list_favorite_accounts:  ->
    @rpc.request('wallet_list_favorite_accounts').then (response) ->
      response.result

  # Lists all unregistered accounts belonging to this wallet
  # parameters: 
  # return_type: `wallet_account_record_array`
  list_unregistered_accounts:  ->
    @rpc.request('wallet_list_unregistered_accounts').then (response) ->
      response.result

  # Lists all accounts for which we have a private key in this wallet
  # parameters: 
  # return_type: `wallet_account_record_array`
  list_my_accounts:  ->
    @rpc.request('wallet_list_my_accounts').then (response) ->
      response.result

  # Get the account record for a given name
  # parameters: 
  #   account_name `account_name` - the name of the account to retrieve
  # return_type: `wallet_account_record`
  get_account: (account_name) ->
    @rpc.request('wallet_get_account', [account_name]).then (response) ->
      response.result

  # Remove a contact account from your wallet
  # parameters: 
  #   account_name `account_name` - the name of the contact
  # return_type: `void`
  remove_contact_account: (account_name) ->
    @rpc.request('wallet_remove_contact_account', [account_name]).then (response) ->
      response.result

  # Rename an account in wallet
  # parameters: 
  #   account_name `current_account_name` - the current name of the account
  #   new_account_name `new_account_name` - the new name for the account
  # return_type: `void`
  account_rename: (current_account_name, new_account_name) ->
    @rpc.request('wallet_account_rename', [current_account_name, new_account_name]).then (response) ->
      response.result

  # Creates a new user issued asset
  # parameters: 
  #   asset_symbol `symbol` - the ticker symbol for the new asset
  #   string `asset_name` - the name of the asset
  #   string `issuer_name` - the name of the issuer of the asset
  #   string `description` - a description of the asset
  #   json_variant `data` - arbitrary data attached to the asset
  #   real_amount `maximum_share_supply` - the maximum number of shares of the asset
  #   int64_t `precision` - defines where the decimal should be displayed, must be a power of 10
  #   bool `is_market_issued` - creation of a new BitAsset that is created by shorting
  # return_type: `signed_transaction`
  asset_create: (symbol, asset_name, issuer_name, description, data, maximum_share_supply, precision, is_market_issued) ->
    @rpc.request('wallet_asset_create', [symbol, asset_name, issuer_name, description, data, maximum_share_supply, precision, is_market_issued]).then (response) ->
      response.result

  # Issues new shares of a given asset type
  # parameters: 
  #   real_amount `amount` - the amount of shares to issue
  #   asset_symbol `symbol` - the ticker symbol for asset
  #   account_name `to_account_name` - the name of the account to receive the shares
  #   string `memo_message` - the memo to send to the receiver
  # return_type: `signed_transaction`
  asset_issue: (amount, symbol, to_account_name, memo_message) ->
    @rpc.request('wallet_asset_issue', [amount, symbol, to_account_name, memo_message]).then (response) ->
      response.result

  # Lists the total asset balances for the specified account
  # parameters: 
  #   account_name `account_name` - the account to get a balance for, or leave empty for all accounts
  # return_type: `account_balance_summary_type`
  account_balance: (account_name) ->
    @rpc.request('wallet_account_balance', [account_name]).then (response) ->
      response.result

  # Lists all public keys in this account
  # parameters: 
  #   account_name `account_name` - the account for which public keys should be listed
  # return_type: `public_key_summary_array`
  account_list_public_keys: (account_name) ->
    @rpc.request('wallet_account_list_public_keys', [account_name]).then (response) ->
      response.result

  # Used to transfer some of the delegate's pay from their balance
  # parameters: 
  #   account_name `delegate_name` - the delegate whose pay is being cashed out
  #   account_name `to_account_name` - the account that should receive the funds
  #   real_amount `amount_to_withdraw` - the amount to withdraw
  #   string `memo` - memo to add to transaction
  # return_type: `signed_transaction`
  delegate_withdraw_pay: (delegate_name, to_account_name, amount_to_withdraw, memo) ->
    @rpc.request('wallet_delegate_withdraw_pay', [delegate_name, to_account_name, amount_to_withdraw, memo]).then (response) ->
      response.result

  # Set the transaction fee to add to new transactions
  # parameters: 
  #   real_amount `fee` - the wallet transaction fee to set
  # return_type: `asset`
  set_transaction_fee: (fee) ->
    @rpc.request('wallet_set_transaction_fee', [fee]).then (response) ->
      response.result

  # Used to place a request to buy a quantity of assets at a price specified in another asset
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the bid
  #   real_amount `quantity` - the quantity of items you would like to buy
  #   asset_symbol `quantity_symbol` - the type of items you would like to buy
  #   real_amount `base_price` - the price you would like to pay
  #   asset_symbol `base_symbol` - the type of asset you would like to pay with
  # return_type: `signed_transaction`
  market_submit_bid: (from_account_name, quantity, quantity_symbol, base_price, base_symbol) ->
    @rpc.request('wallet_market_submit_bid', [from_account_name, quantity, quantity_symbol, base_price, base_symbol]).then (response) ->
      response.result

  # Used to place a request to sell a quantity of assets at a price specified in another asset
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   real_amount `sell_quantity` - the quantity of items you would like to sell
  #   asset_symbol `sell_quantity_symbol` - the type of items you would like to sell
  #   real_amount `ask_price` - the price per unit sold.
  #   asset_symbol `ask_price_symbol` - the type of asset you would like to be paid
  # return_type: `signed_transaction`
  market_submit_ask: (from_account_name, sell_quantity, sell_quantity_symbol, ask_price, ask_price_symbol) ->
    @rpc.request('wallet_market_submit_ask', [from_account_name, sell_quantity, sell_quantity_symbol, ask_price, ask_price_symbol]).then (response) ->
      response.result

  # Used to place a request to short sell a quantity of assets at a price specified
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   real_amount `short_quantity` - the quantity of items you would like to short sell (borrow into existance and sell)
  #   real_amount `short_price` - the price (ie: 2.0 USD) per XTS that you would like to short at
  #   asset_symbol `short_symbol` - the type of asset you would like to short, ie: USD
  # return_type: `signed_transaction`
  market_submit_short: (from_account_name, short_quantity, short_price, short_symbol) ->
    @rpc.request('wallet_market_submit_short', [from_account_name, short_quantity, short_price, short_symbol]).then (response) ->
      response.result

  # Used to place a request to cover an existing short position
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   real_amount `quantity` - the quantity of items you would like to cover
  #   asset_symbol `quantity_symbol` - the type of asset you are covering (ie: USD)
  #   address `order_id` - the order ID you would like to cover
  # return_type: `signed_transaction`
  market_cover: (from_account_name, quantity, quantity_symbol, order_id) ->
    @rpc.request('wallet_market_cover', [from_account_name, quantity, quantity_symbol, order_id]).then (response) ->
      response.result

  # List an order list of a specific market
  # parameters: 
  #   asset_symbol `base_symbol` - the base symbol of the market
  #   asset_symbol `quote_symbol` - the quote symbol of the market
  #   int64_t `limit` - the maximum number of items to return
  #   account_name `account_name` - the account for which to get the orders, or 'ALL' to get them all
  # return_type: `market_order_array`
  market_order_list: (base_symbol, quote_symbol, limit, account_name) ->
    @rpc.request('wallet_market_order_list', [base_symbol, quote_symbol, limit, account_name]).then (response) ->
      response.result

  # Cancel an order
  # parameters: 
  #   address `order_id` - the address of the order to cancel
  # return_type: `signed_transaction`
  market_cancel_order: (order_id) ->
    @rpc.request('wallet_market_cancel_order', [order_id]).then (response) ->
      response.result

  # Reveals the private key corresponding to an account, public key, or address
  # parameters: 
  #   string `input` - an account name, public key, or address (quoted hash of public key)
  # return_type: `string`
  dump_private_key: (input) ->
    @rpc.request('wallet_dump_private_key', [input]).then (response) ->
      response.result

  # Returns the allocation of votes by this account
  # parameters: 
  #   account_name `account_name` - the account to report votes on, or empty for all accounts
  # return_type: `account_vote_summary`
  account_vote_summary: (account_name) ->
    @rpc.request('wallet_account_vote_summary', [account_name]).then (response) ->
      response.result

  # Set a property in the GUI settings DB
  # parameters: 
  #   string `name` - the name of the setting to set
  #   variant `value` - the value to set the setting to
  # return_type: `void`
  set_setting: (name, value) ->
    @rpc.request('wallet_set_setting', [name, value]).then (response) ->
      response.result

  # Get the value of the given setting
  # parameters: 
  #   string `name` - The name of the setting to fetch
  # return_type: `optional_variant`
  get_setting: (name) ->
    @rpc.request('wallet_get_setting', [name]).then (response) ->
      response.result

  # Enable or disable block production for a particular delegate account
  # parameters: 
  #   string `delegate_name` - The delegate to enable/disable block production for; ALL for all delegate accounts
  #   bool `enabled` - true to enable block production, false otherwise
  # return_type: `void`
  delegate_set_block_production: (delegate_name, enabled) ->
    @rpc.request('wallet_delegate_set_block_production', [delegate_name, enabled]).then (response) ->
      response.result

  # Enable or disable wallet transaction scanning
  # parameters: 
  #   bool `enabled` - true to enable transaction scanning, false otherwise
  # return_type: `bool`
  set_transaction_scanning: (enabled) ->
    @rpc.request('wallet_set_transaction_scanning', [enabled]).then (response) ->
      response.result

  # Signs the provided message digest with the account key
  # parameters: 
  #   string `signing_account` - Name of the account to sign the message with
  #   sha256 `hash` - SHA256 digest of the message to sign
  # return_type: `compact_signature`
  sign_hash: (signing_account, hash) ->
    @rpc.request('wallet_sign_hash', [signing_account, hash]).then (response) ->
      response.result

  # Initiates the login procedure by providing a BitShares Login URL
  # parameters: 
  #   string `server_account` - Name of the account of the server. The user will be shown this name as the site he is logging into.
  # return_type: `string`
  login_start: (server_account) ->
    @rpc.request('wallet_login_start', [server_account]).then (response) ->
      response.result

  # Completes the login procedure by finding the user's public account key and shared secret
  # parameters: 
  #   public_key `server_key` - The one-time public key from wallet_login_start.
  #   public_key `client_key` - The client's one-time public key.
  #   compact_signature `client_signature` - The client's signature of the shared secret.
  # return_type: `variant`
  login_finish: (server_key, client_key, client_signature) ->
    @rpc.request('wallet_login_finish', [server_key, client_key, client_signature]).then (response) ->
      response.result

  # Publishes the current wallet delegate slate to the public data associated with the account
  # parameters: 
  #   account_name `publishing_account_name` - The account to publish the slate ID under
  #   account_name `paying_account_name` - The account to pay transaction fees; leave empty to pay with publishing account.
  # return_type: `signed_transaction`
  publish_slate: (publishing_account_name, paying_account_name) ->
    @rpc.request('wallet_publish_slate', [publishing_account_name, paying_account_name]).then (response) ->
      response.result

  # Attempts to recover accounts created after last backup was taken and returns number of successful recoveries. Use if you have restored from backup and are missing accounts.
  # parameters: 
  #   int32_t `accounts_to_recover` - The number of accounts to attept to recover
  #   int32_t `maximum_number_of_attempts` - The maximum number of keys to generate trying to recover accounts
  # return_type: `int32_t`
  recover_accounts: (accounts_to_recover, maximum_number_of_attempts) ->
    @rpc.request('wallet_recover_accounts', [accounts_to_recover, maximum_number_of_attempts]).then (response) ->
      response.result

  # publishes a price feed for BitAssets, only active delegates may do this
  # parameters: 
  #   account_name `delegate_account` - the delegate to publish the price under
  #   real_amount `price` - the number of this asset per XTS
  #   asset_symbol `asset_symbol` - the type of asset being priced
  # return_type: `signed_transaction`
  publish_price_feed: (delegate_account, price, asset_symbol) ->
    @rpc.request('wallet_publish_price_feed', [delegate_account, price, asset_symbol]).then (response) ->
      response.result



angular.module("app").service("WalletAPI", ["$q", "$log", "RpcService", "$interval", WalletAPI])
