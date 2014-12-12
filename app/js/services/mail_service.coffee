class Mailbox
    
    constructor: ->
        @folder = []
        @folder_idx = {}
        
        # sets the order
        @get 'inbox'
        @get 'sent'
    
    get: (name) ->
        throw 'Missing folder name' unless name
        folder = @folder_idx[name]
        return folder if folder
        folder =
            name: name
            mail: []
            mail_idx: {}
            new_mail: []
            new_mail_idx: {}
        @folder.push folder
        @folder_idx[name] = folder
        folder

    update: (folder_name, id, status) ->
        folder = @get folder_name
        
        existing_mail = folder.mail_idx[id]
        existing_mail?.status = status
        
        mail = { id: id, status: status }
        folder.new_mail.push mail
        folder.new_mail_idx[id] = mail
        
    ###* {return} true if id was found and removed ###
    remove: (id) ->
        # assumes message is in only one folder
        for folder in @folder
            if folder.mail_idx[id]
                 delete folder.mail_idx[id]
                 for i in [0...folder.mail.length] by 1
                     if folder.mail[i].id is id
                         folder.mail.splice i,1
                         break
                 throw 'missmatch' if folder.mail.length isnt Object.keys(folder.mail_idx).length
                 return true
        false
                         

###* Keeps an observable/updated list mail messages ###
class MailService
    
    ByteBuffer = window.dcodeIO.ByteBuffer
    
    constructor: (@MailAPI, @Observer, @q, @timeout) ->
        @mailbox = new Mailbox()
        @first_run = on # start by loading all mail messages
        @refreshing = off
        @observer_config =
            name: "MailService"
            frequency: 10 * 1000
            update: (data, deferred) =>
                @observer_refresh().then ->
                    deferred.resolve()
    
    start: ->
        #console.log 'register mail service'
        @Observer.registerObserver @observer_config
    
    stop: ->
        #console.log 'unregister mail service'
        @Observer.unregisterObserver @observer_config
        
    refresh: ->
        @Observer.refresh(@observer_config)
        
    retry_processing: (id) ->
        # mail_retry_send 7df65e70b56460b206334e4f754f8e6b14b64ea8
        deferred = @q.defer()
        @MailAPI.retry_send(id).then (result) =>
            deferred.resolve(result)
        deferred.promise
    
    #delete_all: (ids) ->
    #    @q.all(for id in ids
    #        @remove_message id
    #    )
    
    remove_message: (id) ->
        deferred = @q.defer()
        @MailAPI.remove_message(id).then (result) =>
            @mailbox.remove id
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
        
    observer_refresh: ->
        check_all = () =>
            add_by_status = (result) =>
                for r in result
                    status = r[0]
                    id = r[1]
                    folder_name = switch status
                        when 'accepted'
                            'sent'
                        when 'received'
                            'inbox'
                        when 'failed'
                            status
                        else
                            status
                            
                    @mailbox.update(folder_name, id, status)
            
            p1 = @q.defer()
            archive = @MailAPI.get_archive_messages()
            processing = @MailAPI.get_processing_messages()
            @q.all(
                archive:archive
                processing:processing 
            ).then (result) =>
                add_by_status(result.archive)
                add_by_status(result.processing)
                @sync_mailbox()
                p1.resolve()
            p1.promise
        
        deferred = @q.defer()
        @refreshing = on
        if @first_run
            @first_run = off
            # show inbox while running the slower normal remote check
            check_all().then =>
                @MailAPI.check_new_messages(fetch_old = true).then =>
                    check_all().then =>
                       deferred.resolve()
                       @refreshing = off
        else
            @MailAPI.check_new_messages(fetch_old = true).then =>
                check_all().then =>
                    deferred.resolve() 
                    @refreshing = off
        deferred.promise
        
    sync_mailbox: ->
        @q.all(
            for folder in @mailbox.folder
                @sync_folder folder
        )
        
    ###* 
        Delete missing or removed messages, then do a full API lookup on new messages
    ###
    sync_folder: (folder) ->
        mail = folder.mail
        mail_idx = folder.mail_idx
        new_mail = folder.new_mail
        new_mail_idx = folder.new_mail_idx
        
        for i in [mail.length - 1..0] by -1
            m = mail[i]
            # messages were removed
            unless new_mail_idx[m.id]
                mail.splice i, 1
                delete mail_idx[m.id]
        
        for i in [new_mail.length - 1..0] by -1
            m = new_mail[i]
            # messages already loaded
            if mail_idx[m.id]
                new_mail.splice i, 1
                delete new_mail_idx[m.id]
        
        deferred_get_message = []
        deferred_process_message = []
        for m in new_mail
            promise = @MailAPI.get_message(m.id)
            deferred_get_message.push promise
            promise.then (result) =>
                deferred = @q.defer()
                deferred_process_message.push deferred
                # this will be a different i than above ( rpc call timming )
                m = new_mail_idx[result.header.id]
                m.sender = result.header.sender
                m.recipient = result.header.recipient
                m.subject = result.header.subject
                m.type = result.content.type
                m.timestamp = result.header.timestamp
                m.time = new Date(m.timestamp).toLocaleString()
                m.failure_reason = result.failure_reason
                switch m.type
                    # Hide none email message ( like transaction notices )
                    when 'email'
                        try
                            hex = result.content.data
                            b = ByteBuffer.fromHex hex
                            # reading the subject advances position in the stream
                            m.subject = b.readVString() 
                            m.body = b.readVString()
                        catch exception
                            #stack = exception.stack
                            #Shared.addError(exception.message, stack)
                            console.log exception, m
                    else
                        console.log 'unprocessed message type',m
                
                deferred.resolve()
                
        # re-check failed messages where the 
        # failure reason has been cleared
        if folder.name is 'failed'
            for m in mail
                continue if new_mail[m.id]
                if not m.failure_reason or m.failure_reason is 'unspecified'
                    promise = @MailAPI.get_message(m.id)
                    deferred_get_message.push promise
                    my_mail = m # save reference
                    promise.then (result) =>
                        deferred = @q.defer()
                        deferred_process_message.push deferred
                        #console.log 'mail_service updating failure reason',m.failure_reason,result.failure_reason
                        my_mail.failure_reason = result.failure_reason
                    
        
        deferred = @q.defer()
        @q.all(deferred_get_message).then =>
            @q.all(deferred_process_message).then ->
                # sort before they are published and viewed on the GUI
                new_mail.sort (a, b) ->
                    a.timestamp < b.timestamp
                
                # Update the GUI display with minimal re-work:
                # Adding new_mail to the top is typically already in
                # time-sorted order.
                for m in new_mail
                    mail.unshift m
                    mail_idx[m.id] = m
                new_mail.length = 0
                delete new_mail_idx[el] for el of new_mail_idx
                # re-sort incase older messages poped in
                mail.sort (a, b) ->
                    a.timestamp < b.timestamp
                deferred.resolve()
        deferred.promise
    
angular.module("app").service "MailService", ["MailAPI", "Observer", "$q", "$timeout", MailService]