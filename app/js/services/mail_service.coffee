###* Keeps an observable/updated list mail messages ###
class MailService
    
    ByteBuffer = window.dcodeIO.ByteBuffer
    
    constructor: (@MailAPI, @Observer, @q) ->
        @inbox = []
        @inbox_ids = {}
        
        @processing = []
        ### @processing_ids["7df65e70b56460b206334e4f754f8e6b14b64ea8"] = "failed" ###
        @processing_ids = {}
        
        @first_run = on # start by loading all mail messages
        @observer_config =
            name: "MailService"
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
        check_all = (deferred, fetch_old) =>
            p1 = @check_new_messages(fetch_old)
            p2 = @check_processing()
            @q.all([p1,p2]).then ->
                deferred.resolve()
        
        if @first_run
            @first_run = off
            # show inbox while running the slower normal remote check
            @check_inbox().then =>
                check_all(deferred, true)
        else
            check_all(deferred, false)
        deferred.promise
        
    check_new_messages: (fetch_old) ->
        deferred = @q.defer()
        @MailAPI.check_new_messages(fetch_old).then (result) => # slow
            if result
                @check_inbox().then =>
                    deferred.resolve()
            else
                deferred.resolve()
        deferred.promise
    
    check_inbox: ->
        deferred = @q.defer()
        inbox_promise = @MailAPI.inbox()
        inbox_promise.then (result) =>
            
            new_messages = []
            for i in result
                continue if @inbox_ids[i.id]
                @inbox_ids[i.id] = i
                new_messages.push i
                
            # sort before they are shown
            new_messages.sort (a, b) ->
                a.timestamp > b.timestamp
            
            @inbox.unshift m for m in new_messages
            for i in new_messages
                @MailAPI.get_message(i.id).then (result) =>
                    # this may be a different i than above ( rpc call timming )
                    i = @inbox_ids[result.header.id]
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
                                i.body = b.readVString()
                            catch exception
                                #stack = exception.stack
                                #Shared.addError(exception.message, stack)
                                console.log exception
            deferred.resolve()
        deferred.promise
        
    check_processing: ->
        deferred = @q.defer()
        @MailAPI.get_processing_messages().then (result) =>
            # [  ["failed", "7df65e70b56460b206334e4f754f8e6b14b64ea8"]  ]
            new_processing = result
            for status, id in @processing_ids
                unless new_processing[id]
                    delete @processing_ids[id]
            
            for status, id in new_processing
                unless @processing_ids[id]
                    @processing_ids[id] = status
            
            deferred.resolve()
        deferred.promise
    
    retry_processing: (id) ->
        # mail_retry_send 7df65e70b56460b206334e4f754f8e6b14b64ea8
        deferred = @q.defer()
        @MailAPI.retry_send(id).then (result) =>
            deferred.resolve(result)
        deferred.promise
    
    ###
    Resolve's as:
    {
      "header": {
        "id": "7df65e70b56460b206334e4f754f8e6b14b64ea8",
        "sender": "delegate0",
        "recipient": "delegate1",
        "subject": "0->1 subject",
        "timestamp": "2014-12-04T15:04:21"
      },
      "content": {
        "type": "email",
        "recipient": "XTS2Kpf4whNd3TkSi6BZ6it4RXRuacUY1qsj",
        "nonce": 31692078,
        "timestamp": "2014-12-04T15:04:21",
        "data": "0af0...."
      },
      "mail_servers": [],
      "failure_reason": "Could not find mail servers for this recipient."
    }
    {string} id - two id types supported: initial ID hash 7df65e70b56460b206334e4f754f8e6b14b64ea8 or re-assigned proof-of-work id 00076bf1ddedaabd27a6eb472da6882959248c05.
    ###
    get_message: (id) ->
        deferred = @q.defer()
        @MailAPI.get_message(id).then (result) => # slow
            deferred.resolve(result)
        deferred.promise

angular.module("app").service "MailService", ["MailAPI", "Observer", "$q", MailService]