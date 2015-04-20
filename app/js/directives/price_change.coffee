angular.module("app.directives").directive "change", () ->
    restrict: "A"
    scope:
        change: "="
    link: (scope, elem, attrs) ->
        # flag = elem.attr "data-flash"
        scope.$watch "change", (nv, ov) ->
            if nv != ov 
                # apply class
                if nv > ov
                    elem.addClass "fa fa-arrow-up change-positive"
                    elem.removeClass "fa-arrow-down change-negative"
                else if nv < ov
                    elem.addClass "fa fa-arrow-down change-negative"
                    elem.removeClass "fa-arrow-up change-positive"
