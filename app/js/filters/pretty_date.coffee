angular.module("app").filter "prettyDate", (Utils)->
    (date) ->
        if not date
            console.log "attempting to prettify null date"
            return ""

        if Utils.type(date) == "date" then date.toLocaleString "en-us" else Utils.toDate(date).toLocaleString "en-us"
