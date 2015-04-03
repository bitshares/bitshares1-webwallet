initChart = (scope, svg) ->

    dim = 
        width: parseInt(d3.select('#pricechart-container').style('width'), 10), height: 500,
        margin: { top: 20, right: 50, bottom: 30, left: 50 },
        ohlc: { height: 305 },
        indicator: { height: 65, padding: 5 }
    
    dim.plot = 
        width: dim.width - dim.margin.left - dim.margin.right,
        height: dim.height - dim.margin.top - dim.margin.bottom
    
    dim.indicator.top = dim.ohlc.height+dim.indicator.padding
    dim.indicator.bottom = dim.indicator.top+dim.indicator.height+dim.indicator.padding

    indicatorTop = d3.scale.linear()
            .range([dim.indicator.top, dim.indicator.bottom])

    # resizing for responsive chart
    resize = () ->
        console.log "being resized"
        # update width
        dim.width = parseInt(d3.select('#pricechart-container').style('width'), 10)

        # reset x range
        x.range([0, dim.width]);
        draw
        # do the actual resize...

    d3.select(window).on('resize', resize); 
    

    draw = () ->
        zoomPercent.translate(zoom.translate())
        zoomPercent.scale(zoom.scale())

        svg.select("g.x.axis").call(xAxis)
        svg.select("g.ohlc .axis").call(yAxis)
        svg.select("g.volume.axis").call(volumeAxis)
        svg.select("g.percent.axis").call(percentAxis)
        svg.select("g.macd .axis.right").call(macdAxis)
        svg.select("g.rsi .axis.right").call(rsiAxis)
        svg.select("g.macd .axis.left").call(macdAxisLeft)
        svg.select("g.rsi .axis.left").call(rsiAxisLeft)

        # We know the data does not change, a simple refresh that does not perform data joins will suffice.
        svg.select("g.candlestick").call(candlestick.refresh)
        svg.select("g.close.annotation").call(closeAnnotation.refresh)
        svg.select("g.volume").call(volume.refresh)
        svg.select("g .sma.ma-0").call(sma0.refresh)
        svg.select("g .sma.ma-1").call(sma1.refresh)
        svg.select("g .ema.ma-2").call(ema2.refresh)
        svg.select("g.macd .indicator-plot").call(macd.refresh)
        svg.select("g.rsi .indicator-plot").call(rsi.refresh)
        svg.select("g.crosshair.ohlc").call(ohlcCrosshair.refresh)
        svg.select("g.crosshair.macd").call(macdCrosshair.refresh)
        svg.select("g.crosshair.rsi").call(rsiCrosshair.refresh)
        # svg.select("g.trendlines").call(trendline.refresh)
        # svg.select("g.supstances").call(supstance.refresh)

    parseDate = d3.time.format("%d-%b-%y").parse

    zoom = d3.behavior.zoom()
            .on("zoom", draw)

    zoomPercent = d3.behavior.zoom()

    x = techan.scale.financetime()
            .range([0, dim.plot.width])

    y = d3.scale.linear()
            .range([dim.ohlc.height, 0])

    yPercent = y.copy()   # Same as y at this stage, will get a different domain later

    yVolume = d3.scale.linear()
            .range([y(0), y(0.2)])

    candlestick = techan.plot.candlestick()
            .xScale(x)
            .yScale(y)

    sma0 = techan.plot.sma()
            .xScale(x)
            .yScale(y)

    sma1 = techan.plot.sma()
            .xScale(x)
            .yScale(y)

    ema2 = techan.plot.ema()
            .xScale(x)
            .yScale(y)

    volume = techan.plot.volume()
            .accessor(candlestick.accessor())   # Set the accessor to a ohlc accessor so we get highlighted bars
            .xScale(x)
            .yScale(yVolume)

    trendline = techan.plot.trendline()
            .xScale(x)
            .yScale(y)

    supstance = techan.plot.supstance()
            .xScale(x)
            .yScale(y)

    xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")

    timeAnnotation = techan.plot.axisannotation()
            .axis(xAxis)
            .format(d3.time.format('%Y-%m-%d'))
            .width(65)
            .translate([0, dim.plot.height])

    yAxis = d3.svg.axis()
            .scale(y)
            .orient("right")

    ohlcAnnotation = techan.plot.axisannotation()
            .axis(yAxis)
            .format(d3.format(',.2fs'))
            .translate([x(1), 0])

    closeAnnotation = techan.plot.axisannotation()
            .axis(yAxis)
            .accessor(candlestick.accessor())
            .format(d3.format(',.2fs'))
            .translate([x(1), 0])

    percentAxis = d3.svg.axis()
            .scale(yPercent)
            .orient("left")
            .tickFormat(d3.format('+.1%'))

    percentAnnotation = techan.plot.axisannotation()
            .axis(percentAxis)

    volumeAxis = d3.svg.axis()
            .scale(yVolume)
            .orient("right")
            .ticks(3)
            .tickFormat(d3.format(",.3s"))

    volumeAnnotation = techan.plot.axisannotation()
            .axis(volumeAxis)
            .width(35)

    macdScale = d3.scale.linear()
            .range([indicatorTop(0)+dim.indicator.height, indicatorTop(0)])

    rsiScale = macdScale.copy()
            .range([indicatorTop(1)+dim.indicator.height, indicatorTop(1)])

    macd = techan.plot.macd()
            .xScale(x)
            .yScale(macdScale)

    macdAxis = d3.svg.axis()
            .scale(macdScale)
            .ticks(3)
            .orient("right")            

    macdAnnotation = techan.plot.axisannotation()
            .axis(macdAxis)
            .format(d3.format(',.2fs'))
            .translate([x(1), 0])

    macdAxisLeft = d3.svg.axis()
            .scale(macdScale)
            .ticks(3)
            .orient("left")

    macdAnnotationLeft = techan.plot.axisannotation()
            .axis(macdAxisLeft)
            .format(d3.format(',.2fs'))

    rsi = techan.plot.rsi()
            .xScale(x)
            .yScale(rsiScale)

    rsiAxis = d3.svg.axis()
            .scale(rsiScale)
            .ticks(3)
            .orient("right")

    rsiAnnotation = techan.plot.axisannotation()
            .axis(rsiAxis)
            .format(d3.format(',.2fs'))
            .translate([x(1), 0])

    rsiAxisLeft = d3.svg.axis()
            .scale(rsiScale)
            .ticks(3)
            .orient("left")

    rsiAnnotationLeft = techan.plot.axisannotation()
            .axis(rsiAxisLeft)
            .format(d3.format(',.2fs'))

    ohlcCrosshair = techan.plot.crosshair()
            .xScale(timeAnnotation.axis().scale())
            .yScale(ohlcAnnotation.axis().scale())
            .xAnnotation(timeAnnotation)
            .yAnnotation([ohlcAnnotation, percentAnnotation, volumeAnnotation])
            .verticalWireRange([0, dim.plot.height])

    macdCrosshair = techan.plot.crosshair()
            .xScale(timeAnnotation.axis().scale())
            .yScale(macdAnnotation.axis().scale())
            .xAnnotation(timeAnnotation)
            .yAnnotation([macdAnnotation, macdAnnotationLeft])
            .verticalWireRange([0, dim.plot.height])

    rsiCrosshair = techan.plot.crosshair()
            .xScale(timeAnnotation.axis().scale())
            .yScale(rsiAnnotation.axis().scale())
            .xAnnotation(timeAnnotation)
            .yAnnotation([rsiAnnotation, rsiAnnotationLeft])
            .verticalWireRange([0, dim.plot.height])

    ### svg = d3.select("#techan_plot").append("svg")
            .attr("width", dim.width)
            .attr("height", dim.height)
    ###
    defs = svg.append("defs")

    defs.append("clipPath")
            .attr("id", "ohlcClip")
        .append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", dim.plot.width)
            .attr("height", dim.ohlc.height)

    defs.selectAll("indicatorClip").data([0, 1])
        .enter()
            .append("clipPath")
            .attr("id", (d, i) ->
                "indicatorClip-" + i)
        .append("rect")
            .attr("x", 0)
            .attr("y", (d, i) ->
                indicatorTop(i))
            .attr("width", dim.plot.width)
            .attr("height", dim.indicator.height)

    svg = svg.append("g")
            .attr("transform", "translate(" + dim.margin.left + "," + dim.margin.top + ")")

    ###
    svg.append('text')
            .attr("class", "symbol")
            .attr("x", 20)
            .text("Facebook, Inc. (FB)")
    ###
    svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + dim.plot.height + ")")

    ohlcSelection = svg.append("g")
            .attr("class", "ohlc")
            .attr("transform", "translate(0,0)")

    ohlcSelection.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + x(1) + ",0)")
    ###
        .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", -12)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("Price ($)")
    ###
    ohlcSelection.append("g")
            .attr("class", "close annotation up")

    ohlcSelection.append("g")
            .attr("class", "volume")
            .attr("clip-path", "url(#ohlcClip)")

    ohlcSelection.append("g")
            .attr("class", "candlestick")
            .attr("clip-path", "url(#ohlcClip)")

    ohlcSelection.append("g")
            .attr("class", "indicator sma ma-0")
            .attr("clip-path", "url(#ohlcClip)")

    ohlcSelection.append("g")
            .attr("class", "indicator sma ma-1")
            .attr("clip-path", "url(#ohlcClip)")

    ohlcSelection.append("g")
            .attr("class", "indicator ema ma-2")
            .attr("clip-path", "url(#ohlcClip)")

    ohlcSelection.append("g")
            .attr("class", "percent axis")

    ohlcSelection.append("g")
            .attr("class", "volume axis")

    indicatorSelection = svg.selectAll("svg > g.indicator").data(["macd", "rsi"]).enter()
             .append("g")
                .attr "class", (d) ->
                    d + " indicator"

    indicatorSelection.append("g")
            .attr("class", "axis right")
            .attr("transform", "translate(" + x(1) + ",0)")

    indicatorSelection.append("g")
            .attr("class", "axis left")
            .attr("transform", "translate(" + x(0) + ",0)")

    indicatorSelection.append("g")
            .attr("class", "indicator-plot")
            .attr "clip-path", (d, i) ->
                "url(#indicatorClip-" + i + ")"

    # Add trendlines and other interactions last to be above zoom pane
    svg.append('g')
            .attr("class", "crosshair ohlc")

    svg.append('g')
            .attr("class", "crosshair macd")

    svg.append('g')
            .attr("class", "crosshair rsi")

    svg.append("g")
            .attr("class", "trendlines analysis")
            .attr("clip-path", "url(#ohlcClip)")
    svg.append("g")
            .attr("class", "supstances analysis")
            .attr("clip-path", "url(#ohlcClip)")

    # d3.select("button").on("click", reset)

    ###
    d3.csv "data.csv", (error, data) ->
        console.log data
        accessor = candlestick.accessor()
        indicatorPreRoll = 33  # Don't show where indicators don't have data

        data = data.map((d) -> 
            return {
                date: parseDate(d.Date),
                open: +d.Open,
                high: +d.High,
                low: +d.Low,
                close: +d.Close,
                volume: +d.Volume
            })
        .sort (a, b) ->
            d3.ascending(accessor.d(a), accessor.d(b))
    ###
    accessor = candlestick.accessor()
    indicatorPreRoll = 33  # Don't show where indicators don't have data
    data = scope.pricedata.map((d) -> 
        return {
            date: new Date(d[0]),
            open: +d[1],
            high: +d[2],
            low: +d[3],
            close: +d[4],
            volume: +0
        })
    .sort (a, b) ->
        d3.ascending(accessor.d(a), accessor.d(b))

    x.domain(techan.scale.plot.time(data).domain())
    y.domain(techan.scale.plot.ohlc(data.slice(indicatorPreRoll)).domain())
    yPercent.domain(techan.scale.plot.percent(y, accessor(data[indicatorPreRoll])).domain())
    yVolume.domain(techan.scale.plot.volume(data).domain())

    trendlineData = [
        { start: { date: new Date(2014, 2, 11), value: 72.50 }, end: { date: new Date(2014, 5, 9), value: 63.34 } },
        { start: { date: new Date(2013, 10, 21), value: 43 }, end: { date: new Date(2014, 2, 17), value: 70.50 } }
    ]

    supstanceData = [
        { start: new Date(2014, 2, 11), end: new Date(2014, 5, 9), value: 63.64 },
        { start: new Date(2013, 10, 21), end: new Date(2014, 2, 17), value: 55.50 }
    ]

    macdData = techan.indicator.macd()(data)
    macdScale.domain(techan.scale.plot.macd(macdData).domain())
    rsiData = techan.indicator.rsi()(data)
    rsiScale.domain(techan.scale.plot.rsi(rsiData).domain())

    svg.select("g.candlestick").datum(data).call(candlestick)
    svg.select("g.close.annotation").datum([data[data.length-1]]).call(closeAnnotation)
    svg.select("g.volume").datum(data).call(volume)
    svg.select("g.sma.ma-0").datum(techan.indicator.sma().period(10)(data)).call(sma0)
    svg.select("g.sma.ma-1").datum(techan.indicator.sma().period(20)(data)).call(sma1)
    svg.select("g.ema.ma-2").datum(techan.indicator.ema().period(50)(data)).call(ema2)
    svg.select("g.macd .indicator-plot").datum(macdData).call(macd)
    svg.select("g.rsi .indicator-plot").datum(rsiData).call(rsi)

    svg.select("g.crosshair.ohlc").call(ohlcCrosshair).call(zoom)
    svg.select("g.crosshair.macd").call(macdCrosshair).call(zoom)
    svg.select("g.crosshair.rsi").call(rsiCrosshair).call(zoom)
    # svg.select("g.trendlines").datum(trendlineData).call(trendline).call(trendline.drag)
    # svg.select("g.supstances").datum(supstanceData).call(supstance).call(supstance.drag)


    zoomable = x.zoomable()
    zoomable.domain([indicatorPreRoll, data.length]) # Zoom in a little to hide indicator preroll

    reset = () ->
        zoom.scale(1)
        zoom.translate([0,0])
        draw()

    

    draw()

    # Associate the zoom with the scale after a domain has been applied
    zoom.x(zoomable).y(y)
    zoomPercent.y(yPercent)

    return true

angular.module("app.directives").directive "techan", ->
    restrict: "E"
    replace: true
    scope:
        pricedata: "="
        volumedata: "="
        marketName: "="
        volumeSymbol: "="
        volumePrecision: "="
        priceSymbol: "="

    template: "<div id=\"techan_plot\"></div>"

    chart: null

    link: (scope, el, attrs) ->
        chart = null
        dim = 
            width: parseInt(d3.select('#pricechart-container').style('width'), 10), height: 500,
            margin: { top: 20, right: 50, bottom: 30, left: 50 },
            ohlc: { height: 305 },
            indicator: { height: 65, padding: 5 }

        svg = d3.select("#techan_plot").append("svg")
            .attr("width", dim.width)
            .attr("height", dim.height)

        console.log "linking techan directive"
        # chart = initChart(scope)
        scope.$watch "pricedata", (newValue) =>
            if newValue and not chart
                chart = initChart(scope, svg)
            else if chart
                console.log "already exists"
                # chart.series[0].setData newValue, true
                # chart.draw
        , true

        ###
        scope.$watch "volumedata", (newValue) =>
            return unless chart
            chart.series[1].setData newValue, true
        , true
        ###

        render = (pricedata) ->
            chart.draw


