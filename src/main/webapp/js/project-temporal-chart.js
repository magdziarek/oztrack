var clientWidth = d3.select("#projectMapOptionsTabs").node().getBoundingClientRect().width;
var clientHeight = clientWidth * 0.6; // keep aspect ratio

var margin = {top: 10, right: 40, bottom: clientHeight*.3, left: 40},
    margin2 = {top: clientHeight*.8 , right: 40, bottom: 20, left: 40},
    width = +clientWidth - margin.left - margin.right,
    height = +clientHeight - margin.top - margin.bottom,
    height2 = +clientHeight - margin2.top - margin2.bottom;

var svg = d3.select("#svgChart")
      .attr("width", +clientWidth)
      .attr("height", +clientHeight);

var brush = d3.brushX()
    .extent([[0, 0], [width, height2]])
    .on("brush end", brushed);

var zoom = d3.zoom()
    .scaleExtent([1, Infinity])
    .translateExtent([[0, 0], [width, height]])
    .extent([[0, 0], [width, height]])
    .on("zoom", zoomed);

svg.append("rect")
    .attr("class", "zoom")
    .attr("width", width)
    .attr("height", height)
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    .call(zoom);

var x = d3.scaleTime().range([0, width]),
    x2 = d3.scaleTime().range([0, width]),
    y = d3.scaleLinear().rangeRound([height, 0]),
    y2 = d3.scaleLinear().rangeRound([height2, 0]);

var xAxis = d3.axisBottom(x),
    xAxis2 = d3.axisBottom(x2),
    yAxis = d3.axisLeft(y);

var maxY;

var div = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

svg.append("defs").append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", width)
    .attr("height", height);

var focus = svg.append("g")
    .attr("class","focus")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var navigation = svg.append("g")
    .attr("class", "navigation")
    .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")")
    .style("fill","#d3d392");

// init some globals and get started
var parseTime = d3.timeParse("%Y-%m-%d %H:%M:%S");
var formatTime = d3.timeFormat("%Y-%m-%d %H:%M:%S");
var roundNumber = d3.format(",.2f"); // round to 0 dec places
var dataNest, animalMetadata, extentMap;
var line=d3.line(), line2=d3.line();
var measure = "cumulative_distance";

// load the data once with no need to reload every time the the chart measure changes
function loadProjectChartData(projectId, animalMetadataArray) {

    animalMetadata = d3.map();
    animalMetadataArray.sort(function(a,b) {return a.name.localeCompare(b.name);});
    animalMetadataArray.forEach(function (a) {
        animalMetadata.set(+a.id, {"name": a.name, "colour": a.colour, "visible": true  });
    });

    extentMap = d3.map();
    d3.csv("posfixstats", type,function(error, data) {

        if (error) throw error;

        // set the globals that we don't want to read in each time
        extentMap.set("detectiontime", d3.extent(data, function(d) { return d.detectiontime }));
        extentMap.set("cumulative_distance", d3.extent(data, function(d) { return d.cumulative_distance; }));
        extentMap.set("displacement", d3.extent(data, function(d) { return d.displacement; }));

        dataNest = d3.nest()
            .key(function(d) {return d.animal_id;})
            .entries(data);

        // fire up the first chart once the data is loaded
        updateChart(measure);
        drawLegend();
    });
}

function type(d) {
    d.project_day_index  = +d.project_day_index;
    d.detectiontime = parseTime(d.detectiontime);
    d.animal_id = +d.animal_id;
    d.cumulative_distance = +d.cumulative_distance/1000;
    d.displacement = +d.displacement/1000;
    return d;
}

