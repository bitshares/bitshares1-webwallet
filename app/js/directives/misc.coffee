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


angular.module("app.directives").directive "inputName", ->
  template: '''
        <input id="name" ng-trim="false" placeholder="Account Name (Required)"
        autofocus ng-model="$parent.ngModel" ng-blur="removeTrailing()"
        my-ng-enter="removeTrailingDashes()"
        popover="Only lowercase alphanumeric characters, dots, and dashes.  Must start with a letter and cannot end with a dash.  Read more in help."
        popover-append-to-body="true" popover-trigger="focus" ng-keydown="kd()"
        ng-change="ku()" uncapitalize type="text" class="form-control" required ng-minlength="1">
        <div ng-show="$parent.f.error_message" class="text-danger">{{$parent.f.error_message}}</div>
    '''
  restrict: "E"
  scope:
    ngModel: "="
  controller: ($scope, $element) ->
    oldname=$scope.ngModel
    $scope.kd = ->
        oldname=$scope.ngModel
       
    $scope.ku = ->
        return unless $scope.ngModel
        if ($scope.ngModel.length>=63)
            $scope.ngModel=oldname
            return
        subnames=$scope.ngModel.split('.')
        i = 0
        last = subnames.length - 1
        while i < last
            valid = /^[a-z]+(?:[a-z0-9\-])*[a-z0-9]$/.test(subnames[i])
            if(!valid)
                $scope.ngModel=oldname
                break
            ++i
        if(subnames[last] != '')
            valid = /^[a-z]+(?:[a-z0-9\-])*$/.test(subnames[last])
            if(!valid)
                $scope.ngModel=oldname

    $scope.removeTrailing = ->
        $scope.ngModel = $scope.ngModel.replace(/\-+$/, "") if $scope.ngModel
        $scope.ngModel = $scope.ngModel.replace(/\.+$/, "") if $scope.ngModel
  ###
  link: (scope, elem, attrs, ngModel) ->
      elem.on("click", ->
          console.log(ngModel.$viewValue)
          ngModel.$setViewValue(ngModel.$viewValue+'1')
          scope.$apply()
      )
###

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
      console.log transformedInput
      if transformedInput isnt text
        element.css('background-color', 'pink');
        setTimeout (->
            element.css('background-color', 'none');
        ), 500
        ngModelCtrl.$setViewValue transformedInput
        ngModelCtrl.$render()
      transformedInput # or return Number(transformedInput)
    ngModelCtrl.$parsers.push fromUser
    return

angular.module("app.directives").directive "loadingIndicator", ->
  restrict: "A"
  replace: true
  scope:
    loading: '=loadingIndicator'
    progress: '=progressIndicator'
  template: """
  <div ng-show="loading" class='loading-overlay'>
    <div class='loading-panel'>
      <div class="spinner-container"></div>
      <div><span>Scanning transactions {{progress + "%"}}, please wait...</span></div>
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

