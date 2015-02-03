window.getStackTrace = ->
    trace = printStackTrace()
    for value, index in trace
       if value.indexOf("getStackTrace@") >= 0
           trace.splice(0, index) if index >= 0
           break
    trace.join("\n ○ ")

window.open_external_url = (url) ->
    if magic_unicorn?
        magic_unicorn.open_in_external_browser(url)
    else
        window.open(url)

app = angular.module("app",
    ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ui.bootstrap",
     "ui.validate", "xeditable", "pascalprecht.translate", "pageslide-directive", "ui.grid", "utils.autofocus"])

app.run ($rootScope, $location, $idle, $state, $interval, $window, $templateCache, $translate, editableOptions, editableThemes) ->
    $templateCache.put 'ui-grid/uiGridViewport',
        '''<div class="ui-grid-viewport">
             <div class="ui-grid-canvas">
               <div ng-repeat="(rowRenderIndex, row) in rowContainer.renderedRows track by row.uid" class="ui-grid-row" ng-class="row.entity.type" ng-style="containerCtrl.rowStyle(rowRenderIndex)">
                 <div ui-grid-row="row" row-render-index="rowRenderIndex"></div>
               </div>
              </div>
           </div>'''

    $rootScope.context_help = {locale: "en", show: false, file: "", open: false}
    app_history = []

    $rootScope.magic_unicorn = if magic_unicorn? then magic_unicorn else false
    $rootScope.magic_unicorn.log_message(navigator.userAgent) if $rootScope.magic_unicorn

    window.navigate_to = (path) ->
        if path[0] == "/"
            window.location.href = "/#" + path
        else
            $state.go(path)

    editableOptions.theme = 'default'
    editableThemes['default'].submitTpl = '<button type="submit" class="btn btn-sm btn-primary"><i class="fa fa-check fa-lg"></i></button>'
    editableThemes['default'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-sm btn-warning"><i class="fa fa-times fa-lg"></i></button>'

    $rootScope.$on "$stateChangeSuccess", (event, toState, toParams, fromState, fromParams) ->
        app_history.push {state: fromState.name, params: fromParams} if fromState.name

    $rootScope.history_back = ->
        return false if app_history.length == 0
        loop
            prev_page = app_history.pop()
            break unless prev_page
            break unless prev_page.state == "createwallet" or prev_page.state == "unlockwallet"
        $state.go(prev_page.state, prev_page.params) if prev_page
        return !!prev_page

    $rootScope.history_forward = ->
        $window.history.forward()

    $rootScope.loading_indicator = {show: false,  progress: null}
    $rootScope.showLoadingIndicator = (promise, progress = null) ->
        li = $rootScope.loading_indicator
        li.show = true
        li.progress = if progress then progress.replace("{{value}}", '0') else ""
        promise.then ->
            li.show = false
        , ->
            li.show = false
        ,  (value) ->
            li.progress = progress.replace("{{value}}", value) if progress

    $rootScope.showContextHelp = (name) ->
        if name
            $rootScope.context_help.show = true
            $rootScope.context_help.file = "context_help/#{$translate.preferredLanguage()}/#{name}.html"
        else
            $rootScope.context_help.show = false
            $rootScope.context_help.file = ""

    $rootScope.current_account = null

    $idle.watch()

app.config ($idleProvider, $translateProvider, $tooltipProvider, $compileProvider) ->

    $compileProvider.debugInfoEnabled(false);

    $tooltipProvider.options { appendToBody: true }

    $translateProvider.useStaticFilesLoader
        prefix: 'locale-',
        suffix: '.json'

    lang = switch(window.navigator.language)
      when "zh-CN" then "zh-CN"
      when "de", "de-DE", "de-de" then "de"
      when "ru", "ru-RU", "ru-ru" then "ru"
      when "it", "it-IT", "it-it" then "it"
      when "ko", "ko-KR", "ko-kr" then "ko"
      else "en"
      
    moment.locale(lang)

    $translateProvider.preferredLanguage(lang)

    $idleProvider.idleDuration(1776)
    $idleProvider.warningDuration(60)


