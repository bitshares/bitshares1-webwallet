utils = null

initChart = (scope) ->

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "orderbookchart"
            height: 350 #if scope.advancedMode then 200 else 350

        title:
            text: null

        credits:
            enabled: false

        legend:
            verticalAlign: "top"

        tooltip:
            formatter: ->
                "<b>#{@series.name}</b><br/>Price #{utils.formatDecimal(@x,scope.pricePrecision,true)} #{scope.priceSymbol}<br/>Volume #{utils.formatDecimal(@y,scope.volumePrecision,true)} #{scope.volumeSymbol}"

        xAxis:
            title:
                text: "Price " + scope.priceSymbol

        yAxis:
            title:
                text: "Volume " + scope.volumeSymbol

        series: [
            name: "Buy " + scope.volumeSymbol
            data: scope.bidsArray
            color: "#2ca02c"
            lineWidth: 1
        ,
            name: "Sell " + scope.volumeSymbol
            data: scope.asksArray
            color: "#ff7f0e"
            lineWidth: 1
        ]

        plotOptions:
            area:
                marker:
                    enabled: false

addPlotLine = (chart, value) ->
    chart.xAxis[0].addPlotLine
        id: "feed_price"
        color: "#555"
        dashStyle: "longdashdot"
        value: value
        width: 1
        label: {text: 'Price Feed'}
        zIndex: 5

removePlotLine = (chart) ->
    chart.xAxis[0].removePlotLine "feed_price"

angular.module("app.directives").directive "orderbookchart", ->
    restrict: "E"
    replace: true
    scope:
        bidsArray: "="
        asksArray: "="
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

        scope.$watch "bidsArray", (value) =>
            if value and not chart
                chart = initChart(scope)
                addPlotLine(chart, scope.feedPrice)
            else if chart
                chart.series[0].setData value, true
        , true

        scope.$watch "asksArray", (value) =>
            if chart
                chart.series[1].setData value, true
        , true

        scope.$watch "feedPrice", (value) =>
            return unless chart
            removePlotLine(chart)
            addPlotLine(chart, value)
