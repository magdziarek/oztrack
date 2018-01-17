(function (OzTrack) {
    OzTrack.DataFeedChart = function () {
        if (!(this instanceof OzTrack.DataFeedChart)) {
            throw new Error("DataFeedChart - Constructor called as a function");
        }
        var that = this;
        var svg
            , focus
            , navigation
            , brush
            , zoom
            , lastPollDate, dateExtent
            , dataNest
            , animalMetadata;

        var id, project_id;
        var margin, margin2, width, height, height2;
        var x, x2, y, y2, xAxis, xAxis2, yAxis, yAxis2;
        var barWidth, barPadding;
        var formatTime = d3.timeFormat("%d/%m/%Y %H:%M:%S");
        var tooltipDiv = d3.select("body").append("div")
            .attr("class", "tooltip")
            .style("opacity", 0);
        var downloadDiv = d3.select("body").append("div")
            .attr("class", "tooltip")
            .style("opacity", 0);


        that.divSetup = function () {

            // size is dependent on width of client and number of devices
            var clientWidth = d3.select("#dataFeedPlots").node().getBoundingClientRect().width;
            barWidth = 5;

            margin = {top: 30, right: 40, bottom: 30, left: 40} //see mbostock's margin convention
                , width = +clientWidth - margin.left - margin.right
                , height2 = animalMetadata.size() * 7
                , height = (animalMetadata.size() * 25) //- margin.top - margin.bottom
                , margin2 = {top: height + margin.bottom, right: margin.right, bottom: 20, left: margin.left};

            x = d3.scaleTime().range([0, width]),
                x2 = d3.scaleTime().range([0, width]),
                y = d3.scaleBand().range([0, height]).domain(animalMetadata.keys()),
                y2 = d3.scaleBand().range([0, height2]).round(false).domain(animalMetadata.keys()),
                xAxis = d3.axisTop(x),
                xAxis2 = d3.axisBottom(x2);

            svg = d3.select("#svg-" + that.id)
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom + height2 + margin2.bottom)
                .attr("class", "datafeedSvg");

            brush = d3.brushX()
                .extent([[0, 0], [width, height2]])
                .on("brush end", brushed);

            zoom = d3.zoom()
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

            svg.append("defs").append("clipPath")
                .attr("id", "clip")
                .append("rect")
                .attr("width", width)
                .attr("height", height);

            focus = svg.append("g")
                .attr("class", "focus")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            navigation = svg.append("g")
                .attr("class", "navigation")
                .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")")
                .style("fill", "#d3d392");

        };

        that.loadChartData = function (id, feedType, project_id, animalsList) { //url, animalsList) {
            that.id = id;
            that.feedType = feedType;
            that.project_id = project_id;
            animalMetadata = d3.map();
            animalsList.sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
            animalsList.forEach(function (a) {
                animalMetadata.set(a.device_ident, {
                    "name": a.name
                    , "device_id": a.device_id
                    , "animal_id": a.animal_id
                    , "colour": a.colour
                    , "visible": true
                });
            });
            var url = "/projects/" + project_id + "/detcsv?dataFeedId=" + id;
            d3.csv(url, type, function (error, data) {
                if (error) throw error;
                lastPollDate = d3.max(data, function (d) {
                    return d.poll_date;
                });
                dateExtent = [d3.min(data, function (d) {
                    return d.location_date;
                }), d3.timeHour.offset(lastPollDate, 3)];
                dataNest = d3.nest()
                    .key(function (d) {
                        return d.device_ident;
                    })
                    .entries(data);
                var animalStats = d3.nest()
                    .key(function (d) {
                        return d.device_ident;
                    })
                    .rollup(function (leaves) {
                        return {
                            "countnum": leaves.length
                            , "maxLocationDate": d3.max(leaves, function (d) {
                                return d.location_date;
                            })
                        }
                    })
                    .entries(data);
                animalStats.forEach(function (d) {
                    var a = animalMetadata.get(d.key);
                    a['count'] = d.value["countnum"];
                    a['maxLocationDate'] = d.value["maxLocationDate"];
                });
                drawChart();
            });
            that.divSetup();
        };

        function type(d) {
            var parseTime = d3.timeParse("%Y-%m-%d %H:%M:%S");
            var parseTimeHour = d3.timeParse("%Y-%m-%d %H");
            d.detection_date = parseTime(d.detection_date);
            d.location_date = parseTime(d.location_date);
            if (d.location_date == null) {
                d.location_date = d.detection_date;
                d.location_flag = false;
            } else {
                d.location_flag = true;
            }
            d.poll_date = parseTimeHour(d.poll_date);
            return d;
        }

        function drawChart() {

            x.domain(dateExtent);
            x2.domain(dateExtent);

            focus.append("g")
                .attr("class", "axis axis--x")
                .call(xAxis)
                .append("text")
                .attr("y", -20)
                .attr("x", width - 15)
                .attr("fill", "#000")
                .style("text-anchor", "end")
                .style("font-weight", "bold")
                .text("Location Date");

            focus.selectAll(".laneLine")
                .data(animalMetadata.keys())
                .enter().append("line")
                .attr("stroke", "#000")
                .attr("stroke-opacity", 0.2)
                .attr("x1", 0)
                .attr("y1", function (d) {
                    return y(d) + y.bandwidth();
                })
                .attr("x2", width)
                .attr("y2", function (d) {
                    return y(d) + y.bandwidth();
                })
                .attr("class", "domain")
                .style("shape-rendering", "crispedges");

            focus.selectAll(".laneText")
                .data(animalMetadata.keys())
                .enter().append("text")
                .text(function (d) {
                    return d;
                })
                .attr("x", -3)
                .attr("y", function (d) {
                    return y(d) + y.bandwidth() / 2 + 0.5;
                })
                .attr('dy', '0.5ex')
                .attr("text-anchor", "end")
                .attr("class", "laneText")
                .style("font-size", "smaller")
                .style("font-weight", "bold")
                .on("mouseover", function (d) {
                    var thisAnimal = animalMetadata.get(d);
                    var tooltipHtml = "<b>" + thisAnimal.name + ": </b>" + thisAnimal.count + " locations <br/>" +
                        "<b>Last Located: </b> " + thisAnimal.maxLocationDate + "<br\>";
                    tooltipDiv.transition()
                        .duration(2)
                        .style("opacity", .9);
                    tooltipDiv.html(tooltipHtml)
                        .style("left", (d3.event.pageX + 25) + "px")
                        .style("top", (d3.event.pageY - y.bandwidth() / 2) + "px")
                        .style("background", thisAnimal.colour)
                        .style("font-size", "smaller")
                        .style("stroke", "#666666")
                        .style("stroke-opacity", 1)
                        .style("stroke-width", 1);
                })
                .on("mouseout", function (d) {
                    tooltipDiv.transition()
                        .duration(2)
                        .style("opacity", 0)
                });

            focus.selectAll(".laneDownload")
                .data(animalMetadata.keys())
                .enter().append("svg:foreignObject")
                .attr("x", width + 10)
                .attr("y", function (d) {
                    return y(d) + y.bandwidth() / 4;
                })
                .append("xhtml:a")
                .attr("class", "icon-download")
                .on("mouseover", function (d) {
                    var thisAnimal = animalMetadata.get(d);
                    var mouseoverText;
                    if (that.feedType == 'Argos') {
                        mouseoverText = '<b>Download Diagnostic Data</b>' +
                            "<p>Extra information eg nbrMessages, " +
                            " errorRadius, semiMinor, semiMajor, orientation, hdop (1 row for each detection).</p>";
                    } else if (that.feedType == 'Spot') {
                        mouseoverText = 'Download Raw Data';
                    }
                    downloadDiv.transition()
                        .duration(2)
                        .style("opacity", .9);
                    downloadDiv.html(mouseoverText)
                        .style("left", (d3.event.pageX + 5) + "px")
                        .style("top", (d3.event.pageY - y.bandwidth() / 2) + "px")
                        .style("background", thisAnimal.colour)
                        .style("font-size", "smaller")
                        .style("stroke", "#666666")
                        .style("stroke-opacity", 1)
                        .style("stroke-width", 1);
                })
                .on("mouseout", function (d) {
                    downloadDiv.transition()
                        .duration(2)
                        .style("opacity", 0)
                })
                .attr("href", function (d) {
                    var thisAnimal = animalMetadata.get(d);
                    var downloadLink;
                    if (that.feedType == 'Argos') {
                        downloadLink = "/projects/" + that.project_id + "/argosraw?deviceId=" + thisAnimal.device_id + "&rtype=diagnostic";
                    } else if (that.feedType == 'Spot') {
                        downloadLink = "/projects/" + that.project_id + "/spotraw?deviceId=" + thisAnimal.device_id;
                    }
                    return downloadLink;
                });

            if (that.feedType == 'Argos') {
                focus.selectAll(".laneDownloadArgos")
                    .data(animalMetadata.keys())
                    .enter().append("svg:foreignObject")
                    .attr("x", width + 25)
                    .attr("y", function (d) {
                        return y(d) + y.bandwidth() / 4;
                    })
                    .append("xhtml:a")
                    .attr("class", "icon-download")
                    .on("mouseover", function (d) {
                        var thisAnimal = animalMetadata.get(d);
                        downloadDiv.transition()
                            .duration(2)
                            .style("opacity", .9);
                        var messageHtml = "<b>Download Raw Message Data</b>" +
                            "<p>Raw data for each message and encoded sensor data (many rows per detection).</p>";

                        downloadDiv.html(messageHtml)
                            .style("left", (d3.event.pageX + 10) + "px")
                            .style("top", (d3.event.pageY - y.bandwidth() / 2) + "px")
                            .style("background", thisAnimal.colour)
                            .style("font-size", "smaller")
                            .style("stroke", "#666666")
                            .style("stroke-opacity", 1)
                            .style("stroke-width", 1);
                    })
                    .on("mouseout", function (d) {
                        downloadDiv.transition()
                            .duration(2)
                            .style("opacity", 0)
                    })
                    .attr("href", function (d) {
                        var thisAnimal = animalMetadata.get(d);
                        return "/projects/" + that.project_id + "/argosraw?deviceId=" + thisAnimal.device_id + "&rtype=messages";
                    });
            }

            navigation.append("g")
                .attr("class", "axis axis--x")
                .attr("transform", "translate(0," + height2 + ")")
                .call(xAxis2);

            navigation.append("g")
                .attr("class", "brush")
                .call(brush)
                .call(brush.move, x.range());

            dataNest.forEach(function (d) {

                var thisAnimal = animalMetadata.get(d.key);
                barPadding = y.bandwidth() * .1;
                focus.selectAll(".blip")
                    .data(d.values)
                    .enter().append("rect")
                    .attr("rx", y.bandwidth() * .1)
                    .attr("ry", y.bandwidth() * .1)
                    .attr("x", function (d) {
                        return x(d.location_date);
                    })
                    .attr("y", function (d) {
                        return y(d.device_ident) + barPadding;
                    })
                    .attr("width", barWidth)
                    .attr("height", y.bandwidth() * .9 - barPadding)
                    .attr("clip-path", "url(#clip)")
                    .attr("class", "point point-" + d.key)
                    .style("fill", thisAnimal.colour)
                    .style("opacity", function (d) {
                        if (d.location_flag) {
                            return 1
                        } else {
                            return 0.3
                        }
                    })
                    .style("stroke", "#000")
                    .style("stroke-opacity", function (d) {
                        if (d3.timeHour.count(d.poll_date, lastPollDate) <= 1) {
                            return 1
                        } else {
                            return 0.1
                        }
                    })
                    .style("stroke-width", .5)
                    .on("mouseover", function (d) {
                        var tooltipText = "<b>" + formatTime(d.location_date) + "</b> ";
                        if (!d.location_flag) {
                            tooltipText += "<br/>No location";
                        }
                        tooltipDiv.transition()
                            .duration(2)
                            .style("opacity", .9);
                        tooltipDiv.html(tooltipText)
                            .style("left", (d3.event.pageX) + 5 + "px")
                            .style("top", (d3.event.pageY - y.bandwidth()) + "px")
                            .style("background", thisAnimal.colour)
                            .style("font-size", "smaller")
                            .style("stroke", "#666666")
                            .style("stroke-opacity", 1)
                            .style("stroke-width", 1);
                    })
                    .on("mouseout", function (d) {
                        tooltipDiv.transition()
                            .duration(500)
                            .style("opacity", 0)
                    });

                navigation.selectAll(".littleBlip")
                    .data(d.values)
                    .enter().append("circle")
                    .attr("r", 2)
                    .attr("cx", function (d) {
                        return x2(d.location_date);
                    })
                    .attr("cy", function (d) {
                        return y2(d.device_ident) + y2.bandwidth() / 2;
                    })
                    .style("fill", function (d) {
                        return thisAnimal.colour;
                    })
                    .style("shape-rendering", "auto")
                    .style("stroke", "#666666")
                    .style("stroke-opacity", 0.5)
                    .style("stroke-width", 0.3);
            });

            // set the navigation window to the last third of the chart
            navigation.select(".brush").call(brush.move, [x.range()[1] * .67, x.range()[1]]);
        }

        function brushed() {
            if (d3.event.sourceEvent && d3.event.sourceEvent.type === "zoom") return; // ignore brush-by-zoom
            var s = d3.event.selection || x2.range();
            x.domain(s.map(x2.invert, x2));
            dataNest.forEach(function (d) {
                focus.selectAll('.point-' + d.key)
                    .attr("x", function (d) {
                        return x(d.location_date);
                    })
                    .attr("y", function (d) {
                        return y(d.device_ident) + barPadding;
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
            dataNest.forEach(function (d) {
                focus.selectAll('.point-' + d.key)
                    .attr("x", function (d) {
                        return x(d.location_date);
                    })
                    .attr("y", function (d) {
                        return y(d.device_ident) + barPadding;
                    });
            });
            focus.select(".axis--x").call(xAxis);
            navigation.select(".brush").call(brush.move, x.range().map(t.invertX, t));
        }
    }


}(window.OzTrack = window.OzTrack || {}));        
