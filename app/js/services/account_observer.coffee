###* Keeps an observable/updated list of accounts ###
class AccountObserver
    
    constructor: (@Wallet, @q, @Observer) ->
        @my_accounts = []
        @accounts = {}
        @observer_config =
            name: "AccountObserver"
            frequency: "each_block"
            update: =>
                @refresh()
    
    start: ->
        console.log 'start'
        @Observer.registerObserver @observer_config
    
    stop: ->
        console.log 'stop'
        @Observer.unregisterObserver @observer_config
    
    best_account: (name) ->
        deferred = @q.defer()
        account = @Wallet.accounts[name]
        if account
            deferred.resolve(account)
        else
            @Wallet.get_current_or_first_account().then (account)->
                deferred.resolve(account)
        
        deferred.promise
    
    refresh: ->
        console.log 'refresh'
        deferred = @q.defer()
        refresh_accounts_promise = @Wallet.refresh_accounts()
        refresh_accounts_promise.then =>
            @my_accounts.splice(0, @my_accounts.length)
            for k,a of @Wallet.accounts
                @my_accounts.push a if a.is_my_account
    
            angular.forEach @Wallet.accounts, (acct, name) =>
                if acct.is_my_account
                    @accounts[name] = acct
                    
            deferred.resolve()
        
        deferred.promise

angular.module("app").service "AccountObserver", ["Wallet", "$q", "Observer", AccountObserver]