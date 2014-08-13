angular.module("app").filter "reverse", ->
  (items) ->
    if not items
        return items
    items.slice().reverse()


#angular.module("app").filter "orderInReverseBy", ->
#    (input, attribute) ->
#        return unless input
#        console.log "------ orderInReverseBy ------>", input, attribute
#        input.sort (a, b) ->
#            a = a[attribute]
#            b = b[attribute]
#            b - a
