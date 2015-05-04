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
            height: scope.height
            pinchType: "x"
            dataGrouping: 
                enabled: false

        credits:
            enabled: false

        title:
            text: null #"Price history "

        xAxis:
            type: "datetime"
            lineWidth: 0
            minRange: 60 * 1000 # one minute
            events:
                afterSetExtremes: scope.afterSetExtremes

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
                time = new Date(this.x) + "<br>"
                TA = ""
                if this.points.length == 0
                    return ""
                if this.points.length == 5
                    TA = "<br> MACD:"+Highcharts.numberFormat(this.points[2].y, price_dec-1,".",",") + "  Signal line:"+Highcharts.numberFormat(this.points[4].y, price_dec-1,".",",")
                if (this.points[0].point and this.points[0].point.open) and (this.points[1].point and this.points[1].point.y)
                    return time + "O:" + Highcharts.numberFormat(this.points[0].point.open, price_dec,".",",") + "  H:" + Highcharts.numberFormat(this.points[0].point.high, price_dec,".",",")+ "  L:" + Highcharts.numberFormat(this.points[0].point.low, price_dec,".",",") + "  C:" + Highcharts.numberFormat(this.points[0].point.close, price_dec,".",",") + "  V:" + Highcharts.numberFormat(this.points[1].point.y, vol_dec,".",",")+" "+scope.volumeSymbol+TA
                else if this.points.length == 1 and this.points[0] and this.points[0].point.open
                    return time + "O:" + Highcharts.numberFormat(this.points[0].point.open, price_dec,".",",") + "  H:" + Highcharts.numberFormat(this.points[0].point.high, price_dec,".",",")+ "  L:" + Highcharts.numberFormat(this.points[0].point.low, price_dec,".",",") + "  C:" + Highcharts.numberFormat(this.points[0].point.close, price_dec,".",",")+TA
                else if this.points.length == 1 and this.points[1] and this.points[1].point.y
                    return time + "V:" + Highcharts.numberFormat(this.points[1].point.y, vol_dec,".",",")+" "+scope.volumeSymbol+TA
                else
                    return ""
            positioner: () ->
                return { x: 5, y: -5 };
        
            
        ###
            changeDecimals: 4
            valueDecimals: (scope.volumePrecision+"").length - 1
        ###
        scrollbar:
            enabled: false

        navigator:
            enabled: true

        rangeSelector:
            enabled: false
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
            height: "80%"
            gridLineColor: 'transparent'
        ,
            labels:
                enabled: true 
            opposite: false
            title: { text: '' }
            color: "#4572A7"
            height: "80%"           
            gridLineColor: 'transparent'
        ,
            labels:
                enabled: false 
            title: { text: 'MACD' }
            color: "#4572A7"
            top: "80%"
            height: "20%"            
            offset: 0
            lineWidth: 1
            gridLineColor: 'transparent'
            plotLines: [
                color: '#FF0000'
                width: 1
                value: 0
            ]
        ]

        series: [
            id: "primary"
            type: 'candlestick'
            name: 'Price'
            data: scope.pricedata
            zIndex: 10
            dataGrouping:
                enabled: false
        ,
            type: 'column'
            name: 'Volume'
            data: scope.volumedata
            yAxis: 1
            opposite: false
            zIndex: 9
            dataGrouping:
                enabled: false
        ,
            name: "MACD"
            linkedTo: 'primary'
            showInLegend: true
            type: 'trendline'
            algorithm: 'MACD'
            zIndex: 7
            yAxis: 2
        ,
            name : 'Signal line',
            linkedTo: 'primary',
            yAxis: 2,
            showInLegend: true,
            type: 'trendline',
            algorithm: 'signalLine'
        ,
            name: 'Histogram',
            linkedTo: 'primary',
            yAxis: 2,
            showInLegend: true,
            type: 'histogram'
            zIndex: 8
        ]

angular.module("app.directives").directive "pricechart", ($window)->
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
        interval: "="
    template: "<div id=\"pricechart\"></div>"

    link: (scope, element, attrs) ->
        chart = null
        initialZoom = true
        intervalChange = false
        interval = 1800

        scope.afterSetExtremes = (e) ->
            # On first draw or interval change, reset to min/max to a reasonable value
            if (e.trigger == "updatedData") and (initialZoom or intervalChange)
                newMin = @.dataMin + (@.dataMax - @.dataMin) * 2 / 3
                initialZoom = false
                intervalChange = false
                chart.xAxis[0].setExtremes(newMin, @.max)

        # Set the height of the graph depending on the vertical resolution
        scope.height = 500
        if $window.screen.height <= 800
            scope.height = 300
        else if $window.screen.height <= 1080
            scope.height = 400

        if not chart
            chart = initChart(scope)

        scope.$watch "pricedata", (newValue) =>
            if newValue and not chart
                chart = initChart(scope)
                interval = scope.interval
            else if chart
                # Check whether the interval size changed
                if interval != scope.interval
                    intervalChange = true
                interval = scope.interval
                # Updathe series
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

