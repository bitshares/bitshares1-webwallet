utils = null

initChart = (scope) ->

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "orderbookchart"
            height: scope.height #if scope.advancedMode then 200 else 350

        title:
            text: null

        credits:
            enabled: false

        legend:
            enabled: false
            verticalAlign: "top"

        tooltip:
            formatter: ->
                "<b>#{@series.name}</b><br/>Price #{utils.formatDecimal(@x,scope.pricePrecision,true)} #{scope.priceSymbol}<br/>Volume #{utils.formatDecimal(@y,scope.volumePrecision,true)} #{scope.volumeSymbol}"

        xAxis:
            title:
                enabled: false
                text: "Price " + scope.priceSymbol

        yAxis:
            opposite: false
            title:
                text: ""
            gridLineColor: 'transparent'


        series: [
            name: "Buy " + scope.volumeSymbol
            data: scope.bidsArray
            color: "#28a92e"
            lineWidth: 1
        ,
            name: "Sell " + scope.volumeSymbol
            data: scope.asksArray
            color: "#c90808"
            lineWidth: 1
        ]

        plotOptions:
            area:
                marker:
                    enabled: false
            series:
                fillOpacity: 0.25

addPlotLine = (chart, value) ->
    return unless value
    chart.xAxis[0].addPlotLine
        id: "feed_price"
        color: "#555"
        dashStyle: "longdashdot"
        value: value
        width: 1
        label: {text: 'Call Price'}
        zIndex: 5

removePlotLine = (chart) ->
    chart.xAxis[0].removePlotLine "feed_price"

angular.module("app.directives").directive "orderbookchart", ($window) ->
    restrict: "E"
    replace: true
    scope:
        bidsArray: "="
        asksArray: "="
        avgValue: "="
        volumeSymbol: "="
        volumePrecision: "="
        priceSymbol: "="
        pricePrecision: "="
        invertedMarket: "="
        feedPrice: "="
        advancedMode: "="

    controller: ($scope, $element, $attrs, Utils) ->
        utils = Utils

    template: '''<div id="orderbookchart" class="orderbookchart" style="margin: 0 auto"></div>'''

    chart: null

    link: (scope) ->

        chart = null

        # Set the height of the graph depending on the vertical resolution
        scope.height = 500
        if $window.screen.height <= 800
            scope.height = 300
        else if $window.screen.height <= 1080
            scope.height = 400

        scope.$watch "bidsArray", (value) =>
            if value and not chart
                chart = initChart(scope)
                addPlotLine(chart, scope.feedPrice)
            else if chart
                chart.series[0].setData value, true
            
            if scope.feedPrice == 0 and scope.avgValue
                chart.xAxis[0].setExtremes(0.4 * scope.avgValue, 1.6*scope.avgValue, false)
        , true

        scope.$watch "asksArray", (value) =>
            if chart
                chart.series[1].setData value, true
        , true

        scope.$watch "feedPrice", (value) =>
            return unless chart
            removePlotLine(chart)
            addPlotLine(chart, value)
