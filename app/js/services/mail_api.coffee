# Warning: this is a generated file, any changes made here will be overwritten by the build process

class MailAPI

  constructor: (@q, @log, @rpc, @interval) ->
    #@log.info "---- API Constructor ----"


  # Store a message on the mail server.
  # parameters: 
  #   message `message` - The message to store.
  # return_type: `void`
  store_message: (message, error_handler = null) ->
    @rpc.request('mail_store_message', [message], error_handler).then (response) ->
      response.result

  # Get inventory of all messages belonging to a given address received after a given time.
  # parameters: 
  #   address `owner` - The owner whose message inventory should be retrieved.
  #   timestamp `start_time` - No messages received before this time will be returned.
  #   uint32_t `limit` - Maximum number of messages to retrieve.
  # return_type: `mail_inventory`
  fetch_inventory: (owner, start_time, limit, error_handler = null) ->
    @rpc.request('mail_fetch_inventory', [owner, start_time, limit], error_handler).then (response) ->
      response.result

  # Get a specific message from the server.
  # parameters: 
  #   message_id `inventory_id` - The ID of the message to retrieve.
  # return_type: `message`
  fetch_message: (inventory_id, error_handler = null) ->
    @rpc.request('mail_fetch_message', [inventory_id], error_handler).then (response) ->
      response.result

  # Get all messages in the mail client which are still in processing.
  # parameters: 
  # return_type: `message_status_list`
  get_processing_messages: (error_handler = null) ->
    @rpc.request('mail_get_processing_messages', error_handler).then (response) ->
      response.result

  # Get all messages in the mail client which are not in processing (sent and received).
  # parameters: 
  # return_type: `message_status_list`
  get_archive_messages: (error_handler = null) ->
    @rpc.request('mail_get_archive_messages', error_handler).then (response) ->
      response.result

  # Get headers of all messages in the inbox.
  # parameters: 
  # return_type: `message_header_list`
  inbox: (error_handler = null) ->
    @rpc.request('mail_inbox', error_handler).then (response) ->
      response.result

  # Retries sending the specified message.
  # parameters: 
  #   message_id `message_id` - ID of the failed message to retry sending.
  # return_type: `void`
  retry_send: (message_id, error_handler = null) ->
    @rpc.request('mail_retry_send', [message_id], error_handler).then (response) ->
      response.result

  # Cancels the outgoing message if it has not been transmitted yet.
  # parameters: 
  #   message_id `message_id` - ID of the message to cancel.
  # return_type: `void`
  cancel_message: (message_id, error_handler = null) ->
    @rpc.request('mail_cancel_message', [message_id], error_handler).then (response) ->
      response.result

  # Removes the message from the local database.
  # parameters: 
  #   message_id `message_id` - ID of the message to remove.
  # return_type: `void`
  remove_message: (message_id, error_handler = null) ->
    @rpc.request('mail_remove_message', [message_id], error_handler).then (response) ->
      response.result

  # Removes the message from the inbox.
  # parameters: 
  #   message_id `message_id` - ID of the message to archive.
  # return_type: `void`
  archive_message: (message_id, error_handler = null) ->
    @rpc.request('mail_archive_message', [message_id], error_handler).then (response) ->
      response.result

  # Check mail server for new mail and return number of new messages.
  # parameters: 
  #   bool `get_old_messages` - If true, all messages will be retrieved, not just new ones.
  # return_type: `int32_t`
  check_new_messages: (get_old_messages, error_handler = null) ->
    @rpc.request('mail_check_new_messages', [get_old_messages], error_handler).then (response) ->
      response.result

  # Get a specific message from the client.
  # parameters: 
  #   message_id `message_id` - The ID of the message to retrieve.
  # return_type: `email_record`
  get_message: (message_id, error_handler = null) ->
    @rpc.request('mail_get_message', [message_id], error_handler).then (response) ->
      response.result

  # Get a list of messages from a given sender.
  # parameters: 
  #   string `sender` - The name of the sender to search for.
  # return_type: `message_header_list`
  get_messages_from: (sender, error_handler = null) ->
    @rpc.request('mail_get_messages_from', [sender], error_handler).then (response) ->
      response.result

  # Get a list of messages to a given recipient.
  # parameters: 
  #   string `recipient` - The name of the recipient to search for.
  # return_type: `message_header_list`
  get_messages_to: (recipient, error_handler = null) ->
    @rpc.request('mail_get_messages_to', [recipient], error_handler).then (response) ->
      response.result

  # Get a list of messages between a given pair of accounts.
  # parameters: 
  #   string `account_one` - The name of an account in the conversation.
  #   string `account_two` - The name of an account in the conversation.
  # return_type: `message_header_list`
  get_messages_in_conversation: (account_one, account_two, error_handler = null) ->
    @rpc.request('mail_get_messages_in_conversation', [account_one, account_two], error_handler).then (response) ->
      response.result

  # Create a new email, encrypt it, and send it to the recipient's mail server.
  # parameters: 
  #   string `from` - The sender's name.
  #   string `to` - The recipient's name.
  #   string `subject` - The subject of the email.
  #   string `body` - The body of the email.
  #   message_id `reply_to` - The ID of the email this email is in reply to.
  # return_type: `message_id`
  send: (from, to, subject, body, reply_to, error_handler = null) ->
    @rpc.request('mail_send', [from, to, subject, body, reply_to], error_handler).then (response) ->
      response.result



angular.module("app").service("MailAPI", ["$q", "$log", "RpcService", "$interval", MailAPI])
