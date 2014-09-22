utils = null

initChart = (scope) ->

    #[shorts_range_begin, shorts_range_end] = scope.shortsRange.split("-")

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "shortscollatchart"
            height: 200

        title:
            text: null

        legend:
            verticalAlign: "top"
            #align: "right"

        tooltip:
            formatter: ->
                "Price #{utils.formatDecimal(@x,scope.pricePrecision,true)} #{scope.priceSymbol}<br/>Volume #{utils.formatDecimal(@y,scope.volumePrecision,true)} #{scope.volumeSymbol}"


        xAxis:
            title: "Price " + scope.priceSymbol
            #reversed: true

        yAxis:
            title: ""

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

addPlotLine = (chart, value) ->
    chart.xAxis[0].addPlotLine
        id: "shorts_price"
        color: "#555"
        dashStyle: "longdashdot"
        value: value
        width: 1
        label: {text: 'Feed Price'}
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
        #console.log "orderbookchart controller"
        utils = Utils

    template: "<div id=\"shortscollatchart\" style=\"margin: 0 auto\"></div>"

    chart: null

    link: (scope, element, attrs) ->

        chart = null

        scope.$watch "shortscollatArray", (value) =>
            if value and not chart
                chart = initChart(scope)
                addPlotLine(chart, scope.shortsPrice)
            else if chart
                chart.series[0].setData value, true
        , true

        scope.$watch "shortsPrice", (value) =>
            return unless chart
            removePlotLine(chart)
            addPlotLine(chart, value)
