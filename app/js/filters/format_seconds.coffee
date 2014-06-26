angular.module("app").filter "formatSecond", ()->
    (seconds) ->
        s = seconds % 60
        minutes = (seconds - s) / 60
        m = minutes % 60
        hours = (minutes - m) / 60
        h = hours % 24
        days = (hours - h) / 24

        result = "" + (if days then (days + "d ") else "")
        result = result + (if h then (h + "h ") else "")
        result = result + (if m then (m + "m ") else "")
        result = result + (s + "s")
        result
