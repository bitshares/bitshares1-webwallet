angular.module("app.directives").directive "focusMe", ($timeout) ->
  scope:
    trigger: "@focusMe"
  link: (scope, element) ->
    scope.$watch "trigger", ->
      $timeout ->
        element[0].focus()

angular.module("app.directives").directive "pwCheck", ->
  require: "ngModel"
  link: (scope, elem, attrs, ctrl) ->
    firstPassword = "#" + attrs.pwCheck
    elem.add(firstPassword).on "keyup", ->
      scope.$apply ->
        v = elem.val() is $(firstPassword).val()
        ctrl.$setValidity "pwmatch", v