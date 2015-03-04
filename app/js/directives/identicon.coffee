angular.module("app.directives").directive "identicon", () ->
    restrict: 'E'
    replace: true
    scope:
        'account': '@'
        'empty': '@'
        'size': '@'
    template:
        '''<canvas style="width:{{size}}px;height:{{size}}px;" class="identicon" height="{{2*size}}" width="{{2*size}}"></canvas>'''
    link: (scope, element, attrs) ->
        draw_circle = (context, x, y, radius) ->
            context.beginPath()
            context.arc x, y, radius, 0, 2 * Math.PI, false
            context.fillStyle = "rgba(0, 0, 0, 0.1)"
            context.fill()
        scope.$watch "account", (value) ->
            if value
                element.jdenticon(sha256(value))
            else
                size = scope.size * 2
                canvas = element.get(0)
                context = canvas.getContext('2d')
                centerX = size / 2
                centerY = size / 2
                radius = 20
                context.clearRect(0, 0, size, size)
                draw_circle(context, centerX, centerY, radius)
                draw_circle(context, 2*radius, 2*radius, radius)
                draw_circle(context, centerX, 2*radius, radius)
                draw_circle(context, size - 2*radius, 2*radius, radius)
                draw_circle(context, size - 2*radius, centerY, radius)
                draw_circle(context, size - 2*radius, size - 2*radius, radius)
                draw_circle(context, centerX, size - 2*radius, radius)
                draw_circle(context, 2*radius, size - 2*radius, radius)
                draw_circle(context, 2*radius, centerY, radius)
