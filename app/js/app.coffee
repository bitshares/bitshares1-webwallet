app = angular.module("app", ["ngResource", "ui.router", "app.services", "app.directives", "ngGrid", "ui.bootstrap"])

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise('/home')

  home =
    name: 'home'
    url: '/home'
    templateUrl: "home.html"
    controller: "HomeController"

  console =
    name: 'console'
    url: '/console'
    templateUrl: "console.html"
    controller: "ConsoleController"

  accounts =
    name: 'accounts'
    url: '/accounts'
    templateUrl: "accounts.html"
    controller: "AccountsController"

  delegates =
    name: 'delegates'
    url: '/delegates'
    templateUrl: "delegates.html"
    controller: "DelegatesController"

  directory =
    name: 'directory'
    url: '/directory'
    templateUrl: "directory.html"
    controller: "DirectoryController"

  transfer =
    name: 'transfer'
    url: '/transfer'
    templateUrl: "transfer.html"
    controller: "TransferController"

  editaccount =
    name: 'editaccount'
    url: '/editaccount'
    templateUrl: "editaccount.html"
    controller: "EditAccountController"

  contacts =
    name: 'contacts'
    url: '/contacts'
    templateUrl: "contacts.html"
    controller: "ContactsController"

  contact =
    name: 'contact'
    url: '/contacts/:contactName'
    templateUrl: "contact.html"
    controller: "ContactController"

  account =
    name: 'account'
    url: '/accounts/:accountName'
    templateUrl: "account.html"
    controller: "AccountController"

  blocks =
    name: 'blocks'
    url: '/blocks'
    templateUrl: "blocks.html"
    controller: "BlocksController"

  createwallet =
    name: 'createwallet'
    url: '/createwallet'
    templateUrl: "createwallet.html"
    controller: "CreateWalletController"

  assets =
    name: 'assets'
    url: '/assets'
    templateUrl: "assets.html"
    controller: "AssetsController"

  $stateProvider.state(home).state(assets).state(console).state(delegates).state(editaccount).state(accounts).state(transfer).state(contacts).state(blocks).state(createwallet).state(contact).state(account).state(directory)

