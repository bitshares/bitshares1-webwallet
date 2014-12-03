###* Keeps an observable/updated list mail messages ###
class MailInboxObserver
    
    ByteBuffer = window.dcodeIO.ByteBuffer
    
    constructor: (@MailAPI, @Observer, @q) ->
        @inbox = []
        @ids = {}
        @first_run = on # start by loading all mail messages
        @observer_config =
            name: "MailInboxObserver"
            frequency: 10 * 1000
            update: (data, deferred) =>
                @refresh().then ->
                    deferred.resolve()
    
    start: ->
        @Observer.registerObserver @observer_config
    
    stop: ->
        @Observer.unregisterObserver @observer_config
    
    refresh: ->
        deferred = @q.defer()
        if @first_run
            @first_run = off
            # show inbox while doing a slower new message check
            @check_inbox().then =>
                @new_messages(true).then (result) =>
                    if result
                        @check_inbox().then =>
                            @first_run = false
                            deferred.resolve()
                    else
                        deferred.resolve()
        else
            @new_messages(false).then (result) =>
                if result
                    @check_inbox().then =>
                        deferred.resolve()
                else
                    deferred.resolve()
        deferred.promise
        
    # slow
    new_messages: (fetch_old) ->
        deferred = @q.defer()
        @MailAPI.check_new_messages(fetch_old).then (result) ->
            deferred.resolve()
        deferred.promise
        
    check_inbox: ->
        deferred = @q.defer()
        inbox_promise = @MailAPI.inbox()
        inbox_promise.then (result) =>
            
            new_messages = []
            for i in result
                continue if @ids[i.id]
                @ids[i.id] = i
                new_messages.push i
                
            # sort before they are shown
            new_messages.sort (a, b) ->
                a.timestamp > b.timestamp
            
            @inbox.unshift m for m in new_messages
            for i in new_messages
                @MailAPI.get_message(i.id).then (result) =>
                    # this may be a different i than above ( rpc call timming )
                    i = @ids[result.header.id]
                    i.type = result.content.type
                    switch i.type
                        # Hide none email message ( like transaction notices )
                        when 'email'
                            i.time = new Date(i.timestamp).toLocaleString()
                            try
                                hex = result.content.data
                                b = ByteBuffer.fromHex hex
                                # read subject, but ignore ( already in header )
                                subject = b.readVString() 
                                i.message = b.readVString()
                            catch exception
                                #stack = exception.stack
                                #Shared.addError(exception.message, stack)
                                console.log exception
            deferred.resolve()
        deferred.promise

angular.module("app").service "MailInboxObserver", ["MailAPI", "Observer", "$q", MailInboxObserver]