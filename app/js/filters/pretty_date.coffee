angular.module("app").filter "prettyDate", (Utils)->
    (date) ->
        if not date
            console.log "attempting to prettify null date"
            return ""

        if date.valueOf() == "19700101T000000"
            return "Not registered"

        angular.isDate(date)
            return date.toLocaleString "en-us"
        else
            return Utils.toDate(date).toLocaleString "en-us"
