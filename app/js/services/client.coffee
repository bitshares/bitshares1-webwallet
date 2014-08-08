class Client

    constructor: (@common, @network, @blockchain, @q, @interval) ->
        #@interval @refresh_status, 3000
    
    status:
        network_num_connections: 0
        alert_level: "red"

    # This will repopulate "real-time" info
    ###
    refresh_status: ->
        @common.get_info().then (data) =>
            @status.network_num_connections = data.network_num_connections
            ####


angular.module("app").service("Client", ["CommonAPI", "NetworkAPI", "BlockchainAPI", "$q", "$interval", Client])
