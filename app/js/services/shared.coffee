servicesModule = angular.module("app.services")

servicesModule.factory "Shared", ->
    contactName: null
    message: ""
    errors:
        list: []
        new_error: false
        num_errors: 0
    addError: (text, stack) ->
        ++@errors.num_errors
        @errors.new_error = true
        if @errors.list.length > 0
            first_error = @errors.list[0]
            if first_error.text == text and first_error.stack == stack
                first_error.counter
                return
        @errors.list.unshift {text: text, time: (new Date()).toLocaleString(), stack: stack, counter: 1}
        @errors.list.splice(-1) if @errors.list.length > 16
