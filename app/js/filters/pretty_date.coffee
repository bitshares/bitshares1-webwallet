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
        return "" if not date
            #console.log "attempting to prettify null date"
        return "Unregistered" if date.valueOf() == "19700101T000000"
        if not angular.isDate(date)
            date = Utils.toDate(date)
        diff = (Date.now() - date) / 1000.0
        return date.toLocaleDateString "en-us" if diff > 48*3600
        if diff < 60
            diff + "#{Math.round(diff)} seconds ago"
        else if diff < 3600
            diff + "#{Math.round(diff/60.0)} minutes ago"
        else if diff < 12*3600
            diff + "#{Math.round(diff/3600.0)} hours ago"
        else if diff < 24*3600
            "Today"
        else "Yesterday"


angular.module("app").filter "hoursAgo", (Utils)->
    (date) ->
        if not date
            #console.log "attempting to prettify null date"
            return ""

        if not angular.isDate(date)
            date = Utils.toDate(date)
        diff = Date.now() - date

        diff = Math.round(diff/1000/3600)
        return diff

angular.module("app").filter "secondsAgo", (Utils)->
  (date) ->
    if not date
      #console.log "attempting to prettify null date"
      return "9999999999999"

    if date.valueOf() == "19700101T000000"
      return "9999999999999"

    if not angular.isDate(date)
      date = Utils.toDate(date)
    diff = Date.now() - date

    Math.round(diff/1000)
