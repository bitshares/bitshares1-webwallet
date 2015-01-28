angular.module("app.directives").directive "formVgroup", ->
    template: '''
    <div class="form-group" ng-class="{ 'has-error': has_error }">
        <label for="{{for}}"><span popover="{{labelPopover}}" popover-trigger="mouseenter">{{label}}</span></label>
        <div class="input-group input-vgroup">
            <span ng-transclude></span>
            <span ng-if="addon" class="input-group-addon">{{addon}}</span>
        </div>
        <div ng-show="error_message"><span class="help-block text-danger">{{error_message | translate}}</span></div>
        <div ng-show="help" ng-if="helpIf"><span class="help-block">{{help}}</span></div>
    </div>
    '''
    replace: true
    transclude: true
    require: "^form"
    scope:
        label: "@"
        addon: "@"
        help: "@"
        helpIf: "@"
        labelPopover: "@"

    link: (scope, element, attrs, formController) ->
        formName = formController.$name
        fieldName = element.find("[name]").attr("name")
        field = scope.$parent[formName][fieldName]
        return unless field
        field.clear_errors = ->
            scope.has_error = false
            scope.error_message = field.$error.message = ""
        id = "fgh_#{formName}_#{fieldName}"
        element.find(":input").attr("id", id)
        scope.for = id
        watchExpression = "#{formName}.#{fieldName}.$viewValue"
        scope.$parent.$watch watchExpression, (value) ->
            scope.has_error = !field.$valid and !field.$pristine
        errorExpression = "#{formName}.#{fieldName}.$error.message"
        scope.$parent.$watch errorExpression, (error_message) ->
            scope.error_message = error_message
            scope.has_error = scope.has_error or !!error_message

    controller: ($scope, $element) ->
        @clear_errors = ->
            $scope.error_message = null
            $scope.has_error = false
        return @
