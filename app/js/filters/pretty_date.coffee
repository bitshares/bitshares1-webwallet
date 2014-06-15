angular.module("app").filter "prettyDate", (Utils)->
    (date) ->
        if not date
            console.log "attempting to prettify null date"
            return ""
        console.log date
        Utils.toDate(date).toLocaleString "en-us"
