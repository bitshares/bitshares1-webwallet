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
      if inputValue == undefined
        return inputValue
      uncapitalized = inputValue.toLowerCase()
      if uncapitalized isnt inputValue
        modelCtrl.$setViewValue uncapitalized
        modelCtrl.$render()
      uncapitalized

    modelCtrl.$parsers.push uncapitalize
    uncapitalize scope[attrs.ngModel] # uncapitalize initial value
    return

angular.module("app.directives").directive "loadingIndicator", ->
  console.log "####################"
  restrict: "A"
  replace: true
  scope:
    loading: '=loadingIndicator'
  template: """
  <div ng-show="loading" class='loading-overlay'>
    <div class="spinner-container"></div>
  </div>
  """
  link: (scope, element, attrs) ->
    spinner = new Spinner().spin()
    loadingContainer = element.find(".spinner-container")[0]
    loadingContainer.appendChild spinner.el
