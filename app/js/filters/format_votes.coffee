angular.module("app").filter "formatVotes", () ->
    (number) ->  # TODO  use real precision, not available in web wallet yet
        return number / 100000
