# Warning: this is a generated file, any changes made here will be overwritten by the build process

class NetworkAPI

  constructor: (@q, @log, @rpc) ->
    #@log.info "---- Network API Constructor ----"


  # Attempts add or remove <node> from the peer list or try a connection to <node> once
  # parameters: 
  #   string `node` - The node (see network_get_peer_info for nodes), example: 192.168.1.5:5678
  #   string `command` - 'add' to add a node to the list, 'remove' to remove a node from the list, 'onetry' to try a connection to the node once, example: add
  # return_type: `void`
  add_node: (node, command, error_handler = null) ->
    @rpc.request('network_add_node', [node, command], error_handler).then (response) ->
      response.result

  # Returns the number of fully-established connections to other nodes
  # parameters: 
  # return_type: `uint32_t`
  get_connection_count: (error_handler = null) ->
    @rpc.request('network_get_connection_count', error_handler).then (response) ->
      response.result

  # Returns data about each connected node
  # parameters: 
  #   bool `not_firewalled` - true to output only peers not behind a firewall and false otherwise
  # return_type: `json_object_array`
  get_peer_info: (not_firewalled, error_handler = null) ->
    @rpc.request('network_get_peer_info', [not_firewalled], error_handler).then (response) ->
      response.result

  # Broadcast a previously-created signed transaction to the network
  # parameters: 
  #   signed_transaction `transaction_to_broadcast` - The transaction to broadcast to the network
  # return_type: `transaction_id`
  broadcast_transaction: (transaction_to_broadcast, error_handler = null) ->
    @rpc.request('network_broadcast_transaction', [transaction_to_broadcast], error_handler).then (response) ->
      response.result

  # Sets advanced node parameters, used for setting up automated tests
  # parameters: 
  #   json_object `params` - A JSON object containing the name/value pairs for the parameters to set
  # return_type: `void`
  set_advanced_node_parameters: (params, error_handler = null) ->
    @rpc.request('network_set_advanced_node_parameters', [params], error_handler).then (response) ->
      response.result

  # Sets advanced node parameters, used for setting up automated tests
  # parameters: 
  # return_type: `json_object`
  get_advanced_node_parameters: (error_handler = null) ->
    @rpc.request('network_get_advanced_node_parameters', error_handler).then (response) ->
      response.result

  # Returns the time the transaction was first seen by this client
  # parameters: 
  #   transaction_id `transaction_id` - the id of the transaction
  # return_type: `message_propagation_data`
  get_transaction_propagation_data: (transaction_id, error_handler = null) ->
    @rpc.request('network_get_transaction_propagation_data', [transaction_id], error_handler).then (response) ->
      response.result

  # Returns the time the block was first seen by this client
  # parameters: 
  #   block_id_type `block_hash` - the id of the block
  # return_type: `message_propagation_data`
  get_block_propagation_data: (block_hash, error_handler = null) ->
    @rpc.request('network_get_block_propagation_data', [block_hash], error_handler).then (response) ->
      response.result

  # Sets the list of peers this node is allowed to connect to
  # parameters: 
  #   node_id_list `allowed_peers` - the list of allowable peers
  # return_type: `void`
  set_allowed_peers: (allowed_peers, error_handler = null) ->
    @rpc.request('network_set_allowed_peers', [allowed_peers], error_handler).then (response) ->
      response.result

  # Returns assorted information about the network settings and connections
  # parameters: 
  # return_type: `json_object`
  get_info: (error_handler = null) ->
    @rpc.request('network_get_info', error_handler).then (response) ->
      response.result

  # Returns list of potential peers
  # parameters: 
  # return_type: `potential_peer_record_array`
  list_potential_peers: (error_handler = null) ->
    @rpc.request('network_list_potential_peers', error_handler).then (response) ->
      response.result

  # Get information on UPNP status including whether it's enabled and what the client believes its IP to be
  # parameters: 
  # return_type: `json_object`
  get_upnp_info: (error_handler = null) ->
    @rpc.request('network_get_upnp_info', error_handler).then (response) ->
      response.result

  # Get bandwidth usage stats
  # parameters: 
  # return_type: `json_object`
  get_usage_stats: (error_handler = null) ->
    @rpc.request('network_get_usage_stats', error_handler).then (response) ->
      response.result



angular.module("app").service("NetworkAPI", ["$q", "$log", "RpcService", NetworkAPI])