function drawLegend() {

    var legendX = margin.left
        , legendY = 10 //margin2.top + height2 + 30
        , legendSquareSize = 10;

    var legendSvg = d3.select("#legendDiv")
        .attr("width", width)
        .attr("height", height + height2)
        .append("svg")
        .attr("id","svgLegend")
        .attr("width", width - 50)
        .attr("height", (animalMetadata.size() * (legendSquareSize+5))+ legendY*2);

    legendSvg.selectAll("title_text")
        .data(["Click box to show/hide:"])
        .enter()
        .append("text")
        .attr("x", legendX)
        .attr("y", legendY)
        .style("font-family", "sans-serif")
        .style("font-size", "10px")
        .style("color", "Black")
        .text(function (d) { return d; });


    legendY+=10; //wiggle down from the header
    var legendg = legendSvg.append("g")
        .attr("class","legend")
      ;

    legendg.selectAll('rect')
        .data(animalMetadata.keys())
        .enter()
        .append("rect")
        .attr("id", function (d) { return "legend-"+d; })
        .attr("class", "legendSquare")
        .attr("width", legendSquareSize)
        .attr("height", legendSquareSize)
        .attr("x", legendX)
        .attr("y", function (d,i) { return (i*(legendSquareSize+5))+ legendY; })
        .attr("fill", function(d) { var o = animalMetadata.get(d); return o.visible ? o.colour : "#F1F1F2" })
        .style("stroke", "#666666")
        .style("stroke-opacity", .5)
        .style("stroke-width", .3)
        .on("click", function(d) {
            var o = animalMetadata.get(d);
            var thisVisible = !(o.visible); // toggle
            animalMetadata.set(d, {"name": o.name, "colour": o.colour, "visible": thisVisible });
            legendg.select("#legend-" + d)
                .transition()
                .attr("fill", function() { return thisVisible ? o.colour : "#F1F1F2"; });
            y.domain([extentMap.get(measure)[0],findMaxY()]);
            svg.select(".axis--y")
                .transition().call(yAxis);
            dataNest.map(function (fd) { if (fd.key==d) {
                draw(fd); // send this object to be drawn or removed
            } else {
                redraw(fd); // adjust all the others to the new y domain
            } });
        })
        .on("mouseover", function(d){
            var o = animalMetadata.get(d);
            legendg.select("#legend-" + d)
                .transition()
                .attr("fill", o.colour) })
        .on("mouseout", function(d){
            var o = animalMetadata.get(d);
            legendg.select("#legend-" + d)
                .transition()
                .attr("fill", o.visible ? o.colour : "#F1F1F2")
        });

    legendg.selectAll('text')
        .data(animalMetadata.values())
        .enter()
        .append("text")
        .attr("class","legendText")
        .attr("x", legendX + legendSquareSize + 5)
        .attr("y", function (d,i) { return (i*(legendSquareSize+5)) + legendY+legendSquareSize; })
        .text(function(d, i) { return d.name });
}

function updateChart(aMeasure) {

    measure = aMeasure;
    svg.selectAll("g > *").remove();

    var dateExtent = extentMap.get("detectiontime");
        x.domain(dateExtent);
        y.domain(extentMap.get(measure));
        x2.domain(dateExtent);
        y2.domain(extentMap.get(measure));

    line
        .curve(d3.curveMonotoneX)
        .x(function(d) { return x(d.detectiontime); })
        .y(function(d) { return y(d[measure]); });

    line2
        .curve(d3.curveMonotoneX)
        .x(function(d) { return x2(d.detectiontime); })
        .y(function(d) { return y2(d[measure]); });

    focus.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        .append("text")
        .attr("fill", "#000")
        .attr("y",30)
        .attr("x",width)
        .style("text-anchor", "end")
        .style("font-weight", "bold")
        .text("Detection Date");

    navigation.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height2 + ")")
        .call(xAxis2);

    navigation.append("g")
        .attr("class", "brush")
        .call(brush)
        .call(brush.move, x.range());

    focus.append("g")
        .attr("class", "axis axis--y")
        .call(yAxis)
        .append("text")
        .attr("fill", "#000")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "0.71em")
        .style("text-anchor", "end")
        .style("font-weight", "bold")
        .text("Distance (km)");

    dataNest.forEach(function(d) {
        draw(d);
        navigation.append("path")
            .attr("id","nav-line-"+d.key)
            .attr("class", "line nav-line")
            .attr("d", line2(d.values))
            .style("stroke", animalMetadata.get(d.key).colour);
    });

    // set the navigation window to the first third of the chart
    navigation.select(".brush").call(brush.move,[x.range()[0],x.range()[1]/3]);
}

