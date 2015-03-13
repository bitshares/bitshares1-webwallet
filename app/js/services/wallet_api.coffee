# Warning: this is a generated file, any changes made here will be overwritten by the build process

class WalletAPI

  constructor: (@q, @log, @rpc, @interval) ->
    #@log.info "---- WalletAPI Constructor ----"


  # Extra information about the wallet.
  # parameters: 
  # return_type: `json_object`
  get_info: (error_handler = null) ->
    @rpc.request('wallet_get_info', error_handler).then (response) ->
      response.result

  # Opens the wallet of the given name
  # parameters: 
  #   wallet_name `wallet_name` - the name of the wallet to open
  # return_type: `void`
  open: (wallet_name, error_handler = null) ->
    @rpc.request('wallet_open', [wallet_name], error_handler).then (response) ->
      response.result

  # Creates a wallet with the given name
  # parameters: 
  #   wallet_name `wallet_name` - name of the wallet to create
  #   new_passphrase `new_passphrase` - a passphrase for encrypting the wallet; must be surrounded with quotes if contains spaces
  #   brainkey `brain_key` - a strong passphrase that will be used to generate all private keys, defaults to a large random number
  #   passphrase `new_passphrase_verify` - optionally provide passphrase again to double-check
  # return_type: `void`
  create: (wallet_name, new_passphrase, brain_key, new_passphrase_verify, error_handler = null) ->
    @rpc.request('wallet_create', [wallet_name, new_passphrase, brain_key, new_passphrase_verify], error_handler).then (response) ->
      response.result

  # Loads the private key into the specified account. Returns which account it was actually imported to.
  # parameters: 
  #   wif_private_key `wif_key` - A private key in bitcoin Wallet Import Format (WIF)
  #   account_name `account_name` - the name of the account the key should be imported into, if null then the key must belong to an active account
  #   bool `create_new_account` - If true, the wallet will attempt to create a new account for the name provided rather than import the key into an existing account
  #   bool `rescan` - If true, the wallet will rescan the blockchain looking for transactions that involve this private key
  # return_type: `account_name`
  import_private_key: (wif_key, account_name, create_new_account, rescan, error_handler = null) ->
    @rpc.request('wallet_import_private_key', [wif_key, account_name, create_new_account, rescan], error_handler).then (response) ->
      response.result

  # Imports a Bitcoin Core or BitShares PTS wallet
  # parameters: 
  #   filename `wallet_filename` - the Bitcoin/PTS wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `uint32_t`
  import_bitcoin: (wallet_filename, passphrase, account_name, error_handler = null) ->
    @rpc.request('wallet_import_bitcoin', [wallet_filename, passphrase, account_name], error_handler).then (response) ->
      response.result

  # Imports an Electrum wallet
  # parameters: 
  #   filename `wallet_filename` - the Electrum wallet file path
  #   passphrase `passphrase` - the imported wallet's password
  #   account_name `account_name` - the account to receive the contents of the wallet
  # return_type: `uint32_t`
  import_electrum: (wallet_filename, passphrase, account_name, error_handler = null) ->
    @rpc.request('wallet_import_electrum', [wallet_filename, passphrase, account_name], error_handler).then (response) ->
      response.result

  # Create the key from keyhotee config and import it to the wallet, creating a new account using this key
  # parameters: 
  #   name `firstname` - first name in keyhotee profile config, for salting the seed of private key
  #   name `middlename` - middle name in keyhotee profile config, for salting the seed of private key
  #   name `lastname` - last name in keyhotee profile config, for salting the seed of private key
  #   brainkey `brainkey` - brainkey in keyhotee profile config, for salting the seed of private key
  #   keyhoteeid `keyhoteeid` - using keyhotee id as account name
  # return_type: `void`
  import_keyhotee: (firstname, middlename, lastname, brainkey, keyhoteeid, error_handler = null) ->
    @rpc.request('wallet_import_keyhotee', [firstname, middlename, lastname, brainkey, keyhoteeid], error_handler).then (response) ->
      response.result

  # Imports anything that looks like a private key from the given JSON file.
  # parameters: 
  #   filename `json_filename` - the full path and filename of JSON wallet to import, example: /path/to/exported_wallet.json
  #   passphrase `imported_wallet_passphrase` - passphrase for encrypted keys
  #   account_name `account` - Account into which to import keys.
  # return_type: `uint32_t`
  import_keys_from_json: (json_filename, imported_wallet_passphrase, account, error_handler = null) ->
    @rpc.request('wallet_import_keys_from_json', [json_filename, imported_wallet_passphrase, account], error_handler).then (response) ->
      response.result

  # Closes the curent wallet if one is open
  # parameters: 
  # return_type: `void`
  close: (error_handler = null) ->
    @rpc.request('wallet_close', error_handler).then (response) ->
      response.result

  # Exports the current wallet to a JSON file
  # parameters: 
  #   filename `json_filename` - the full path and filename of JSON file to generate, example: /path/to/exported_wallet.json
  # return_type: `void`
  backup_create: (json_filename, error_handler = null) ->
    @rpc.request('wallet_backup_create', [json_filename], error_handler).then (response) ->
      response.result

  # Creates a new wallet from an exported JSON file
  # parameters: 
  #   filename `json_filename` - the full path and filename of JSON wallet to import, example: /path/to/exported_wallet.json
  #   wallet_name `wallet_name` - name of the wallet to create
  #   passphrase `imported_wallet_passphrase` - passphrase of the imported wallet
  # return_type: `void`
  backup_restore: (json_filename, wallet_name, imported_wallet_passphrase, error_handler = null) ->
    @rpc.request('wallet_backup_restore', [json_filename, wallet_name, imported_wallet_passphrase], error_handler).then (response) ->
      response.result

  # Enables or disables automatic wallet backups
  # parameters: 
  #   bool `enabled` - true to enable and false to disable
  # return_type: `bool`
  set_automatic_backups: (enabled, error_handler = null) ->
    @rpc.request('wallet_set_automatic_backups', [enabled], error_handler).then (response) ->
      response.result

  # Set transaction expiration time
  # parameters: 
  #   uint32_t `seconds` - seconds before new transactions expire
  # return_type: `uint32_t`
  set_transaction_expiration_time: (seconds, error_handler = null) ->
    @rpc.request('wallet_set_transaction_expiration_time', [seconds], error_handler).then (response) ->
      response.result

  # Lists transaction history for the specified account
  # parameters: 
  #   string `account_name` - the name of the account for which the transaction history will be returned, "" for all accounts, example: alice
  #   string `asset_symbol` - only include transactions involving the specified asset, or "" to include all
  #   int32_t `limit` - limit the number of returned transactions; negative for most recent and positive for least recent. 0 does not limit
  #   uint32_t `start_block_num` - the earliest block number to list transactions from; 0 to include all transactions starting from genesis
  #   uint32_t `end_block_num` - the latest block to list transaction from; -1 to include all transactions ending at the head block
  # return_type: `pretty_transactions`
  account_transaction_history: (account_name, asset_symbol, limit, start_block_num, end_block_num, error_handler = null) ->
    @rpc.request('wallet_account_transaction_history', [account_name, asset_symbol, limit, start_block_num, end_block_num], error_handler).then (response) ->
      response.result

  # Lists wallet's balance at the given time
  # parameters: 
  #   timestamp `time` - the date and time for which the balance will be computed, example: 2015-01-31T23:59:59
  #   string `account_name` - the name of the account for which the historic balance will be returned, "" for all accounts, example: alice
  # return_type: `account_balance_summary_type`
  account_historic_balance: (time, account_name, error_handler = null) ->
    @rpc.request('wallet_account_historic_balance', [time, account_name], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `account_name` - the name of the account for which the transaction history will be returned, "" for all accounts, example: alice
  # return_type: `experimental_transactions`
  transaction_history_experimental: (account_name, error_handler = null) ->
    @rpc.request('wallet_transaction_history_experimental', [account_name], error_handler).then (response) ->
      response.result

  # Removes the specified transaction record from your transaction history. USE WITH CAUTION! Rescan cannot reconstruct all transaction details
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction record
  # return_type: `void`
  remove_transaction: (transaction_id, error_handler = null) ->
    @rpc.request('wallet_remove_transaction', [transaction_id], error_handler).then (response) ->
      response.result

  # Return any errors for your currently pending transactions
  # parameters: 
  #   string `filename` - filename to save pending transaction errors to
  # return_type: `map<transaction_id_type, fc::exception>`
  get_pending_transaction_errors: (filename, error_handler = null) ->
    @rpc.request('wallet_get_pending_transaction_errors', [filename], error_handler).then (response) ->
      response.result

  # Lock the private keys in wallet, disables spending commands until unlocked
  # parameters: 
  # return_type: `void`
  lock: (error_handler = null) ->
    @rpc.request('wallet_lock', error_handler).then (response) ->
      response.result

  # Unlock the private keys in the wallet to enable spending operations
  # parameters: 
  #   uint32_t `timeout` - the number of seconds to keep the wallet unlocked
  #   passphrase `passphrase` - the passphrase for encrypting the wallet
  # return_type: `void`
  unlock: (timeout, passphrase, error_handler = null) ->
    @rpc.request('wallet_unlock', [timeout, passphrase], error_handler).then (response) ->
      response.result

  # Change the password of the current wallet
  # parameters: 
  #   new_passphrase `new_passphrase` - the new passphrase for encrypting the wallet; must be surrounded with quotes if contains spaces
  #   passphrase `new_passphrase_verify` - optionally provide passphrase again to double-check
  # return_type: `void`
  change_passphrase: (new_passphrase, new_passphrase_verify, error_handler = null) ->
    @rpc.request('wallet_change_passphrase', [new_passphrase, new_passphrase_verify], error_handler).then (response) ->
      response.result

  # Return a list of wallets in the current data directory
  # parameters: 
  # return_type: `wallet_name_array`
  list: (error_handler = null) ->
    @rpc.request('wallet_list', error_handler).then (response) ->
      response.result

  # Add new account for receiving payments
  # parameters: 
  #   account_name `account_name` - the name you will use to refer to this receive account
  # return_type: `public_key`
  account_create: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_create', [account_name], error_handler).then (response) ->
      response.result

  # List all contact entries
  # parameters: 
  # return_type: `wallet_contact_record_array`
  list_contacts: (error_handler = null) ->
    @rpc.request('wallet_list_contacts', error_handler).then (response) ->
      response.result

  # Get the specified contact entry
  # parameters: 
  #   string `contact` - the value or label (prefixed by "label:") of the contact to query
  # return_type: `owallet_contact_record`
  get_contact: (contact, error_handler = null) ->
    @rpc.request('wallet_get_contact', [contact], error_handler).then (response) ->
      response.result

  # Add a new contact entry or update the label for an existing entry
  # parameters: 
  #   string `contact` - a registered account name, a public key, an address, or a btc address that represents this contact
  #   string `label` - an optional custom label to use when referring to this contact
  # return_type: `wallet_contact_record`
  add_contact: (contact, label, error_handler = null) ->
    @rpc.request('wallet_add_contact', [contact, label], error_handler).then (response) ->
      response.result

  # Remove a contact entry
  # parameters: 
  #   string `contact` - the value or label (prefixed by "label:") of the contact to remove
  # return_type: `owallet_contact_record`
  remove_contact: (contact, error_handler = null) ->
    @rpc.request('wallet_remove_contact', [contact], error_handler).then (response) ->
      response.result

  # List all approval entries
  # parameters: 
  # return_type: `wallet_approval_record_array`
  list_approvals: (error_handler = null) ->
    @rpc.request('wallet_list_approvals', error_handler).then (response) ->
      response.result

  # Get the specified approval entry
  # parameters: 
  #   string `approval` - the name of the approval to query
  # return_type: `owallet_approval_record`
  get_approval: (approval, error_handler = null) ->
    @rpc.request('wallet_get_approval', [approval], error_handler).then (response) ->
      response.result

  # Approve or disapprove the specified account or proposal
  # parameters: 
  #   string `name` - a registered account or proposal name to set approval for
  #   int8_t `approval` - 1, 0, or -1 respectively for approve, neutral, or disapprove
  # return_type: `wallet_approval_record`
  approve: (name, approval, error_handler = null) ->
    @rpc.request('wallet_approve', [name, approval], error_handler).then (response) ->
      response.result

  # Authorizes a public key to control funds of a particular asset class.  Requires authority of asset issuer
  # parameters: 
  #   account_name `paying_account` - the account that will pay the transaction fee
  #   asset_symbol `symbol` - the asset granting authorization
  #   string `address` - the address being granted permission, or the public key, or the account name
  # return_type: `transaction_record`
  asset_authorize_key: (paying_account, symbol, address, error_handler = null) ->
    @rpc.request('wallet_asset_authorize_key', [paying_account, symbol, address], error_handler).then (response) ->
      response.result

  # Burns given amount to the given account.  This will allow you to post message and +/- sentiment on someones account as a form of reputation.
  # parameters: 
  #   string `amount_to_burn` - the amount of shares to burn
  #   asset_symbol `asset_symbol` - the asset to burn
  #   sending_account_name `from_account_name` - the source account to draw the shares from
  #   string `for_or_against` - the value 'for' or 'against'
  #   receive_account_name `to_account_name` - the account to which the burn should be credited (for or against) and on which the public message will appear
  #   string `public_message` - a public message to post
  #   bool `anonymous` - true if anonymous, else signed by from_account_name
  # return_type: `transaction_record`
  burn: (amount_to_burn, asset_symbol, from_account_name, for_or_against, to_account_name, public_message, anonymous, error_handler = null) ->
    @rpc.request('wallet_burn', [amount_to_burn, asset_symbol, from_account_name, for_or_against, to_account_name, public_message, anonymous], error_handler).then (response) ->
      response.result

  # Creates an address which can be used for a simple (non-TITAN) transfer.
  # parameters: 
  #   string `account_name` - The account name that will own this address
  #   string `label` - 
  #   int32_t `legacy_network_byte` - If not -1, use this as the network byte for a BTC-style address.
  # return_type: `string`
  address_create: (account_name, label, legacy_network_byte, error_handler = null) ->
    @rpc.request('wallet_address_create', [account_name, label, legacy_network_byte], error_handler).then (response) ->
      response.result

  # Sends given amount to the given account, with the from field set to the payer.  This transfer will occur in a single transaction and will be cheaper, but may reduce your privacy.
  # parameters: 
  #   string `amount_to_transfer` - the amount of shares to transfer
  #   asset_symbol `asset_symbol` - the asset to transfer
  #   sending_account_name `from_account_name` - the source account to draw the shares from
  #   string `recipient` - the account name, public key, address, or btc address which will receive the funds
  #   string `memo_message` - a memo to store with the transaction
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  # return_type: `transaction_record`
  transfer: (amount_to_transfer, asset_symbol, from_account_name, recipient, memo_message, strategy, error_handler = null) ->
    @rpc.request('wallet_transfer', [amount_to_transfer, asset_symbol, from_account_name, recipient, memo_message, strategy], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `symbol` - which asset
  #   uint32_t `m` - Required number of signatures
  #   address_list `addresses` - List of possible addresses for signatures
  # return_type: `address`
  multisig_get_balance_id: (symbol, m, addresses, error_handler = null) ->
    @rpc.request('wallet_multisig_get_balance_id', [symbol, m, addresses], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `amount` - how much to transfer
  #   string `symbol` - which asset
  #   string `from_name` - TITAN name to withdraw from
  #   uint32_t `m` - Required number of signatures
  #   address_list `addresses` - List of possible addresses for signatures
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  # return_type: `transaction_record`
  multisig_deposit: (amount, symbol, from_name, m, addresses, strategy, error_handler = null) ->
    @rpc.request('wallet_multisig_deposit', [amount, symbol, from_name, m, addresses, strategy], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `amount` - how much to transfer
  #   string `symbol` - which asset
  #   address `from_address` - the balance address to withdraw from
  #   string `to` - address or account to receive funds
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  #   bool `sign_and_broadcast` - 
  #   string `builder_path` - If specified, will write builder here instead of to DATA_DIR/transactions/latest.trx
  # return_type: `transaction_builder`
  withdraw_from_address: (amount, symbol, from_address, to, strategy, sign_and_broadcast, builder_path, error_handler = null) ->
    @rpc.request('wallet_withdraw_from_address', [amount, symbol, from_address, to, strategy, sign_and_broadcast, builder_path], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `amount` - how much to transfer
  #   string `symbol` - which asset
  #   legacy_address `from_address` - the balance address to withdraw from
  #   string `to` - address or account to receive funds
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  #   bool `sign_and_broadcast` - 
  #   string `builder_path` - If specified, will write builder here instead of to DATA_DIR/transactions/latest.trx
  # return_type: `transaction_builder`
  withdraw_from_legacy_address: (amount, symbol, from_address, to, strategy, sign_and_broadcast, builder_path, error_handler = null) ->
    @rpc.request('wallet_withdraw_from_legacy_address', [amount, symbol, from_address, to, strategy, sign_and_broadcast, builder_path], error_handler).then (response) ->
      response.result

  # 
  # parameters: 
  #   string `amount` - how much to transfer
  #   string `symbol` - which asset
  #   address `from` - multisig balance ID to withdraw from
  #   address `to_address` - address to receive funds
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  #   string `builder_path` - If specified, will write builder here instead of to DATA_DIR/transactions/latest.trx
  # return_type: `transaction_builder`
  multisig_withdraw_start: (amount, symbol, from, to_address, strategy, builder_path, error_handler = null) ->
    @rpc.request('wallet_multisig_withdraw_start', [amount, symbol, from, to_address, strategy, builder_path], error_handler).then (response) ->
      response.result

  # Review a transaction and add a signature.
  # parameters: 
  #   transaction_builder `builder` - A transaction builder object created by a wallet. If null, tries to use builder in file.
  #   bool `broadcast` - Try to broadcast this transaction?
  # return_type: `transaction_builder`
  builder_add_signature: (builder, broadcast, error_handler = null) ->
    @rpc.request('wallet_builder_add_signature', [builder, broadcast], error_handler).then (response) ->
      response.result

  # Review a transaction in a builder file and add a signature.
  # parameters: 
  #   string `builder_path` - If specified, will write builder here instead of to DATA_DIR/transactions/latest.trx
  #   bool `broadcast` - Try to broadcast this transaction?
  # return_type: `transaction_builder`
  builder_file_add_signature: (builder_path, broadcast, error_handler = null) ->
    @rpc.request('wallet_builder_file_add_signature', [builder_path, broadcast], error_handler).then (response) ->
      response.result

  # Releases escrow balance to third parties
  # parameters: 
  #   account_name `pay_fee_with_account_name` - when releasing escrow a transaction fee must be paid by funds not in escrow, this account will pay the fee
  #   address `escrow_balance_id` - The balance id of the escrow to be released.
  #   account_name `released_by_account` - the account that is to perform the release.
  #   real_amount `amount_to_sender` - Amount to release back to the sender.
  #   real_amount `amount_to_receiver` - Amount to release to receiver.
  # return_type: `transaction_record`
  release_escrow: (pay_fee_with_account_name, escrow_balance_id, released_by_account, amount_to_sender, amount_to_receiver, error_handler = null) ->
    @rpc.request('wallet_release_escrow', [pay_fee_with_account_name, escrow_balance_id, released_by_account, amount_to_sender, amount_to_receiver], error_handler).then (response) ->
      response.result

  # Sends given amount to the given name, with the from field set to a different account than the payer.  This transfer will occur in a single transaction and will be cheaper, but may reduce your privacy.
  # parameters: 
  #   string `amount_to_transfer` - the amount of shares to transfer
  #   asset_symbol `asset_symbol` - the asset to transfer
  #   sending_account_name `paying_account_name` - the source account to draw the shares from
  #   sending_account_name `from_account_name` - the account to show the recipient as being the sender (requires account's private key to be in wallet).
  #   receive_account_name `to_account_name` - the account to transfer the shares to
  #   account_name `escrow_account_name` - the account of the escrow agent which has the power to decide how to divide the funds among from/to accounts.
  #   digest `agreement` - the hash of an agreement between the sender/receiver in the event a dispute arises can be given to escrow agent
  #   string `memo_message` - a memo to store with the transaction
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  # return_type: `transaction_record`
  transfer_from_with_escrow: (amount_to_transfer, asset_symbol, paying_account_name, from_account_name, to_account_name, escrow_account_name, agreement, memo_message, strategy, error_handler = null) ->
    @rpc.request('wallet_transfer_from_with_escrow', [amount_to_transfer, asset_symbol, paying_account_name, from_account_name, to_account_name, escrow_account_name, agreement, memo_message, strategy], error_handler).then (response) ->
      response.result

  # Scans the blockchain history for operations relevant to this wallet.
  # parameters: 
  #   uint32_t `start_block_num` - the first block to scan
  #   uint32_t `limit` - the maximum number of blocks to scan
  #   bool `scan_in_background` - if true then scan asynchronously in the background, otherwise block until scan is done
  # return_type: `void`
  rescan_blockchain: (start_block_num, limit, scan_in_background, error_handler = null) ->
    @rpc.request('wallet_rescan_blockchain', [start_block_num, limit, scan_in_background], error_handler).then (response) ->
      response.result

  # Cancel any current scan task
  # parameters: 
  # return_type: `void`
  cancel_scan: (error_handler = null) ->
    @rpc.request('wallet_cancel_scan', error_handler).then (response) ->
      response.result

  # Queries your wallet for the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  # return_type: `transaction_record`
  get_transaction: (transaction_id, error_handler = null) ->
    @rpc.request('wallet_get_transaction', [transaction_id], error_handler).then (response) ->
      response.result

  # Scans the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  #   bool `overwrite_existing` - true to overwrite existing wallet transaction record and false otherwise
  # return_type: `transaction_record`
  scan_transaction: (transaction_id, overwrite_existing, error_handler = null) ->
    @rpc.request('wallet_scan_transaction', [transaction_id, overwrite_existing], error_handler).then (response) ->
      response.result

  # Scans the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  #   bool `overwrite_existing` - true to overwrite existing wallet transaction record and false otherwise
  # return_type: `void`
  scan_transaction_experimental: (transaction_id, overwrite_existing, error_handler = null) ->
    @rpc.request('wallet_scan_transaction_experimental', [transaction_id, overwrite_existing], error_handler).then (response) ->
      response.result

  # Adds a custom note to the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  #   string `note` - note to add
  # return_type: `void`
  add_transaction_note_experimental: (transaction_id, note, error_handler = null) ->
    @rpc.request('wallet_add_transaction_note_experimental', [transaction_id, note], error_handler).then (response) ->
      response.result

  # Rebroadcasts the specified transaction
  # parameters: 
  #   string `transaction_id` - the id (or id prefix) of the transaction
  # return_type: `void`
  rebroadcast_transaction: (transaction_id, error_handler = null) ->
    @rpc.request('wallet_rebroadcast_transaction', [transaction_id], error_handler).then (response) ->
      response.result

  # Updates the data published about a given account
  # parameters: 
  #   account_name `account_name` - the account that will be updated
  #   account_name `pay_from_account` - the account from which fees will be paid
  #   json_variant `public_data` - public data about the account
  #   uint8_t `delegate_pay_rate` - -1 for non-delegates; otherwise the percent of delegate pay to accept per produced block
  #   string `account_type` - titan_account | public_account - public accounts do not receive memos and all payments are made to the active key
  # return_type: `transaction_record`
  account_register: (account_name, pay_from_account, public_data, delegate_pay_rate, account_type, error_handler = null) ->
    @rpc.request('wallet_account_register', [account_name, pay_from_account, public_data, delegate_pay_rate, account_type], error_handler).then (response) ->
      response.result

  # Overwrite the local custom data for an account, contact, or approval
  # parameters: 
  #   wallet_record_type `type` - specify one of {account_record_type, contact_record_type, approval_record_type}
  #   string `item` - name of the account, contact, or approval
  #   variant_object `custom_data` - the custom data object to store
  # return_type: `void`
  set_custom_data: (type, item, custom_data, error_handler = null) ->
    @rpc.request('wallet_set_custom_data', [type, item, custom_data], error_handler).then (response) ->
      response.result

  # Updates the data published about a given account
  # parameters: 
  #   account_name `account_name` - the account that will be updated
  #   account_name `pay_from_account` - the account from which fees will be paid
  #   json_variant `public_data` - public data about the account
  #   uint8_t `delegate_pay_rate` - -1 for non-delegates; otherwise the percent of delegate pay to accept per produced block
  # return_type: `transaction_record`
  account_update_registration: (account_name, pay_from_account, public_data, delegate_pay_rate, error_handler = null) ->
    @rpc.request('wallet_account_update_registration', [account_name, pay_from_account, public_data, delegate_pay_rate], error_handler).then (response) ->
      response.result

  # Updates the specified account's active key and broadcasts the transaction.
  # parameters: 
  #   account_name `account_to_update` - The name of the account to update the active key of.
  #   account_name `pay_from_account` - The account from which fees will be paid.
  #   string `new_active_key` - WIF private key to update active key to. If empty, a new key will be generated.
  # return_type: `transaction_record`
  account_update_active_key: (account_to_update, pay_from_account, new_active_key, error_handler = null) ->
    @rpc.request('wallet_account_update_active_key', [account_to_update, pay_from_account, new_active_key], error_handler).then (response) ->
      response.result

  # Lists all account entries
  # parameters: 
  # return_type: `wallet_account_record_array`
  list_accounts: (error_handler = null) ->
    @rpc.request('wallet_list_accounts', error_handler).then (response) ->
      response.result

  # Get the specified account entry
  # parameters: 
  #   string `account` - the name, key, address, or id of the account to query
  # return_type: `owallet_account_record`
  get_account: (account, error_handler = null) ->
    @rpc.request('wallet_get_account', [account], error_handler).then (response) ->
      response.result

  # Rename an account in wallet
  # parameters: 
  #   account_name `current_account_name` - the current name of the account
  #   new_account_name `new_account_name` - the new name for the account
  # return_type: `void`
  account_rename: (current_account_name, new_account_name, error_handler = null) ->
    @rpc.request('wallet_account_rename', [current_account_name, new_account_name], error_handler).then (response) ->
      response.result

  # Creates a new user issued asset
  # parameters: 
  #   asset_symbol `symbol` - the ticker symbol for the new asset
  #   string `asset_name` - the name of the asset
  #   string `issuer_name` - the name of the issuer of the asset
  #   string `description` - a description of the asset
  #   real_amount `maximum_share_supply` - the maximum number of shares of the asset
  #   uint64_t `precision` - defines where the decimal should be displayed, must be a power of 10
  #   json_variant `public_data` - arbitrary data attached to the asset
  #   bool `is_market_issued` - creation of a new BitAsset that is created by shorting
  # return_type: `transaction_record`
  asset_create: (symbol, asset_name, issuer_name, description, maximum_share_supply, precision, public_data, is_market_issued, error_handler = null) ->
    @rpc.request('wallet_asset_create', [symbol, asset_name, issuer_name, description, maximum_share_supply, precision, public_data, is_market_issued], error_handler).then (response) ->
      response.result

  # Updates an existing user-issued asset; only the public_data can be updated if any shares of the asset exist
  # parameters: 
  #   asset_symbol `symbol` - the ticker symbol for the asset to update
  #   optional_string `name` - the new name to give the asset; or null to keep the current name
  #   optional_string `description` - the new description to give the asset; or null to keep the current description
  #   optional_variant `public_data` - the new public_data to give the asset; or null to keep the current public_data
  #   optional_double `maximum_share_supply` - the new maximum_share_supply to give the asset; or null to keep the current maximum_share_supply
  #   optional_uint64_t `precision` - the new precision to give the asset; or null to keep the current precision
  #   share_type `issuer_transaction_fee` - an additional fee (denominated in issued asset) charged by the issuer on every transaction that uses this asset type
  #   real_amount `issuer_market_fee` - an additional fee (denominated in percent) charged by the issuer on every order that is matched
  #   asset_permission_array `flags` - a set of flags set by the issuer (if they have permission to set them)
  #   asset_permission_array `issuer_permissions` - a set of permissions an issuer retains
  #   account_name `issuer_account_name` - used to transfer the asset to a new user
  #   uint32_t `required_sigs` - number of signatures from the authority required to control this asset record
  #   address_list `authority` - owner keys that control this asset record
  # return_type: `transaction_record`
  asset_update: (symbol, name, description, public_data, maximum_share_supply, precision, issuer_transaction_fee, issuer_market_fee, flags, issuer_permissions, issuer_account_name, required_sigs, authority, error_handler = null) ->
    @rpc.request('wallet_asset_update', [symbol, name, description, public_data, maximum_share_supply, precision, issuer_transaction_fee, issuer_market_fee, flags, issuer_permissions, issuer_account_name, required_sigs, authority], error_handler).then (response) ->
      response.result

  # Issues new shares of a given asset type
  # parameters: 
  #   real_amount `amount` - the amount of shares to issue
  #   asset_symbol `symbol` - the ticker symbol for asset
  #   account_name `to_account_name` - the name of the account to receive the shares
  #   string `memo_message` - the memo to send to the receiver
  # return_type: `transaction_record`
  asset_issue: (amount, symbol, to_account_name, memo_message, error_handler = null) ->
    @rpc.request('wallet_asset_issue', [amount, symbol, to_account_name, memo_message], error_handler).then (response) ->
      response.result

  # Issues new UIA shares to specific addresses.
  # parameters: 
  #   asset_symbol `symbol` - the ticker symbol for asset
  #   snapshot_map `addresses` - A map of addresses-to-amounts to transfer the new shares to
  # return_type: `transaction_record`
  asset_issue_to_addresses: (symbol, addresses, error_handler = null) ->
    @rpc.request('wallet_asset_issue_to_addresses', [symbol, addresses], error_handler).then (response) ->
      response.result

  # Lists the total asset balances for all open escrows
  # parameters: 
  #   account_name `account_name` - the account to get a escrow summary for, or leave empty for all accounts
  # return_type: `escrow_summary_array`
  escrow_summary: (account_name, error_handler = null) ->
    @rpc.request('wallet_escrow_summary', [account_name], error_handler).then (response) ->
      response.result

  # Lists the total asset balances for the specified account
  # parameters: 
  #   account_name `account_name` - the account to get a balance for, or leave empty for all accounts
  # return_type: `account_balance_summary_type`
  account_balance: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_balance', [account_name], error_handler).then (response) ->
      response.result

  # Lists the balance IDs for the specified account
  # parameters: 
  #   account_name `account_name` - the account to get a balance IDs for, or leave empty for all accounts
  # return_type: `account_balance_id_summary_type`
  account_balance_ids: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_balance_ids', [account_name], error_handler).then (response) ->
      response.result

  # Lists the total asset balances across all withdraw condition types for the specified account
  # parameters: 
  #   account_name `account_name` - the account to get a balance for, or leave empty for all accounts
  # return_type: `account_extended_balance_type`
  account_balance_extended: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_balance_extended', [account_name], error_handler).then (response) ->
      response.result

  # List the vesting balances available to the specified account
  # parameters: 
  #   account_name `account_name` - the account name to list vesting balances for, or leave empty for all accounts
  # return_type: `account_vesting_balance_summary_type`
  account_vesting_balances: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_vesting_balances', [account_name], error_handler).then (response) ->
      response.result

  # Lists the total accumulated yield for asset balances
  # parameters: 
  #   account_name `account_name` - the account to get yield for, or leave empty for all accounts
  # return_type: `account_balance_summary_type`
  account_yield: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_yield', [account_name], error_handler).then (response) ->
      response.result

  # Lists all public keys in this account
  # parameters: 
  #   account_name `account_name` - the account for which public keys should be listed
  # return_type: `public_key_summary_array`
  account_list_public_keys: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_list_public_keys', [account_name], error_handler).then (response) ->
      response.result

  # Used to transfer some of the delegate's pay from their balance
  # parameters: 
  #   account_name `delegate_name` - the delegate whose pay is being cashed out
  #   account_name `to_account_name` - the account that should receive the funds
  #   real_amount `amount_to_withdraw` - the amount to withdraw
  # return_type: `transaction_record`
  delegate_withdraw_pay: (delegate_name, to_account_name, amount_to_withdraw, error_handler = null) ->
    @rpc.request('wallet_delegate_withdraw_pay', [delegate_name, to_account_name, amount_to_withdraw], error_handler).then (response) ->
      response.result

  # Set the fee to add to new transactions
  # parameters: 
  #   real_amount `fee` - the wallet transaction fee to set
  # return_type: `asset`
  set_transaction_fee: (fee, error_handler = null) ->
    @rpc.request('wallet_set_transaction_fee', [fee], error_handler).then (response) ->
      response.result

  # Returns 
  # parameters: 
  #   asset_symbol `symbol` - the wallet transaction if paid in the given asset type
  # return_type: `asset`
  get_transaction_fee: (symbol, error_handler = null) ->
    @rpc.request('wallet_get_transaction_fee', [symbol], error_handler).then (response) ->
      response.result

  # Used to place a request to sell a quantity of assets at a price specified in another asset
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the order
  #   string `sell_quantity` - the quantity of items you would like to sell
  #   asset_symbol `sell_quantity_symbol` - the type of items you would like to sell
  #   string `price_limit` - the lowest price you are willing to accept
  #   asset_symbol `price_symbol` - the type of asset you would like to be paid
  #   string `relative_price` - a fraction of the price feed, e.g. 5% above is 1.05 or 105%
  #   bool `allow_stupid` - Allow user to sell at less than 5% below the current top of book
  # return_type: `transaction_record`
  market_sell: (from_account_name, sell_quantity, sell_quantity_symbol, price_limit, price_symbol, relative_price, allow_stupid, error_handler = null) ->
    @rpc.request('wallet_market_sell', [from_account_name, sell_quantity, sell_quantity_symbol, price_limit, price_symbol, relative_price, allow_stupid], error_handler).then (response) ->
      response.result

  # Used to place a request to buy a quantity of assets at a price specified in another asset
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the bid
  #   string `quantity` - the quantity of items you would like to buy
  #   asset_symbol `quantity_symbol` - the type of items you would like to buy
  #   string `base_price` - the price you would like to pay
  #   asset_symbol `base_symbol` - the type of asset you would like to pay with
  #   bool `allow_stupid_bid` - Allow user to place bid at more than 5% above the current sell price.
  # return_type: `transaction_record`
  market_submit_bid: (from_account_name, quantity, quantity_symbol, base_price, base_symbol, allow_stupid_bid, error_handler = null) ->
    @rpc.request('wallet_market_submit_bid', [from_account_name, quantity, quantity_symbol, base_price, base_symbol, allow_stupid_bid], error_handler).then (response) ->
      response.result

  # Used to place a request to sell a quantity of assets at a price specified in another asset
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   string `sell_quantity` - the quantity of items you would like to sell
  #   asset_symbol `sell_quantity_symbol` - the type of items you would like to sell
  #   string `ask_price` - the price per unit sold.
  #   asset_symbol `ask_price_symbol` - the type of asset you would like to be paid
  #   bool `allow_stupid_ask` - Allow user to place ask at more than 5% below the current buy price.
  # return_type: `transaction_record`
  market_submit_ask: (from_account_name, sell_quantity, sell_quantity_symbol, ask_price, ask_price_symbol, allow_stupid_ask, error_handler = null) ->
    @rpc.request('wallet_market_submit_ask', [from_account_name, sell_quantity, sell_quantity_symbol, ask_price, ask_price_symbol, allow_stupid_ask], error_handler).then (response) ->
      response.result

  # Used to place a request to short sell a quantity of assets at a price specified
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   string `short_collateral` - the amount of collateral you wish to fund this short with
  #   asset_symbol `collateral_symbol` - the type of asset collateralizing this short (i.e. XTS)
  #   string `interest_rate` - the APR you wish to pay interest at (0.0% to 1000.0%)
  #   asset_symbol `quote_symbol` - the asset to short sell (i.e. USD)
  #   string `short_price_limit` - maximim price (USD per XTS) that the short will execute at, if 0 then no limit will be applied
  # return_type: `transaction_record`
  market_submit_short: (from_account_name, short_collateral, collateral_symbol, interest_rate, quote_symbol, short_price_limit, error_handler = null) ->
    @rpc.request('wallet_market_submit_short', [from_account_name, short_collateral, collateral_symbol, interest_rate, quote_symbol, short_price_limit], error_handler).then (response) ->
      response.result

  # Used to place a request to cover an existing short position
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   string `quantity` - the quantity of asset you would like to cover
  #   asset_symbol `quantity_symbol` - the type of asset you are covering (ie: USD)
  #   order_id `cover_id` - the order ID you would like to cover
  # return_type: `transaction_record`
  market_cover: (from_account_name, quantity, quantity_symbol, cover_id, error_handler = null) ->
    @rpc.request('wallet_market_cover', [from_account_name, quantity, quantity_symbol, cover_id], error_handler).then (response) ->
      response.result

  # Cancel and/or create many market orders in a single transaction.
  # parameters: 
  #   order_ids `cancel_order_ids` - Order IDs of all market orders to cancel in this transaction.
  #   order_descriptions `new_orders` - Descriptions of all new orders to create in this transaction.
  #   bool `sign` - True if transaction should be signed and broadcast (if possible), false otherwse.
  # return_type: `transaction_record`
  market_batch_update: (cancel_order_ids, new_orders, sign, error_handler = null) ->
    @rpc.request('wallet_market_batch_update', [cancel_order_ids, new_orders, sign], error_handler).then (response) ->
      response.result

  # Add collateral to a short position
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the ask
  #   order_id `cover_id` - the ID of the order to recollateralize
  #   string `real_quantity_collateral_to_add` - the quantity of collateral of the base asset to add to the specified position
  # return_type: `transaction_record`
  market_add_collateral: (from_account_name, cover_id, real_quantity_collateral_to_add, error_handler = null) ->
    @rpc.request('wallet_market_add_collateral', [from_account_name, cover_id, real_quantity_collateral_to_add], error_handler).then (response) ->
      response.result

  # List an order list of a specific market
  # parameters: 
  #   asset_symbol `base_symbol` - the base symbol of the market
  #   asset_symbol `quote_symbol` - the quote symbol of the market
  #   uint32_t `limit` - the maximum number of items to return
  #   account_name `account_name` - the account for which to get the orders, or empty for all accounts
  # return_type: `market_order_map`
  market_order_list: (base_symbol, quote_symbol, limit, account_name, error_handler = null) ->
    @rpc.request('wallet_market_order_list', [base_symbol, quote_symbol, limit, account_name], error_handler).then (response) ->
      response.result

  # List an order list of a specific account
  # parameters: 
  #   account_name `account_name` - the account for which to get the orders, or empty for all accounts
  #   uint32_t `limit` - the maximum number of items to return
  # return_type: `market_order_map`
  account_order_list: (account_name, limit, error_handler = null) ->
    @rpc.request('wallet_account_order_list', [account_name, limit], error_handler).then (response) ->
      response.result

  # Cancel an order: deprecated - use wallet_market_cancel_orders
  # parameters: 
  #   order_id `order_id` - the ID of the order to cancel
  # return_type: `transaction_record`
  market_cancel_order: (order_id, error_handler = null) ->
    @rpc.request('wallet_market_cancel_order', [order_id], error_handler).then (response) ->
      response.result

  # Cancel more than one order at a time
  # parameters: 
  #   order_ids `order_ids` - the IDs of the orders to cancel
  # return_type: `transaction_record`
  market_cancel_orders: (order_ids, error_handler = null) ->
    @rpc.request('wallet_market_cancel_orders', [order_ids], error_handler).then (response) ->
      response.result

  # Reveals the private key corresponding to the specified public key or address; use with caution
  # parameters: 
  #   string `input` - public key or address to dump private key for
  # return_type: `optional_string`
  dump_private_key: (input, error_handler = null) ->
    @rpc.request('wallet_dump_private_key', [input], error_handler).then (response) ->
      response.result

  # Reveals the specified account private key; use with caution
  # parameters: 
  #   string `account_name` - account name to dump private key for
  #   account_key_type `key_type` - which account private key to dump; one of {owner_key, active_key, signing_key}
  # return_type: `optional_string`
  dump_account_private_key: (account_name, key_type, error_handler = null) ->
    @rpc.request('wallet_dump_account_private_key', [account_name, key_type], error_handler).then (response) ->
      response.result

  # Returns the allocation of votes by this account
  # parameters: 
  #   account_name `account_name` - the account to report votes on, or empty for all accounts
  # return_type: `account_vote_summary`
  account_vote_summary: (account_name, error_handler = null) ->
    @rpc.request('wallet_account_vote_summary', [account_name], error_handler).then (response) ->
      response.result

  # Set a property in the GUI settings DB
  # parameters: 
  #   string `name` - the name of the setting to set
  #   variant `value` - the value to set the setting to
  # return_type: `void`
  set_setting: (name, value, error_handler = null) ->
    @rpc.request('wallet_set_setting', [name, value], error_handler).then (response) ->
      response.result

  # Get the value of the given setting
  # parameters: 
  #   string `name` - The name of the setting to fetch
  # return_type: `optional_variant`
  get_setting: (name, error_handler = null) ->
    @rpc.request('wallet_get_setting', [name], error_handler).then (response) ->
      response.result

  # Enable or disable block production for a particular delegate account
  # parameters: 
  #   string `delegate_name` - The delegate to enable/disable block production for; ALL for all delegate accounts
  #   bool `enabled` - true to enable block production, false otherwise
  # return_type: `void`
  delegate_set_block_production: (delegate_name, enabled, error_handler = null) ->
    @rpc.request('wallet_delegate_set_block_production', [delegate_name, enabled], error_handler).then (response) ->
      response.result

  # Enable or disable wallet transaction scanning
  # parameters: 
  #   bool `enabled` - true to enable transaction scanning, false otherwise
  # return_type: `bool`
  set_transaction_scanning: (enabled, error_handler = null) ->
    @rpc.request('wallet_set_transaction_scanning', [enabled], error_handler).then (response) ->
      response.result

  # Signs the provided message digest with the account key
  # parameters: 
  #   string `signer` - A public key, address, or account name whose key to sign with
  #   sha256 `hash` - SHA256 digest of the message to sign
  # return_type: `compact_signature`
  sign_hash: (signer, hash, error_handler = null) ->
    @rpc.request('wallet_sign_hash', [signer, hash], error_handler).then (response) ->
      response.result

  # Initiates the login procedure by providing a BitShares Login URL
  # parameters: 
  #   string `server_account` - Name of the account of the server. The user will be shown this name as the site he is logging into.
  # return_type: `string`
  login_start: (server_account, error_handler = null) ->
    @rpc.request('wallet_login_start', [server_account], error_handler).then (response) ->
      response.result

  # Completes the login procedure by finding the user's public account key and shared secret
  # parameters: 
  #   public_key `server_key` - The one-time public key from wallet_login_start.
  #   public_key `client_key` - The client's one-time public key.
  #   compact_signature `client_signature` - The client's signature of the shared secret.
  # return_type: `variant`
  login_finish: (server_key, client_key, client_signature, error_handler = null) ->
    @rpc.request('wallet_login_finish', [server_key, client_key, client_signature], error_handler).then (response) ->
      response.result

  # Set this balance's voting address and slate
  # parameters: 
  #   address `balance_id` - the current name of the account
  #   string `voter_address` - The new voting address. If none is specified, tries to re-use existing address.
  #   vote_strategy `strategy` - enumeration [vote_none | vote_all | vote_random | vote_recommended] 
  #   bool `sign_and_broadcast` - 
  #   string `builder_path` - If specified, will write builder here instead of to DATA_DIR/transactions/latest.trx
  # return_type: `transaction_builder`
  balance_set_vote_info: (balance_id, voter_address, strategy, sign_and_broadcast, builder_path, error_handler = null) ->
    @rpc.request('wallet_balance_set_vote_info', [balance_id, voter_address, strategy, sign_and_broadcast, builder_path], error_handler).then (response) ->
      response.result

  # Publishes the current wallet delegate slate to the public data associated with the account
  # parameters: 
  #   account_name `publishing_account_name` - The account to publish the slate ID under
  #   account_name `paying_account_name` - The account to pay transaction fees or leave empty to pay with publishing account
  # return_type: `transaction_record`
  publish_slate: (publishing_account_name, paying_account_name, error_handler = null) ->
    @rpc.request('wallet_publish_slate', [publishing_account_name, paying_account_name], error_handler).then (response) ->
      response.result

  # Publish your current client version to the specified account's public data record
  # parameters: 
  #   account_name `publishing_account_name` - The account to publish the client version under
  #   account_name `paying_account_name` - The account to pay transaction fees with or leave empty to pay with publishing account
  # return_type: `transaction_record`
  publish_version: (publishing_account_name, paying_account_name, error_handler = null) ->
    @rpc.request('wallet_publish_version', [publishing_account_name, paying_account_name], error_handler).then (response) ->
      response.result

  # Collect specified account's genesis balances
  # parameters: 
  #   account_name `account_name` - account to collect genesis balances for
  # return_type: `transaction_record`
  collect_genesis_balances: (account_name, error_handler = null) ->
    @rpc.request('wallet_collect_genesis_balances', [account_name], error_handler).then (response) ->
      response.result

  # Collect specified account's vested balances
  # parameters: 
  #   account_name `account_name` - account to collect vested balances for
  # return_type: `transaction_record`
  collect_vested_balances: (account_name, error_handler = null) ->
    @rpc.request('wallet_collect_vested_balances', [account_name], error_handler).then (response) ->
      response.result

  # Update a delegate's block signing and feed publishing key
  # parameters: 
  #   account_name `authorizing_account_name` - The account that will authorize changing the block signing key
  #   account_name `delegate_name` - The delegate account which will have its block signing key changed
  #   public_key `signing_key` - The new key that will be used for block signing
  # return_type: `transaction_record`
  delegate_update_signing_key: (authorizing_account_name, delegate_name, signing_key, error_handler = null) ->
    @rpc.request('wallet_delegate_update_signing_key', [authorizing_account_name, delegate_name, signing_key], error_handler).then (response) ->
      response.result

  # Attempts to recover accounts created after last backup was taken and returns number of successful recoveries. Use if you have restored from backup and are missing accounts.
  # parameters: 
  #   int32_t `accounts_to_recover` - The number of accounts to attept to recover
  #   int32_t `maximum_number_of_attempts` - The maximum number of keys to generate trying to recover accounts
  # return_type: `int32_t`
  recover_accounts: (accounts_to_recover, maximum_number_of_attempts, error_handler = null) ->
    @rpc.request('wallet_recover_accounts', [accounts_to_recover, maximum_number_of_attempts], error_handler).then (response) ->
      response.result

  # Attempts to recover any missing recipient and memo information for the specified transaction
  # parameters: 
  #   string `transaction_id_prefix` - the id (or id prefix) of the transaction record
  #   string `recipient_account` - the account name of the recipient (if known)
  # return_type: `transaction_record`
  recover_titan_deposit_info: (transaction_id_prefix, recipient_account, error_handler = null) ->
    @rpc.request('wallet_recover_titan_deposit_info', [transaction_id_prefix, recipient_account], error_handler).then (response) ->
      response.result

  # Verify whether the specified transaction made a TITAN deposit to the current wallet; returns null if not
  # parameters: 
  #   string `transaction_id_prefix` - the id (or id prefix) of the transaction record
  # return_type: `optional_variant_object`
  verify_titan_deposit: (transaction_id_prefix, error_handler = null) ->
    @rpc.request('wallet_verify_titan_deposit', [transaction_id_prefix], error_handler).then (response) ->
      response.result

  # publishes a price feed for BitAssets, only active delegates may do this
  # parameters: 
  #   account_name `delegate_account` - the delegate to publish the price under
  #   real_amount `price` - the number of this asset per XTS
  #   asset_symbol `asset_symbol` - the type of asset being priced
  # return_type: `transaction_record`
  publish_price_feed: (delegate_account, price, asset_symbol, error_handler = null) ->
    @rpc.request('wallet_publish_price_feed', [delegate_account, price, asset_symbol], error_handler).then (response) ->
      response.result

  # publish price feeds for market-pegged assets; pays fee from delegate pay balance otherwise wallet account balance
  # parameters: 
  #   account_name `delegate_account` - the delegate to publish the price under
  #   price_map `symbol_to_price_map` - maps the BitAsset symbol to its price per share
  # return_type: `transaction_record`
  publish_feeds: (delegate_account, symbol_to_price_map, error_handler = null) ->
    @rpc.request('wallet_publish_feeds', [delegate_account, symbol_to_price_map], error_handler).then (response) ->
      response.result

  # publishes a set of feeds for BitAssets for all active delegates, most useful for testnets
  # parameters: 
  #   price_map `symbol_to_price_map` - maps the BitAsset symbol to its price per share
  # return_type: `vector<std::pair<string, wallet_transaction_record>>`
  publish_feeds_multi_experimental: (symbol_to_price_map, error_handler = null) ->
    @rpc.request('wallet_publish_feeds_multi_experimental', [symbol_to_price_map], error_handler).then (response) ->
      response.result

  # tries to repair any inconsistent wallet account, key, and transaction records
  # parameters: 
  #   account_name `collecting_account_name` - collect any orphan balances into this account
  # return_type: `void`
  repair_records: (collecting_account_name, error_handler = null) ->
    @rpc.request('wallet_repair_records', [collecting_account_name], error_handler).then (response) ->
      response.result

  # regenerates private keys as part of wallet recovery
  # parameters: 
  #   account_name `account_name` - the account the generated keys should be a part of
  #   uint32_t `max_key_number` - the last key number to regenerate
  # return_type: `int32_t`
  regenerate_keys: (account_name, max_key_number, error_handler = null) ->
    @rpc.request('wallet_regenerate_keys', [account_name, max_key_number], error_handler).then (response) ->
      response.result

  # Creates a new mail message and returns the unencrypted message.
  # parameters: 
  #   string `sender` - The name of the message's sender.
  #   string `subject` - The subject of the message.
  #   string `body` - The body of the message.
  #   message_id `reply_to` - The ID of the message this is in reply to.
  # return_type: `message`
  mail_create: (sender, subject, body, reply_to, error_handler = null) ->
    @rpc.request('wallet_mail_create', [sender, subject, body, reply_to], error_handler).then (response) ->
      response.result

  # Encrypts a mail message and returns the encrypted message.
  # parameters: 
  #   string `recipient` - The name of the message's recipient.
  #   message `plaintext` - The plaintext message, such as from wallet_mail_create.
  # return_type: `message`
  mail_encrypt: (recipient, plaintext, error_handler = null) ->
    @rpc.request('wallet_mail_encrypt', [recipient, plaintext], error_handler).then (response) ->
      response.result

  # Opens an encrypted mail message.
  # parameters: 
  #   address `recipient` - The address of the message's recipient.
  #   message `ciphertext` - The encrypted message.
  # return_type: `message`
  mail_open: (recipient, ciphertext, error_handler = null) ->
    @rpc.request('wallet_mail_open', [recipient, ciphertext], error_handler).then (response) ->
      response.result

  # Sets the list of mail servers an account checks for his mail.
  # parameters: 
  #   string `account_name` - The name of the account whose mail servers should be updated.
  #   string_array `server_list` - A list of names of blockchain accounts who run mail servers.
  #   string `paying_account` - The name of the account to pay the transaction fee, if different from account_name.
  # return_type: `void`
  set_preferred_mail_servers: (account_name, server_list, paying_account, error_handler = null) ->
    @rpc.request('wallet_set_preferred_mail_servers', [account_name, server_list, paying_account], error_handler).then (response) ->
      response.result

  # Retract (permanently disable) the specified account in case of master key compromise.
  # parameters: 
  #   account_name `account_to_retract` - The name of the account to retract.
  #   account_name `pay_from_account` - The account from which fees will be paid.
  # return_type: `transaction_record`
  account_retract: (account_to_retract, pay_from_account, error_handler = null) ->
    @rpc.request('wallet_account_retract', [account_to_retract, pay_from_account], error_handler).then (response) ->
      response.result

  # Generates a human friendly brain wallet key starting with a public salt as the last word
  # parameters: 
  # return_type: `string`
  generate_brain_seed: (error_handler = null) ->
    @rpc.request('wallet_generate_brain_seed', error_handler).then (response) ->
      response.result



angular.module("app").service("WalletAPI", ["$q", "$log", "RpcService", "$interval", WalletAPI])
