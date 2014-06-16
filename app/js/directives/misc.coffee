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


angular.module("app.directives").directive "uncapitalize", ->
  require: "ngModel"
  link: (scope, element, attrs, modelCtrl) ->
    uncapitalize = (inputValue) ->
      uncapitalized = inputValue.toLowerCase()
      if uncapitalized isnt inputValue
        modelCtrl.$setViewValue uncapitalized
        modelCtrl.$render()
      uncapitalized

    modelCtrl.$parsers.push uncapitalize
    uncapitalize scope[attrs.ngModel] # uncapitalize initial value
    return
