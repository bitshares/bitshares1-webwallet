angular.module("app").filter "reverse", ->
  (items) ->
    if not items
        return items
    items.slice().reverse()