function findMaxY() {
    var maxYValues = dataNest.map(function(fd) {
        if (animalMetadata.get(fd.key).visible) {
            return d3.max(fd.values, function(value) {return value[measure]});
        } });
    return d3.max(maxYValues);
}

function draw(d) {
    var thisAnimal = animalMetadata.get(d.key);
    if (thisAnimal.visible) {
        focus.append("path")
            .attr("id","line-"+d.key)
            .attr("class", "line")
            .attr("d", line(d.values))
            .style("stroke", thisAnimal.colour);
        focus.selectAll(".dot")
            .data(d.values)
            .enter().append("circle")
            .attr("r",3)
            .attr("cx", function (d) { return x(d.detectiontime); })
            .attr("cy", function (d) { return y(d[measure]);})
            .attr("clip-path", "url(#clip)")
            .attr("class", "point point-"+d.key)
            .style("fill", thisAnimal.colour)
            .style("stroke", "#666666")
            .style("stroke-opacity", .5)
            .style("stroke-width", .3)
            .on("mouseover", function(d) {
                div.transition()
                    .duration(200)
                    .style("opacity", .75);
                div.html("<b>" + thisAnimal.name + "</b> " + formatTime(d.detectiontime) + " ("  + roundNumber(d[measure]) + "km)")
                    .style("left", (d3.event.pageX) + "px")
                    .style("top", (d3.event.pageY - 28) + "px")
                    .style("background", thisAnimal.colour)
                    .style("font-size", "smaller")
                    .style("stroke", "#666666")
                    .style("stroke-opacity", 1)
                    .style("stroke-width", .6);

            })
            .on("mouseout", function(d) {
                div.transition()
                    .duration(500)
                    .style("opacity", 0)});
    } else {
        focus.selectAll(".point-"+d.key).remove();
        focus.selectAll("#line-"+d.key).remove();
    }
}

function redraw(d) {
    // transition only
    if (animalMetadata.get(d.key).visible) {
        focus.select('#line-' + d.key)
            .transition()
            .attr("d", line(d.values));
        focus.selectAll('.point-' + d.key)
            .transition()
            .attr("cy", function (d) {
                return y(d[measure])});
    }
}

function brushed() {
    if (d3.event.sourceEvent && d3.event.sourceEvent.type === "zoom") return; // ignore brush-by-zoom
    var s = d3.event.selection || x2.range();
    x.domain(s.map(x2.invert, x2));
    dataNest.forEach(function(d) {
        focus.select('#line-' + d.key).attr("d", line(d.values));
        focus.selectAll('.point-' + d.key)
            .attr("cx", function (d) {
                return x(d.detectiontime);
            })
            .attr("cy", function (d) {
                return y(d[measure]);
            });
    });
    focus.select(".axis--x").call(xAxis);
    svg.select(".zoom").call(zoom.transform, d3.zoomIdentity
        .scale(width / (s[1] - s[0]))
        .translate(-s[0], 0));
}

function zoomed() {
    if (d3.event.sourceEvent && d3.event.sourceEvent.type === "brush") return; // ignore zoom-by-brush
    var t = d3.event.transform;
    x.domain(t.rescaleX(x2).domain());
    dataNest.forEach(function(d) {
        focus.select('#line-' + d.key).attr("d", line(d.values));
        focus.selectAll('.point-' + d.key)
            .attr("cx", function (d) { return x(d.detectiontime); })
            .attr("cy", function (d) { return y(d[measure]);});
    });
    focus.select(".axis--x").call(xAxis);
    navigation.select(".brush").call(brush.move, x.range().map(t.invertX, t));
}

