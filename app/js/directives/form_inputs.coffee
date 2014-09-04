angular.module("app.directives").directive "inputName", ->
    template: '''
        <input autofocus id="account_name" name="account_name" ng-trim="false" placeholder="{{ 'directive.input_name.name_tip' | translate }}"
        autofocus ng-model="$parent.ngModel" ng-blur="removeTrailing()"
        my-ng-enter="removeTrailingDashes()"
        popover="{{ 'directive.input_name.popover' | translate }}"
        popover-append-to-body="{{popoverAppendToBody}}" popover-placement="top" popover-trigger="focus" ng-keydown="kd()"
        ng-change="ku()" uncapitalize type="text" class="form-control" required ng-minlength="1" ng-maxlength="63">
        <span class="help-block text-muted" ng-show="showNote1 && !formName.account_name.error_message" translate>directive.input_name.note1</span>
        <span class="help-block text-muted" ng-show="showNote2 && !formName.account_name.error_message" translate>directive.input_name.note2</span>
        <span class="help-block text-danger" ng-show="formName.account_name.error_message">{{formName.account_name.error_message}}</span>
    '''
    restrict: "E"
    scope:
        ngModel: "="
        formName: "="
        showNote1: "="
        showNote2: "="
        popoverTrigger: "="
        popoverAppendToBody: "="
    controller: ($scope, $element) ->
        oldname = $scope.ngModel
        $scope.kd = ->
            oldname = $scope.ngModel

        $scope.ku = ->
            if ($scope.formName && $scope.formName.account_name)
                $scope.formName.account_name.error_message = null
            return unless $scope.ngModel
            if ($scope.ngModel.length >= 63)
                $scope.ngModel = oldname
                return
            subnames = $scope.ngModel.split('.')
            i = 0
            last = subnames.length - 1
            while i < last
                valid = /^[a-z]+(?:[a-z0-9\-])*[a-z0-9]$/.test(subnames[i])
                if(!valid)
                    $scope.ngModel = oldname
                    break
                ++i
            if(subnames[last] != '')
                valid = /^[a-z]+(?:[a-z0-9\-])*$/.test(subnames[last])
                if(!valid)
                    $scope.ngModel = oldname

        $scope.removeTrailing = ->
            $scope.ngModel = $scope.ngModel.replace(/\-+$/, "") if $scope.ngModel
            $scope.ngModel = $scope.ngModel.replace(/\.+$/, "") if $scope.ngModel

angular.module("app.directives").directive "inputPositiveNumber", ->
    template: '''
        <input class="form-control" placeholder="0.0" />
    '''
    restrict: "E"
    replace: true
    require: "ngModel"

    link: (scope, elm, attrs, ctrl) ->

        validator = (viewValue) ->
            #console.log "------ inputPositiveNumber viewValue 0 ------>", viewValue
            res = null
            if /^[\d\.\,\+]+$/.test(viewValue)
                #console.log "------ inputPositiveNumber viewValue 1 ------>", viewValue
                ctrl.$setValidity "float", true
                if $.isNumeric(viewValue)
                    res = parseFloat viewValue
                else
                    res = parseFloat viewValue.replace(",", "")
                    #console.log "------ inputPositiveNumber viewValue 1b ------>", viewValue, res
            else
                #console.log "------ inputPositiveNumber viewValue 2 ------>", viewValue
                ctrl.$setValidity "float", false
            return res

        ctrl.$parsers.unshift validator

        scope.$watch attrs.ngModel, (newValue) ->
            #console.log "------ $watch ------>", newValue
            return unless newValue
            res = validator(newValue)
            #console.log "------ $setViewValue ------>", newValue, res
            ctrl.$setViewValue(newValue)
            scope.$eval(attrs.ngModel + "=" + res)
