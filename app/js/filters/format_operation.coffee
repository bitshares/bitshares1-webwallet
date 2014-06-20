angular.module("app").filter "formatOperationType", (Blockchain)->
    (type) ->
        name = Blockchain.type_name_map[type]

        if name then name else "Unknow Operation"

angular.module("app").filter "filterByOperations", (Blockchain)->
    (operations, filter) ->
        if !filter or filter == "" then return true
        for op in operations
            name = Blockchain.type_name_map[op.type]
            if name and ( (name.toUpperCase().indexOf filter.toUpperCase() )!= -1 )
                return true
        return false
