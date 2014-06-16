app = angular.module("app", ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ngGrid", "ui.bootstrap"])

app.run [
  "$idle"
  ($idle) ->
    $idle.watch()
]

app.config ($keepaliveProvider, $idleProvider, $stateProvider, $urlRouterProvider) ->
  
  $idleProvider.idleDuration(5)
  $idleProvider.warningDuration(5)
  $keepaliveProvider.interval(10)

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

  block =
    name: 'block'
    url:  '/blocks/:number'
    templateUrl: "block.html"
    controller: "BlockController"

  blocksbyhour =
    name: 'blocksbyhour'
    url: '/blocks/hour/:hour'
    templateUrl: "blocksbyhour.html"
    controller: "BlocksByHourController"

  transaction =
    name: 'transaction'
    url:  '/tx/:id'
    templateUrl: "transaction.html"
    controller: "TransactionController"

  unlockwallet =
    name: 'unlockwallet'
    url:  '/unlockwallet'
    templateUrl: "unlockwallet.html"
    controller: "UnlockWalletController"

  $stateProvider.state(home).state(unlockwallet).state(proposals).state(createaccount).state(console).state(editaccount).state(accounts).state(transfer).state(blocks).state(createwallet).state(account).state(directory).state(block).state(transaction).state(blocksbyhour)

