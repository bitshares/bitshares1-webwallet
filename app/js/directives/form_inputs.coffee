angular.module("app.directives").directive "inputName", ->
    template: '''
        <input autofocus id="account_name" name="account_name" ng-trim="false" placeholder="Name (Required)"
        autofocus ng-model="$parent.ngModel" ng-blur="removeTrailing()"
        my-ng-enter="removeTrailingDashes()"
        popover="Only lowercase alphanumeric characters, dots, and dashes.\nMust start with a letter and cannot end with a dash."
        popover-append-to-body="false" popover-placement="top" popover-trigger="focus" ng-keydown="kd()"
        ng-change="ku()" uncapitalize type="text" class="form-control" required ng-minlength="1" ng-maxlength="63">
        <span class="help-block text-muted" ng-show="showNote1 && !formName.account_name.error_message">Note: Account names cannot be transferred.</span>
        <span class="help-block text-muted" ng-show="showNote2 && !formName.account_name.error_message">Only lowercase alphanumeric characters, dots, and dashes. Must start with a letter and cannot end with a dash.</span>
        <span class="help-block text-danger" ng-show="formName.account_name.error_message">{{formName.account_name.error_message}}</span>
    '''
    restrict: "E"
    scope:
        ngModel: "="
        formName: "="
        showNote1: "="
        showNote2: "="
        popoverTrigger: "="
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
        <input class="form-control" ui-validate="'validate($value)'" placeholder="0.0" />
    '''
    restrict: "E"
    replace: true
    require: "^form"
    scope:
        ngModel: "="
        name: "@"
        required: "@"
    controller: ($scope, $element) ->
        $scope.validate = (value) ->
            return true if (!value and !$scope.required)
            return $.isNumeric(value) and value >= 0
