angular.module("app").filter "startFrom", ()->
    (input, start) ->
        if (input)
            start = +start
            input.slice start
