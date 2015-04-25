angular.module("app.directives").directive "inputAccountName", ->
    template: '''
        <input class="form-control"/>
    '''
    restrict: "E"
    replace: true
    require: "ngModel"
    link: (scope, element, attrs, ctrl) ->
        validator = (viewValue) ->
            res = null
            if viewValue == "" and not scope.required
                ctrl.$setValidity "account-name", true
                return ""
            if /^[a-z]+(?:[a-z0-9\-\.])*$/.test(viewValue) and /[a-z0-9]$/.test(viewValue)
                ctrl.$setValidity "account-name", true
                res = viewValue
            else
                ctrl.$setValidity "account-name", false
            return res

        ctrl.$parsers.unshift validator



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
          <button type="button" class="btn dropdown-toggle" dropdown-toggle ng-disabled="false">{{amount.symbol}} <span class="caret"></span></button>
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


