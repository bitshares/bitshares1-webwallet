angular.module("app").filter "startsWithSort", ()->
    (input_array, text) ->
        if !input_array
            return []

        startsWith = []
        notStartsWith = []
        for el in input_array
            if el.indexOf(text) == 0
                startsWith.push el
            else
                notStartsWith.push el

        return startsWith.concat notStartsWith
