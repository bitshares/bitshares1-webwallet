###*
the HTML5 autofocus property can be finicky when it comes to dynamically loaded
templates and such with AngularJS. Use this simple directive to
tame this beast once and for all.

Usage:
<input type="text" autofocus>
###
angular.module("utils.autofocus", []).directive "autofocus", [
  "$timeout"
  ($timeout) ->
    restrict: "A"
    link: ($scope, $element) ->
        $timeout ->
            $element[0].focus()
        ,
            275
]
