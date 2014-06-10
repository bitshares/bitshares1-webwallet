class Client

    status:
        network_connection: 0

angular.module("app").service("Client", ["$q", "$log", "RpcService", "$interval", Client])
