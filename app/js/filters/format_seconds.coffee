angular.module("app").filter "formatSecond", ()->
    (seconds) ->
        min = 60
        hour = 60
        day = 24

        s = seconds % min
        minutes = (seconds - s)/min
        m = minutes % hour
        hours = (minutes - m)/hour
        h = hours % day
        days = (hours - h)/day

        result = "" + (if days then (days + "d ") else "")
        result = result + (if h then (h + "h ") else "")
        result = result + (if m then (m + "m ") else "")
        result = result + (s + "s")
        result
