angular.module("app").filter "prettyDate", (Utils)->
    (date) ->
        if not date
            #console.log "attempting to prettify null date"
            return ""

        if date.valueOf() == "19700101T000000"
            return "Unregistered"

        if angular.isDate(date)
            return date.toLocaleString "en-us"
        else
            return Utils.toDate(date).toLocaleString "en-us"

angular.module("app").filter "prettyRecentDate", (Utils)->
    (date) ->
        if not date
            #console.log "attempting to prettify null date"
            return ""

        if date.valueOf() == "19700101T000000"
            return "Unregistered"

        if not angular.isDate(date)
            date = Utils.toDate(date)
        diff = Date.now() - date

        diff = Math.round(diff/1000)
        if diff < 60
            return diff + " seconds ago"
        else if (diff = Math.round(diff/60)) < 60
            return diff + " minutes ago"
        else if (diff = Math.round(diff/24)) < 24
            return "Today"
        else if diff < 48
            return "Yesterday"
        else
            return date.toLocaleDateString "en-us"

