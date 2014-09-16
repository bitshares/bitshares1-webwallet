utils = null

initChart = (scope) ->

    [shorts_range_begin, shorts_range_end] = scope.shortsRange.split("-")

    new Highcharts.Chart
        chart:
            type: "area"
            renderTo: "orderbookchart"
            height: 200

        title:
            text: null

        legend:
            verticalAlign: "top"
            #align: "right"

        tooltip:
            formatter: ->
                "<b>#{@series.name}</b><br/>Price #{utils.formatDecimal(@x,scope.pricePrecision,true)} #{scope.priceSymbol}<br/>Volume #{utils.formatDecimal(@y,scope.volumePrecision,true)} #{scope.volumeSymbol}"


        xAxis:
            title: "Price " + scope.priceSymbol

            plotLines: [
                color: "#555"
                dashStyle: "longdashdot"
                value: scope.avgprice1h
                width: "1"
                label: {text: '1h Avg. Price'}
                zIndex: 5
            ,
                color: "red"
                dashStyle: "longdashdot"
                value: scope.maxshortprice
                width: "1"
                label: {text: 'Shorts Limit'}
                zIndex: 5
            ]

            plotBands: [
                color: "#eee"
                from: shorts_range_begin
                to: shorts_range_end
                label:
                    text: "Shorts Range"
                    #align: "right"
                #zIndex: 10
            ]

        yAxis:
            title: ""

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
        ,
            name: "Short " + scope.volumeSymbol
            data: scope.shortsArray
            color: if scope.invertedMarket then "#de6e0b" else "#278c27"
            lineWidth: 1
        ,
            name: "Short Demand"
            data: scope.shortsDemandArray
            color: "#ffff99"
            lineWidth: 1
        ]

        plotOptions:
            area:
                marker:
                    enabled: false

angular.module("app.directives").directive "orderbookchart", ->
    restrict: "E"
    replace: true
    scope:
        bidsArray: "="
        asksArray: "="
        shortsArray: "="
        shortsDemandArray: "="
        shortsRange: "="
        volumeSymbol: "="
        volumePrecision: "="
        priceSymbol: "="
        pricePrecision: "="
        invertedMarket: "="
        avgprice1h: "="

    controller: ($scope, $element, $attrs, Utils) ->
        #console.log "orderbookchart controller"
        utils = Utils

    template: "<div id=\"orderbookchart\" style=\"margin: 0 auto\"></div>"

    chart: null

    link: (scope, element, attrs) ->

        chart = null

        scope.$watch "bidsArray", (value) =>
            if value and not chart
                chart = initChart(scope)
            else if chart
                chart.series[0].setData value, true
        , true

        scope.$watch "asksArray", (value) =>
            return unless chart
            chart.series[1].setData value, true
        , true

        scope.$watch "shortsArray", (value) =>
            return unless chart
            chart.series[2].setData value, true
        , true

        scope.$watch "shortsDemandArray", (value) =>
            return unless chart
            chart.series[3].setData value, true
        , true

