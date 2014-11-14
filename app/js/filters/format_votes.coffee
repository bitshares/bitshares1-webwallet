angular.module("app").filter "formatVotes", ($filter) ->
    (number) ->  # TODO  use real precision, not available in web wallet yet
        return $filter('number')(number / 100000,0)+' BTS'
