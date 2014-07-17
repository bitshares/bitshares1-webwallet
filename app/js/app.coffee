window.getStackTrace = ->
    obj = {}
    Error.captureStackTrace(obj, getStackTrace)
    obj.stack

app = angular.module("app",
    ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ngGrid", "ui.bootstrap",
     "angularjs-gravatardirective", "ui.validate", "xeditable", "pascalprecht.translate"])

#app.run [
#  "$idle"
#  ($idle) ->
#    $idle.watch()
#]

app.run ($rootScope, $location, $idle, $interval, editableOptions, editableThemes) ->
    history = []

    editableOptions.theme = 'default'
    editableThemes['default'].submitTpl = '<button type="submit" class="btn btn-sm btn-primary"><i class="fa fa-check fa-lg"></i></button>'
    editableThemes['default'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-sm btn-warning"><i class="fa fa-times fa-lg"></i></button>'

    $rootScope.$on '$locationChangeSuccess', ()->
        history.push $location.$$path

    $rootScope.history_back = ()->
        prevUrl = if history.length > 1 then history.splice(-2)[0] else "/home"
        $location.path(prevUrl)

    $rootScope.loading = false
    $rootScope.progress = 100
    $rootScope.showLoadingIndicator = (promise, i) ->
        $rootScope.loading = true
        if i
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
    $translateProvider.preferredLanguage('en')

    $idleProvider.idleDuration(600)
    $idleProvider.warningDuration(60)

    $urlRouterProvider.otherwise('/home')

    home =
        name: 'home'
        url: '/home'
        templateUrl: "home.html"
        controller: "HomeController"

    help =
        name: 'help'
        url: '/help'
        templateUrl: "help.html"
        controller: "HelpController"

    preferences =
        name: 'preferences'
        url: '/preferences'
        templateUrl: "preferences.html"
        controller: "PreferencesController"

    proposals =
        name: 'proposals'
        url: '/proposals'
        templateUrl: "proposals.html"
        controller: "ProposalsController"

    console =
        name: 'console'
        url: '/console'
        templateUrl: "console.html"
        controller: "ConsoleController"

    createaccount =
        name: 'createaccount'
        url: '/create/account'
        templateUrl: "createaccount.html"
        controller: "CreateAccountController"

    accounts =
        name: 'accounts'
        url: '/accounts'
        templateUrl: "accounts.html"
        controller: "AccountsController"

    directory =
        name: 'directory'
        url: '/directory'
        templateUrl: "directory.html"
        controller: "DirectoryController"

    editaccount =
        name: 'editaccount'
        url: '/accounts/:name/edit'
        templateUrl: "editaccount.html"
        controller: "EditAccountController"

    account =
        name: 'account'
        url: '/accounts/:name'
        templateUrl: "account.html"
        controller: "AccountController"

    blocks =
        name: 'blocks'
        url: '/blocks?withtrxs'
        templateUrl: "blocks.html"
        controller: "BlocksController"

    createwallet =
        name: 'createwallet'
        url: '/createwallet'
        templateUrl: "createwallet.html"
        controller: "CreateWalletController"

    block =
        name: 'block'
        url: '/blocks/:number'
        templateUrl: "block.html"
        controller: "BlockController"

    blocksbyround =
        name: 'blocksbyround'
        url: '/blocks/round/:round?withtrxs'
        templateUrl: "blocksbyround.html"
        controller: "BlocksByRoundController"

    transaction =
        name: 'transaction'
        url: '/tx/:id'
        templateUrl: "transaction.html"
        controller: "TransactionController"

    unlockwallet =
        name: 'unlockwallet'
        url: '/unlockwallet'
        templateUrl: "unlockwallet.html"
        controller: "UnlockWalletController"

    markets =
        name: 'markets'
        url: '/markets'
        templateUrl: "market/markets.html"
        controller: "MarketsController"

    market =
        name: 'market'
        url: '/market/:name/:account'
        templateUrl: "market/market.html"
        controller: "MarketController"


    $stateProvider.state(home).state(help).state(preferences).state(unlockwallet).state(proposals).state(createaccount)
    .state(console).state(editaccount).state(accounts).state(blocks).state(createwallet).state(account).state(directory)
    .state(block).state(transaction).state(blocksbyround).state(markets).state(market)
