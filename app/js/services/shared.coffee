servicesModule = angular.module("app.services")

servicesModule.factory "Shared", ->
    contactName: null
    message: ""
    errors:
        list: []
        new_error: false
        num_errors: 0
    addError: (text, stack, toolkit_error) ->
        match = /Assert Exception [\s\S.]+: ([\s\S.]+)/mi.exec(text)
        text = if !match or match.length < 2 then text else match[1]
        @errors.new_error = true
        if @errors.list.length > 0
            first_error = @errors.list[0]
            if first_error.text == text
                ++first_error.counter
                first_error.time = (new Date()).toLocaleString()
                return
        ++@errors.num_errors
        @errors.list.unshift
            text: text
            time: (new Date()).toLocaleString()
            stack: stack
            counter: 1
            toolkit_error: toolkit_error
        window.ttt = stack
        @errors.list.splice(-1) if @errors.list.length > 16
