# https://github.com/angular-ui/bootstrap/issues/908
angular.module("app").filter "concatTypeAheadWorkAround", ()->
    (input, viewValue) ->
        if viewValue.charAt(viewValue.length-1) is " "
            []
        else
            input
