initChart = (scope) ->

    Highcharts.setOptions
        lang:
            rangeSelectorZoom: ""

    macd_dec = if scope.inverted then 2 else 5
    vol_dec = scope.volumePrecision.toString().length - 3;
    price_dec = if scope.pricePrecision > 9 then (scope.pricePrecision.toString().length - 1) else scope.pricePrecision

    new Highcharts.StockChart
        chart:
            renderTo: "pricechart"
            height: 400
            zoomType: 'x'
            pinchType: 'x'

        credits:
            enabled: false

        title:
            text: null #"Price history "

        xAxis:
            type: "datetime"
            linewidth: 0

        legend:
            enabled: false

        plotOptions:
            candlestick:
                color: "#f01717"
                upColor: "#0ab92b"
            series:
                marker:
                    enabled: false

        tooltip:
            shared: true
            backgroundColor: 'none'
            borderWidth: 0
            shadow: false
            useHTML: true
            padding: 0
            # pointFormat: " O: {point.open:.4f} H: {point.high:.4f} L: {point.low:.4f} C: {point.close:.4f}"
            formatter: () ->
                TA = ""
                if this.points.length == 5
                    TA = "<br> MACD:"+Highcharts.numberFormat(this.points[2].y, price_dec-1,".",",") + " Signal line:"+Highcharts.numberFormat(this.points[4].y, price_dec-1,".",",")
                if (this.points[0].point and this.points[0].point.open) and (this.points[1].point and this.points[1].point.y)
                    return "O: " + Highcharts.numberFormat(this.points[0].point.open, price_dec,".",",") + " H: " + Highcharts.numberFormat(this.points[0].point.high, price_dec,".",",")+ " L: " + Highcharts.numberFormat(this.points[0].point.low, price_dec,".",",") + " C: " + Highcharts.numberFormat(this.points[0].point.close, price_dec,".",",") + " V: " + Highcharts.numberFormat(this.points[1].point.y, vol_dec,".",",")+" "+scope.volumeSymbol+TA
                else if this.points.length == 1 and this.points[0] and this.points[0].point.open
                    return "O: " + Highcharts.numberFormat(this.points[0].point.open, price_dec,".",",") + " H: " + Highcharts.numberFormat(this.points[0].point.high, price_dec,".",",")+ " L: " + Highcharts.numberFormat(this.points[0].point.low, price_dec,".",",") + " C: " + Highcharts.numberFormat(this.points[0].point.close, price_dec,".",",")+TA
                else if this.points.length == 1 and this.points[1] and this.points[1].point.y
                    return "V: " + Highcharts.numberFormat(this.points[1].point.y, vol_dec,".",",")+" "+scope.volumeSymbol+TA
                else
                    return ""
            positioner: () ->
                return { x: 300, y: 5 };
        
            
        ###
            changeDecimals: 4
            valueDecimals: (scope.volumePrecision+"").length - 1
        ###
        scrollbar:
            enabled: false

        navigator:
            enabled: false

        rangeSelector:
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
            ,
                type: "all"
                text: "All"
            ]

        yAxis: [
            title: { text: '' }
            opposite: true
            labels:
                enabled: true 
                align: 'left'
                x: 2
            height: "65%"
            gridLineColor: 'transparent'
        ,
            labels:
                enabled: false 
            title: { text: 'MACD' }
            color: "#4572A7"
            top: "65%"
            height: "20%"            
            offset: 0
            lineWidth: 1
            gridLineColor: 'transparent'
            plotLines: [
                color: '#FF0000'
                width: 1
                value: 0
            ]
        ,
            labels:
                enabled: false 
            title: { text: '' }
            color: "#4572A7"
            top: "85%"
            height: "15%"            
            gridLineColor: 'transparent'
        ]

        series: [
            id: "primary"
            type: 'candlestick'
            name: 'Price'
            data: scope.pricedata
            zIndex: 10
        ,
            type: 'column'
            name: 'Volume'
            data: scope.volumedata
            yAxis: 2
            zIndex: 9
        ,
            name: "MACD"
            linkedTo: 'primary'
            showInLegend: true
            type: 'trendline'
            algorithm: 'MACD'
            zIndex: 7
            yAxis: 1
        ,
            name : 'Signal line',
            linkedTo: 'primary',
            yAxis: 1,
            showInLegend: true,
            type: 'trendline',
            algorithm: 'signalLine'
        ,
            name: 'Histogram',
            linkedTo: 'primary',
            yAxis: 1,
            showInLegend: true,
            type: 'histogram'
            zIndex: 8
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
        pricePrecision: "="
        priceSymbol: "="
        inverted: "="

    controller: ($scope, $element, $attrs) ->
        #console.log "pricechart controller"

    template: "<div id=\"pricechart\"></div>"

    chart: null

    link: (scope, element, attrs) ->
        chart = null
        if not chart
            chart = initChart(scope)
        scope.$watch "pricedata", (newValue) =>
            if newValue and not chart
                chart = initChart(scope)
            else if chart
                chart.series[0].setData scope.pricedata, true
                chart.series[1].setData scope.volumedata, true

        ### Two watches uses a lot of overhead, only one needed
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
        ###

