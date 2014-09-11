angular.module("app.directives").directive "pricechart", ->
    restrict: "E"
    replace: true
    scope:
        pricedata: "="
        volumedata: "="

    controller: ($scope, $element, $attrs) ->
        console.log "pricechart controller"

    template: "<div id=\"pricechart\" style=\"margin: 0 auto\"></div>"
    link: (scope, element, attrs) ->
        console.log 3
        chart = new Highcharts.StockChart
            chart:
                renderTo: "pricechart"
                alignTicks: false

            title:
                text: "Price history"

            yAxis: [
                title: { text: 'OHLC' }
#                height: 200
#                lineWidth: 2
            ,
                title: { text: 'Volume' }
#                top: 300
#                height: 100
#                offset: 0
#                lineWidth: 2
            ]

            series: [
                type: 'candlestick'
                name: 'Price'
                data: scope.pricedata
            ,
                type: 'column'
                name: 'Volume'
                data: scope.volumedata
                yAxis: 1
            ]

        scope.$watch "pricedata", (newValue) ->
            chart.series[0].setData newValue, true
        , true

        scope.$watch "volumedata", (newValue) ->
            chart.series[1].setData newValue, true
        , true

