angular.module("app.directives").directive "flash", ($timeout) ->
    restrict: "A"
    scope:
        flash: "="
    link: (scope, elem, attrs) ->
        # flag = elem.attr "data-flash"
        scope.$watch "flash", (nv, ov) ->
            if nv != ov 
                # apply class
                elem.addClass "highlight"

                # auto remove after some delay
                $timeout ()  ->
                    elem.removeClass "highlight"
                , 1500
        , true
