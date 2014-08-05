window.getStackTrace = ->
    obj = {}
    Error.captureStackTrace(obj, getStackTrace)
    obj.stack

app = angular.module("app",
    ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ngGrid", "ui.bootstrap",
     "angularjs-gravatardirective", "ui.validate", "xeditable", "pascalprecht.translate"])

app.run ($rootScope, $location, $idle, $state, $interval, $window, editableOptions, editableThemes) ->
    app_history = []

    $rootScope.magic_unicorn = if magic_unicorn? then magic_unicorn else false

    editableOptions.theme = 'default'
    editableThemes['default'].submitTpl = '<button type="submit" class="btn btn-sm btn-primary"><i class="fa fa-check fa-lg"></i></button>'
    editableThemes['default'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-sm btn-warning"><i class="fa fa-times fa-lg"></i></button>'

    $rootScope.$on "$stateChangeSuccess", (event, toState, toParams, fromState, fromParams) ->
        app_history.push {state: fromState.name, params: fromState} if fromState.name

    $rootScope.history_back = ->
        return false if app_history.length == 0 or window.history.length == 0
        history_counter = 0
        loop
            history_counter += 1
            prev_page = app_history.pop()
            break unless prev_page
            break unless prev_page.state == "createwallet" or prev_page.state == "unlockwallet"
        return false if window.history.length < history_counter
        $window.history.go(0 - history_counter)
        return true

    $rootScope.history_forward = ->
        $window.history.forward()

    $rootScope.loading = false
    $rootScope.progress = 100
    $rootScope.showLoadingIndicator = (promise, i) ->
        $rootScope.loading = true
        $rootScope.progress = 0
        promise.finally ->
            $rootScope.loading = false
            if i
                $rootScope.progress = 100
                $interval.cancel(i)

    $rootScope.updateProgress = (p) ->
        $rootScope.progress = p

    $idle.watch()

app.config ($idleProvider, $stateProvider, $urlRouterProvider, $translateProvider) ->
    $translateProvider.useStaticFilesLoader
        prefix: 'locale-',
        suffix: '.json'
    lang = window.navigator.language
    if lang == "zh-CN"
        lang = "zh-CN"
    else
        lang = "en"
    
    $translateProvider.preferredLanguage(lang)

    $idleProvider.idleDuration(1776)
    $idleProvider.warningDuration(60)

    $urlRouterProvider.otherwise('/home')

    sp = $stateProvider

    sp.state
        name: 'home'
        url: '/home'
        templateUrl: "home.html"
        controller: "HomeController"

    sp.state
        name: 'help'
        url: '/help'
        templateUrl: "help.html"
        controller: "HelpController"

    sp.state
        name: 'preferences'
        url: '/preferences'
        templateUrl: "preferences.html"
        controller: "PreferencesController"

    sp.state
        name: 'proposals'
        url: '/proposals'
        templateUrl: "proposals.html"
        controller: "ProposalsController"

    sp.state
        name: 'console'
        url: '/console'
        templateUrl: "console.html"
        controller: "ConsoleController"

    sp.state
        name: 'createaccount'
        url: '/create/account'
        templateUrl: "createaccount.html"
        controller: "CreateAccountController"

    sp.state
        name: 'accounts'
        url: '/accounts'
        templateUrl: "accounts.html"
        controller: "AccountsController"

    sp.state
        name: 'directory'
        url: '/directory'
        templateUrl: "directory.html"
        controller: "DirectoryController"

    sp.state
        name: 'delegates'
        url: '/delegates'
        templateUrl: "delegates/delegates.html"
        controller: "DelegatesController"

    sp.state
        name: 'editaccount'
        url: '/accounts/:name/edit'
        templateUrl: "editaccount.html"
        controller: "EditAccountController"

    sp.state
        name: 'account'
        url: '/accounts/:name'
        templateUrl: "account.html"
        controller: "AccountController"

    sp.state
        name: 'blocks'
        url: '/blocks?withtrxs'
        templateUrl: "blocks.html"
        controller: "BlocksController"

    sp.state
        name: 'createwallet'
        url: '/createwallet'
        templateUrl: "createwallet.html"
        controller: "CreateWalletController"

    sp.state
        name: 'block'
        url: '/blocks/:number'
        templateUrl: "block.html"
        controller: "BlockController"

    sp.state
        name: 'blocksbyround'
        url: '/blocks/round/:round?withtrxs'
        templateUrl: "blocksbyround.html"
        controller: "BlocksByRoundController"

    sp.state
        name: 'transaction'
        url: '/tx/:id'
        templateUrl: "transaction.html"
        controller: "TransactionController"

    sp.state
        name: 'unlockwallet'
        url: '/unlockwallet'
        templateUrl: "unlockwallet.html"
        controller: "UnlockWalletController"

    sp.state
        name: 'markets'
        url: '/markets'
        templateUrl: "market/markets.html"
        controller: "MarketsController"

    sp.state "market", { url: "/market/:name/:account", templateUrl: "market/market.html", controller: "MarketController" }
    sp.state "market.buy", { url: "/buy", templateUrl: "market/buy.html" }  
    sp.state "market.sell", { url: "/sell", templateUrl: "market/sell.html" }  
    sp.state "market.short", { url: "/short", templateUrl: "market/short.html" }  

    sp.state
        name: 'transfer'
        url: '/transfer?from&to&amount&memo&asset'
        templateUrl: "transfer.html"
        controller: "TransferController"

    sp.state
        name: 'newcontact'
        url: '/newcontact?name&key'
        templateUrl: "newcontact.html"
        controller: "NewContactController"
