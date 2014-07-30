angular.module("app.directives", []).directive "formHgroup", ->
    template: '''
    <div class="form-group" ng-class="{ 'has-error': has_error }">
        <label class="col-sm-3 control-label" for="{{for}}">{{label}}</label>
        <div class="col-sm-9">
            <div class="input-group">
                <span ng-transclude></span>
                <span class="input-group-addon">{{addon}}</span>
            </div>
            <span class="help-block text-danger" ng-show="error_message">{{error_message}}</span>
        </div>
    </div>
    '''
    replace: true
    transclude: true
    require: "^form"
    scope:
        label: "@"
        addon: "@"

    link: (scope, element, attrs, formController) ->
        formName = formController.$name
        fieldName = element.find(":input").attr("name")
        id = "fgh_#{formName}_#{fieldName}"
        element.find(":input").attr("id", id)
        scope.for = id

        watchExpression = "#{formName}.#{fieldName}.$viewValue"
        scope.$parent.$watch watchExpression, (value) ->
            field = scope.$parent[formName][fieldName]
            scope.has_error = !field.$valid and !field.$pristine

        errorExpression = "#{formName}.#{fieldName}.$error.message"
        scope.$parent.$watch errorExpression, (value) ->
            scope.error_message = value
            scope.has_error = scope.has_error or !!value

angular.module("app.directives").directive "formHgroupSubmitBtn", ->
    template: '''
    <div class="form-group">
        <div class="col-sm-offset-3 col-sm-9">
            <button type="submit" class="btn btn-primary"><span ng-transclude></span></button>
        </div>
    </div>
    '''
    replace: true
    transclude: true
    require: "^form"

    link: (scope, element, attrs, formController) ->
        watchExpression = formController.$name + ".$valid"
        scope.$watch watchExpression, (value) ->
            element.find("button").attr("disabled", !value)


angular.module("app.directives").directive "formHgroupError", ->
    template: '''
    <div class="form-group" ng-show="error_message">
        <div class="col-sm-12">
            <div class="form-error alert alert-danger">
                <i class="fa fa-exclamation"></i> &nbsp; &nbsp;
                {{error_message}}
            </div>
        </div>
    </div>
    '''
    replace: true
    transclude: true
    require: "^form"

    link: (scope, element, attrs, formController) ->
        watchExpression = formController.$name + ".$error.message"
        scope.$watch watchExpression, (value) ->
            scope.error_message = value