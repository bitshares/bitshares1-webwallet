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

angular.module("app.directives").directive "myNgEnter", ->
    (scope, element, attrs) ->
        element.bind "keydown keypress", (event) ->
            if event.which is 13
                scope.$apply ->
                    scope.$eval attrs.myNgEnter


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

angular.module("app.directives").directive "numonly", ->
    require: "ngModel"
    link: (scope, element, attr, ngModelCtrl) ->
        fromUser = (text) ->
            transformedInput = text.replace(/[^0-9]/g, "")
            if transformedInput isnt text
                element.css('background-color', 'pink');
                setTimeout (->
                    element.css('background-color', 'none');
                ), 500
                ngModelCtrl.$setViewValue transformedInput
                ngModelCtrl.$render()
            transformedInput
        ngModelCtrl.$parsers.push fromUser
        return

angular.module("app.directives").directive "decimalonly", ->
    require: "ngModel"
    link: (scope, element, attr, ngModelCtrl) ->
        fromUser = (text) ->
            transformedInput = text.replace(/[^0-9\.]/g, "")
            if transformedInput isnt text
                element.css('background-color', 'pink');
                setTimeout (->
                    element.css('background-color', 'none');
                ), 500
                ngModelCtrl.$setViewValue transformedInput
                ngModelCtrl.$render()
            transformedInput
        ngModelCtrl.$parsers.push fromUser
        return

angular.module("app.directives").directive "loadingIndicator", ->
    restrict: "A"
    replace: true
    scope:
        loading: '=loadingIndicator'
        progress: '=progressIndicator'
    template: """
      <div ng-show="loading" class="loading-overlay" ng-class="{'with-progress': progress > 0}">
        <div class="loading-panel">
          <div class="spinner-container"></div>
          <div class="transactions-progress"><span>Scanning transactions {{progress + "%"}}, please wait...</span></div>
        </div>
      </div>
    """
    link: (scope, element, attrs) ->
        spinner = new Spinner().spin()
        loadingContainer = element.find(".spinner-container")[0]
        loadingContainer.appendChild spinner.el

angular.module("app.directives").directive "watchChange", ->
    scope:
        onchange: '&watchChange'
    link: (scope, element, attrs) ->
        element.on 'input', ->
            scope.$apply ->
                scope.onchange()

# TODO: finish this directive and use it instead of gravatarImage directive
angular.module("app.directives").directive 'gravatar', ->
    restrict: 'E'
    replace: true
    template: "<img src=''/>"


angular.module("app.directives").directive "focus", ($timeout) ->
    link: (scope, element) ->
        $timeout -> element[0].focus()

