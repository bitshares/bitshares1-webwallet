initChart = (scope) ->
    console.log "------ init chart ------>", scope.shortsColor

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "orderbookchart"
            height: 200

        title:
            text: null

        xAxis:
            title: "Price " + scope.priceSymbol

#            plotBands: [
#                color: "orange" # Color value
#                from: "26" # Start of the plot band
#                to: "30" # End of the plot band
#            ]

            plotLines: [
                color: "#555"
                dashStyle: "longdashdot"
                value: scope.avgprice1h
                width: "1"
                label: {text: '1h Avg. Price'}
            ]

        yAxis:
            title: ""

        series: [
            name: "Buy " + scope.volumeSymbol
            data: scope.buys
            color: "#2ca02c"
        ,
            name: "Sell " + scope.volumeSymbol
            data: scope.sells
            color: "#ff7f0e"
        ,
            name: "Short " + scope.volumeSymbol
            data: scope.shorts
            color: scope.shortsColor
        ]

        plotOptions:
            area:
                marker:
                    enabled: false

angular.module("app.directives").directive "orderbookchart", ->
    restrict: "E"
    replace: true
    scope:
        buys: "="
        sells: "="
        shorts: "="
        shortsColor: "="
        volumeSymbol: "="
        priceSymbol: "="
        avgprice1h: "="

    controller: ($scope, $element, $attrs) ->
        #console.log "orderbookchart controller"

    template: "<div id=\"orderbookchart\" style=\"margin: 0 auto\"></div>"

    chart: null

    link: (scope, element, attrs) ->
        chart = null

        scope.$watch "buys", (newValue) =>
            if newValue and not chart
                chart = initChart(scope)
            #else if chart
                #chart.series[0].setData newValue, true
        , true

        scope.$watch "sells", (newValue) =>
            return unless chart
            #console.log "------ sellorders ------>", newValue
            #chart.series[1].setData newValue, true
        , true

        scope.$watch "shorts", (newValue) =>
            return unless chart
            #console.log "------ shortorders ------>", newValue
            #chart.series[2].setData newValue, true
        , true

