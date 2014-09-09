# usage example:
#    observer1 =
#        name: "test1"
#        data:
#            field1: 0
#            field2: 0
#        frequency: 2000
#        update: (data, deferred) ->
#            field1 = Math.floor(Math.random() * 2) + 1
#            field2 = Math.floor(Math.random() * 2) + 1
#            changed = false
#            if data.field1 != field1
#                data.field1 = field1
#                changed = true
#            if data.field2 != field2
#                data.field2 = field2
#                changed = true
#            deferred.resolve(changed)
#        notify: (data) ->
#            console.log "test1 updated data: ", data
#            Observer.unregisterObserver(@) if observer1.counter > 10

class Observer

    private:
        observers: {}
        each_block_observers: {}
        update: (observer, q) ->
            return if observer.busy
            observer.busy = true
            deferred = q.defer()
            observer.update(observer.data, deferred)
            deferred.promise.then (data_changed) ->
                if observer.notify and data_changed
                    observer.notify(observer.data)
            deferred.promise.finally ->
                observer.counter += 1
                observer.busy = false


    constructor: (@q, @log, @interval, @info, @root_scope) ->
        info = @info
        @root_scope.$watch (-> info.info.last_block_time), @on_new_block, true

    on_new_block: =>
        for index, observer of @private.each_block_observers
            @private.update(observer, @q)

    registerObserver: (observer) ->
        if @private.observers[observer.name]
            @log.error("Observer.registerObserver: observer '#{observer.name}' is already registered")
            return
        @private.observers[observer.name] = observer
        observer.counter = 0
        @private.update(observer, @q)
        if  observer.frequency == "each_block"
            @private.each_block_observers[observer.name] = observer
        else
            observer.interval_promise = @interval (=>
                @private.update(observer, @q)
            ), observer.frequency

    unregisterObserver: (observer) ->
        unless @private.observers[observer.name]
            @log.error("Observer.unregisterObserver: cannot find '#{observer.name}' observer")
            return
        @interval.cancel(observer.interval_promise)
        delete @private.observers[observer.name]
        delete @private.each_block_observers[observer.name]

angular.module("app").service("Observer", ["$q", "$log", "$interval", "Info", "$rootScope", Observer])
