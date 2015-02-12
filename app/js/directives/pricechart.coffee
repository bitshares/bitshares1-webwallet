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
            valueDecimals: (scope.volumePrecision+"").length - 3
            valueSuffix: ' ' + scope.priceSymbol

        scrollbar:
            enabled: false

        navigator:
            enabled: false

        rangeSelector:
            rangeSelectorZoom :""
            enabled: true
            inputEnabled: false
            allButtonsEnabled: true
            selected: 3
            buttons: [
                type: "minute"
                count: 30
                text: "30m"
            ,
                type: "hour"
                count: 1
                text: "1h"
            ,
                type: "hour"
                count: 6
                text: "6h"
            ,
                type: "day"
                count: 1
                text: "1d"
            ,
                type: "day"
                count: 7
                text: "7d"
            ,
                type: "day"
                count: 14
                text: "14d"
            ,
                type: "day"
                count: 30
                text: "30d"
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
            title: { text: '' }
            labels: 
                align: 'left'
                x: 2
            height: "65%"
        ,
            title: { text: '' }
            color: "#4572A7"
            top: "70%"
            height: "30%"            
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
            tooltip:
                valueSuffix: ' ' + scope.volumeSymbol
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

    template: "<div id=\"pricechart\"></div>"

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

