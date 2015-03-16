###* Keeps an observable/updated list of accounts ###
class AccountObserver
    
    constructor: (@Wallet, @q, @Observer) ->
        @my_accounts = []
        @my_mail_accounts = []
        @accounts = {}
        @observer_config =
            name: "AccountObserver"
            frequency: "each_block"
            update: (data, deferred) =>
                @refresh().then ->
                    deferred.resolve()
    
    start: ->
        @Observer.registerObserver @observer_config
    
    stop: ->
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
        deferred = @q.defer()
        refresh_accounts_promise = @Wallet.refresh_accounts()
        refresh_accounts_promise.then =>
            @my_accounts.splice(0, @my_accounts.length)
            @my_mail_accounts.splice(0, @my_mail_accounts.length)
            for k,a of @Wallet.accounts
                @accounts[k] = a
                @my_accounts.push a
                @my_mail_accounts.push a if a.public_data?.mail_servers

            deferred.resolve()
        
        deferred.promise

angular.module("app").service "AccountObserver", ["Wallet", "$q", "Observer", AccountObserver]