initChart = (scope) ->
    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "orderbookchart"
            height: 200

        title:
            text: null

        series: [
            name: "Buy " + scope.volumeSymbol
            data: scope.buyorders
            color: "#2ca02c"
        ,
            name: "Sell " + scope.volumeSymbol
            data: scope.sellorders
            color: "#ff7f0e"
        ]

angular.module("app.directives").directive "orderbookchart", ->
    restrict: "E"
    replace: true
    scope:
        buyorders: "="
        sellorders: "="
        volumeSymbol: "="
        priceSymbol: "="

    controller: ($scope, $element, $attrs) ->
        #console.log "orderbookchart controller"

    template: "<div id=\"orderbookchart\" style=\"margin: 0 auto\"></div>"

    chart: null

    link: (scope, element, attrs) ->
        chart = null

        scope.$watch "buyorders", (newValue) =>
            if newValue and not chart
                chart = initChart(scope)
            else if chart
                chart.series[0].setData newValue, true
        , true

        scope.$watch "sellorders", (newValue) =>
            return unless chart
            chart.series[1].setData newValue, true
        , true

