initChart = (scope) ->

    new Highcharts.StockChart
        chart:
            renderTo: "pricechart"
            height: 300

        credits:
            enabled: false

        title:
            text: null #"Price history "

        xAxis:
            type: "datetime"

        legend:
            enabled: false

        plotOptions:
            candlestick:
                color: "#f01717"
                upColor: "#0ab92b"

        tooltip:
            xDateFormat: "%m/%d/%Y %H:%M%p"
            #color: "#f0f"
            changeDecimals: 4
            #borderColor: "#058dc7"
            valueDecimals: (scope.volumePrecision+"").length - 1

        scrollbar:
            enabled: false

        navigator:
            enabled: true

        rangeSelector:
            enabled: true
            inputEnabled: true
            allButtonsEnabled: true
            #selected: 1
            buttons: [
                type: "hour"
                count: 1
                text: "Hour"
            ,
                type: "day"
                count: 1
                text: "Day"
            ,
                type: "week"
                count: 1
                text: "Week"
            ,
                type: "month"
                count: 1
                text: "Month"
#            ,
#                type: "ytd"
#                text: "YTD"
#            ,
#                type: "year"
#                count: 1
#                text: "Year"
#            ,
#                type: "all"
#                text: "All"
            ]

        yAxis: [
            title: { text: 'Price ' + scope.priceSymbol }
            opposite: false
        ,
            title: { text: 'Volume ' + scope.volumeSymbol }
            color: "#4572A7"
            opposite: true
            height: "50%"
            top: "50%"
        ]

        series: [
            type: 'candlestick'
            name: 'Price'
            data: scope.pricedata
            zIndex: 10
        ,
            type: 'column'
            name: 'Volume'
            data: scope.volumedata
            yAxis: 1
            zIndex: 9
        ]

angular.module("app.directives").directive "pricechart", ->
    restrict: "E"
    replace: true
    scope:
        pricedata: "="
        volumedata: "="
        marketName: "="
        volumeSymbol: "="
        volumePrecision: "="
        priceSymbol: "="

    controller: ($scope, $element, $attrs) ->
        #console.log "pricechart controller"

    template: "<div id=\"pricechart\" style=\"margin: 0 auto\"></div>"

    chart: null

    link: (scope, element, attrs) ->
        chart = null

        scope.$watch "pricedata", (newValue) =>
            if newValue and not chart
                chart = initChart(scope)
            else if chart
                chart.series[0].setData newValue, true
        , true

        scope.$watch "volumedata", (newValue) =>
            return unless chart
            chart.series[1].setData newValue, true
        , true

