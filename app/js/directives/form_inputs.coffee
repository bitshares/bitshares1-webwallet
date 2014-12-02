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



angular.module("app.directives").directive "inputPositiveNumber", ($compile, $tooltip) ->
    template: '''
        <input class="form-control" placeholder="0.0 {{required ? '' : '(optional)'}}" />
    '''
    restrict: "E"
    replace: true
    require: "ngModel"

    scope:
        required: "="

    link: (scope, element, attrs, ctrl) ->
#        console.log "------ $tooltip ------>", $tooltip
#        element.after('''<i class="fa fa-question-circle"></i>''')
#        element.parent().addClass("right-inner-addon")
#        $compile(element.contents())(scope)

        validator = (viewValue) ->
            res = null
            if viewValue == "" and not scope.required
                ctrl.$setValidity "float", true
                return 0

            if /^[\d\.\,\+]+$/.test(viewValue)
                ctrl.$setValidity "float", true
                if $.isNumeric(viewValue)
                    res = parseFloat viewValue
                else
                    res = parseFloat viewValue.replace(/,/g, "")
            else
                ctrl.$setValidity "float", false
            return res

        ctrl.$parsers.unshift validator



angular.module("app.directives").directive "inputAssetAmount", ($compile) ->
    template: '''
        <div class="input-asset-amount">
        <input style="width: 12em;" class="form-control" ng-model="amount.value" placeholder="0.0 {{required ? '' : '(optional)'}}" />
        <div class="input-group-btn" dropdown is-open="status.isopen">
          <button type="button" class="btn dropdown-toggle" ng-disabled="false">{{amount.symbol}} <span class="caret"></span></button>
          <ul class="dropdown-menu" role="menu">
            <li ng-repeat="s in symbols">
              <a ng-click="amount.symbol = s; status.isopen = false">{{s}}</a>
            </li>
          </ul>
        </div>
        </div>
    '''
    restrict: "E"
    replace: true
    require: ["ngModel", "^formHgroup"]

    scope:
        required: "="
        symbols: "="

    link: (scope, element, attrs, controllers) ->
        ctrl = controllers[0]
        hgroup_ctrl = controllers[1]

        ctrl.$parsers.push (viewValue) ->
            res = null
            if !viewValue.value and (!scope.required or ctrl.$pristine)
                # TODO: ctrl.$pristine is always false for some reason
                ctrl.$setValidity "float", true
                return {value: 0, symbol: viewValue.symbol}

            if /^[\d\.\,\+]+$/.test(viewValue.value)
                ctrl.$setValidity "float", true
                if $.isNumeric(viewValue.value)
                    res = parseFloat viewValue.value
                else
                    res = parseFloat viewValue.value.replace(/,/g, "")
            else
                ctrl.$setValidity "float", false
            return {value: res || viewValue.value, symbol: viewValue.symbol}

        ctrl.$formatters.push (modelValue) ->
            return {value: modelValue.value, symbol: modelValue.symbol}

        scope.$watch 'amount.value + amount.symbol', ->
            ctrl.$setViewValue(scope.amount)
            hgroup_ctrl.clear_errors()

        scope.$watch ->
            ctrl.$modelValue
        , (val) ->
            return unless val
            ctrl.$viewValue.value = val.value
            ctrl.$viewValue.symbol = val.symbol
        , true

        ctrl.$render = ->
            scope.amount = ctrl.$viewValue


