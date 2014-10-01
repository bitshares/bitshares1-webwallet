utils = null

initChart = (scope) ->

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "shortscollatchart"
            height: 200

        title:
            text: null

        credits:
            enabled: false

        legend:
            verticalAlign: "top"

        tooltip:
            formatter: ->
                "Collateral Ratio #{utils.formatDecimal(@x,scope.pricePrecision,true)} #{scope.priceSymbol}<br/>Volume #{utils.formatDecimal(@y,scope.volumePrecision,true)} #{scope.volumeSymbol}"

        xAxis:
            title:
                text: "Collateral Ratio " + scope.priceSymbol

        yAxis:
            title:
                text: "Volume " + scope.volumeSymbol

        series: [
            name: "Shorts Collateralization"
            data: scope.shortscollatArray
            color: "#7cb5ec"
            lineWidth: 1
        ]

        plotOptions:
            area:
                marker:
                    enabled: false

addPlotLine = (chart, value, inverted) ->
    price = if inverted then value else 1.0/value
    chart.xAxis[0].addPlotLine
        id: "shorts_price"
        color: "#555"
        dashStyle: "longdashdot"
        value: price
        width: 1
        label: {text: 'Price Feed'}
        zIndex: 5

removePlotLine = (chart) ->
    chart.xAxis[0].removePlotLine "shorts_price"


angular.module("app.directives").directive "shortscollatchart", ->
    restrict: "E"
    replace: true
    scope:
        shortscollatArray: "="
        volumeSymbol: "="
        volumePrecision: "="
        priceSymbol: "="
        pricePrecision: "="
        invertedMarket: "="
        shortsPrice: "="

    controller: ($scope, $element, $attrs, Utils) ->
        utils = Utils

    template: '''<div id="shortscollatchart" class="shortscollatchart" style="margin: 0 auto"></div>'''

    chart: null

    link: (scope, element, attrs) ->

        chart = null

        scope.$watch "shortscollatArray", (value) =>
            if value and not chart
                chart = initChart(scope)
                addPlotLine(chart, scope.shortsPrice, scope.invertedMarket)
            else if chart
                chart.series[0].setData value, true
        , true

        scope.$watch "shortsPrice", (value) =>
            return unless chart
            removePlotLine(chart)
            addPlotLine(chart, value, scope.invertedMarket)
