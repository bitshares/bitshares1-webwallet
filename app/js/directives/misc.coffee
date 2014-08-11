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
    scope: false
    template: """
      <div ng-show="loading_indicator.show" class="loading-overlay" ng-class="{'with-progress': loading_indicator.progress}">
        <div class="loading-panel">
            <div class="spinner">
              <div class="bounce1"></div>
              <div class="bounce2"></div>
              <div class="bounce3"></div>
            </div>
          <div class="progress-indicator"><span>{{loading_indicator.progress}}</span></div>
        </div>
      </div>
    """

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

