angular.module("app").filter "delegateName", (Blockchain)->
    (delegate_id) ->
        Blockchain.id_delegates[delegate_id].name
