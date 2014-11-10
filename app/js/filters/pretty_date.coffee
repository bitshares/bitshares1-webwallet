date_params = {timeZone:"UTC",  weekday: undefined, year: "numeric", month: "numeric",  day: "numeric", hour: "numeric", minute: "numeric"}

angular.module("app").filter "prettyDate", (Utils)->
    (date) ->
        return "-" if !date or date.valueOf() == "19700101T000000"
        if angular.isDate(date)
            return moment(date).format('L LT')
        else
            return moment(Utils.toDate(date)).format('L LT')

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

angular.module("app").filter "formatExpiration", (Utils)->
  (value) -> value.days
