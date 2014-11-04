window.getStackTrace = ->
    trace = printStackTrace()
    for value, index in trace
       if value.indexOf("getStackTrace@") >= 0
           trace.splice(0, index) if index >= 0
           break
    trace.join("\n ○ ")

app = angular.module("app",
    ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ui.bootstrap",
     "ui.validate", "xeditable", "pascalprecht.translate", "pageslide-directive", "ui.grid"])

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

    $idle.watch()

app.config ($idleProvider, $stateProvider, $urlRouterProvider, $translateProvider, $tooltipProvider) ->

    $tooltipProvider.options { appendToBody: true }

    $translateProvider.useStaticFilesLoader
        prefix: 'locale-',
        suffix: '.json'

    lang = switch(window.navigator.language)
      when "zh-CN" then "zh-CN"
      when "de", "de-de" then "de"
      when "ru", "ru-RU" then "ru"
      else "en"

    $translateProvider.preferredLanguage(lang)

    $idleProvider.idleDuration(1776)
    $idleProvider.warningDuration(60)

    $urlRouterProvider.otherwise('/home')

    sp = $stateProvider

    sp.state "home",
        url: "/home"
        templateUrl: "home.html"
        controller: "HomeController"

    sp.state "help",
        url: "/help"
        templateUrl: "help.html"
        controller: "HelpController"

    sp.state "preferences",
        url: "/preferences"
        templateUrl: "preferences.html"
        controller: "PreferencesController"

    sp.state "proposals",
        url: "/proposals"
        templateUrl: "proposals.html"
        controller: "ProposalsController"

    sp.state "console",
        url: "/console"
        templateUrl: "console.html"
        controller: "ConsoleController"

    sp.state "createaccount",
        url: "/create/account"
        templateUrl: "createaccount.html"
        controller: "CreateAccountController"

    sp.state "accounts",
        url: "/accounts"
        templateUrl: "accounts.html"
        controller: "AccountsController"

    sp.state "directory",
        url: "/directory"
        templateUrl: "directory/directory.html"
        controller: "DirectoryController"

    sp.state "directory.favorites", { url: "/favorites", views: { 'directory-favorites': { templateUrl: 'directory/favorite.html', controller: 'FavoriteController' } } }

    sp.state "directory.unregistered", { url: "/unregistered", views: { 'directory-unregistered': { templateUrl: 'contacts.html', controller: 'ContactsController' } } }

    sp.state "directory.registered", { url: "/registered?letter", views: { 'directory-registered': { templateUrl: 'directory/registered.html' } } }

    sp.state "directory.assets", { url: "/assets", views: { 'directory-assets': { templateUrl: 'directory/assets.html', controller: 'AssetsController' } } }

    sp.state "delegates",
        url: "/delegates"
        templateUrl: "delegates/delegates.html"
        controller: "DelegatesController"

#    sp.state "editaccount",
#        url: "/accounts/:name/edit"
#        templateUrl: "editaccount.html"
#        controller: "EditAccountController"

    sp.state "account",
        url: "/accounts/:name"
        templateUrl: "account.html"
        controller: "AccountController"

    sp.state "account.transactions", { url: "/account_transactions?pending_only", views: { 'account-transactions': { templateUrl: 'account_transactions.html', controller: 'TransactionsController' } } }

    sp.state "account.priceFeed", { url: "/account_delegate", views: { 'account-delegate-price-feed': { templateUrl: 'account_delegate_price_feeds.html', controller: 'AccountDelegatePriceFeeds' } } }

    sp.state "account.transfer", { url: "/account_transfer?from&to&amount&memo&asset", views: { 'account-transfer': { templateUrl: 'transfer.html', controller: 'TransferController' } } }

    sp.state "account.manageAssets", { url: "/account_assets", views: { 'account-manage-assets': { templateUrl: 'manage_assets.html', controller: 'ManageAssetsController' } } }

    sp.state "account.keys", { url: "/account_keys", views: { 'account-keys': { templateUrl: 'account_keys.html', controller: 'AccountController' } } }

    sp.state "account.updateRegAccount", { url: "/account_edit_registered", views: { 'account-update-reg-account': { templateUrl: 'update-reg-account.html', controller: 'UpdateRegAccountController' } } }

    sp.state "account.editLocal", { url: "/account_edit_local", views: { 'account-editlocal': { templateUrl: 'editlocal.html', controller: 'EditLocalController' } } }

    sp.state "account.vote", { url: "/account_vote", views: { 'account-vote': { templateUrl: 'account_vote.html', controller: 'AccountVoteController' } } }

    sp.state "asset",
        url: "/assets/:ticker"
        templateUrl: "asset.html"
        controller: "AssetController"

    sp.state "blocks",
        url: "/blocks?withtrxs"
        templateUrl: "blocks.html"
        controller: "BlocksController"

    sp.state "createwallet",
        url: "/createwallet"
        templateUrl: "createwallet.html"
        controller: "CreateWalletController"

    sp.state "block",
        url: "/blocks/:number"
        templateUrl: "block.html"
        controller: "BlockController"

    sp.state "blocksbyround",
        url: "/blocks/round/:round?withtrxs"
        templateUrl: "blocksbyround.html"
        controller: "BlocksByRoundController"

    sp.state "transaction",
        url: "/tx/:id"
        templateUrl: "transaction.html"
        controller: "TransactionController"

    sp.state "unlockwallet",
        url: "/unlockwallet"
        templateUrl: "unlockwallet.html"
        controller: "UnlockWalletController"

    sp.state "markets",
        url: "/markets"
        templateUrl: "market/markets.html"
        controller: "MarketsController"

    sp.state "market",
        abstract: true
        url: "/market/:name/:account"
        templateUrl: "market/market.html"
        controller: "MarketController"

    sp.state "market.buy", { url: "/buy", templateUrl: "market/buy.html" }
    sp.state "market.sell", { url: "/sell", templateUrl: "market/sell.html" }
    sp.state "market.short", { url: "/short", templateUrl: "market/short.html" }

    sp.state "transfer",
        url: "/transfer?from&to&amount&memo&asset"
        templateUrl: "transfer.html"
        controller: "TransferController"

    sp.state "newcontact",
        url: "/newcontact?name&key"
        templateUrl: "newcontact.html"
        controller: "NewContactController"
