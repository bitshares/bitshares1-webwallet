app = angular.module("app", ["ngResource", "ui.router", "app.services", "app.directives", "ngGrid", "ui.bootstrap"])

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise('/home')

  home =
    name: 'home'
    url: '/home'
    templateUrl: "home.html"
    controller: "HomeController"

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
    url: '/accounts/:name/edit'
    templateUrl: "editaccount.html"
    controller: "EditAccountController"

  contacts =
    name: 'contacts'
    url: '/contacts'
    templateUrl: "contacts.html"
    controller: "ContactsController"

  contact =
    name: 'contact'
    url: '/contacts/:name'
    templateUrl: "contact.html"
    controller: "ContactController"

  account =
    name: 'account'
    url: '/accounts/:name'
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

  $stateProvider.state(home).state(proposals).state(createaccount).state(assets).state(console).state(delegates).state(editaccount).state(accounts).state(transfer).state(contacts).state(blocks).state(createwallet).state(contact).state(account).state(directory)

