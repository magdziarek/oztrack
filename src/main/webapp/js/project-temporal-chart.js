var clientWidth = d3.select("#projectMapOptions").node().getBoundingClientRect().width - 20;

(function(OzTrack) {
  OzTrack.DistanceCharts = function() {
     if (!(this instanceof OzTrack.DistanceCharts)) {
         throw new Error("DistanceCharts - Constructor called as a function");
     }

     var that = this;
     //var clientWidth = d3.select("#projectMapOptions").node().getBoundingClientRect().width - 20;
     var clientHeight = clientWidth * 0.6; // keep aspect ratio

     // left margin needs to leave room for the axis labels
     var margin = {top: 10, right: 10, bottom: clientHeight * .3, left: 40},
         margin2 = {top: clientHeight * .8, right: 10, bottom: 20, left: 40},
         width = +clientWidth - margin.left - margin.right,
         height = +clientHeight - margin.top - margin.bottom,
         height2 = +clientHeight - margin2.top - margin2.bottom;

     var brush = d3.brushX()
          .extent([[0, 0], [width, height2]])
          .on("brush end", brushed);

     var zoom = d3.zoom()
          .scaleExtent([1, Infinity])
          .translateExtent([[0, 0], [width, height]])
          .extent([[0, 0], [width, height]])
          .on("zoom", zoomed);

     var svg = d3.select("#svgChart")
         .attr("width", +clientWidth)
         .attr("height", +clientHeight);

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

     var x = d3.scaleTime().range([0, width]),
         x2 = d3.scaleTime().range([0, width]),
         y = d3.scaleLinear().rangeRound([height, 0]),
         y2 = d3.scaleLinear().rangeRound([height2, 0]),
         xAxis = d3.axisBottom(x),
         xAxis2 = d3.axisBottom(x2),
         yAxis = d3.axisLeft(y);

     var tooltipDiv = d3.select("body").append("div")
         .attr("class", "tooltip")
         .style("opacity", 0);

     var focus = svg.append("g")
         .attr("class", "focus")
         .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

     var navigation = svg.append("g")
         .attr("class", "navigation")
         .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")")
         .style("fill", "#d3d392");

     var dataNest,
         animalMetadata,
         extentMap,
         line = d3.line(),
         line2 = d3.line(),
         parseTime = d3.timeParse("%Y-%m-%d %H:%M:%S"),
         formatTime = d3.timeFormat("%Y-%m-%d %H:%M:%S"),
         roundNumber2 = d3.format(",.2f"), // round to 0 dec places
         roundNumber4 = d3.format(",.4f");


      var chartMetadata = [
         {     tab_name: "Step Distance"
             , measure: "step_distance"
             , title: "Distance between location fixes over time"
             , description: "The calculated minimum distance between consecutive location fixes. Calculated in WGS84."
             , unit: "km"
             , y_axis_title: "Distance (km)"
             , ord: 1
         }
         ,{    tab_name: "Step Speed"
             , measure: "step_speed"
             , title: "Speed over the ground between location fixes over time"
             , description: "The calculated minimum distance between consecutive location fixes divided by the time difference between those location fixes. Calculated in WGS84."
             , unit: "km/hr"
             , y_axis_title: "Speed (km/hr)"
             , ord: 2
         }
         , {   tab_name: "Cumulative Distance"
             , measure: "cumulative_distance"
             , title: "Cumulative distance moved since release"
             , description: "The sum of the minimum distance moved between consecutive location fixes. Calculated in WGS84."
             , unit: "km"
             , y_axis_title: "Distance (km)"
             , ord: 3
         }
         , {   tab_name: "Displacement"
             , title: "Distance moved from release location"
             , measure: "displacement"
             , description: "The minimum distance between the release location (first detection in track) and each consecutive location fix. Calculated in WGS84."
             , unit: "km"
             , y_axis_title: "Distance (km)"
             , ord: 4
         }
     ];

     function getChartMetadata(measure) {
         return chartMetadata.filter(function (m) {
             if (m.measure == measure) {
                 return m
             }
         })[0];
     }

//     that.chartTabsSetup = function() {

         // sort charts by the order given
         chartMetadata.sort(function (a, b) {
             return a.ord > b.ord;
         });

         // then prepend them in reverse order to leave the export button last
         chartMetadata.reverse().forEach(function (d, i) {
             $("#chart-menu-tabs").prepend(
                 $('<li>').attr('class', 'chart-menu-tab-li')
                     .attr('class', function (d1, i1) {
                         if (d.ord == 1) { //(i == chartMetadata.length-1) {
                             $("#chartTitle").html(d.title);
                             $("#chartDescription").html(d.description);
                             return 'chart-menu-tab-li active';
                         }
                     })
                     .append(
                         $('<a>').attr('id', 'chart-tab-' + d.ord)
                             .attr('data-chart-type', d.measure)
                             .attr('href', '#tab1')
                             .append(d.tab_name)
                             .click(function (e) {
                                 e.preventDefault();
                                 $(".chart-menu-tab-li").removeClass('active');
                                 $(this).parent().addClass('active');
                                 $("#chartTitle").html(d.title);
                                 $("#chartDescription").html(d.description);
                                 updateChart(d.measure);
                             })
                     )
             );
         });


 //    };
      

      
      that.adjustChartTabs = function () {
   // find widths

          var allTabsWidth, scrollAmount;
          $('#chart-menu-tabs li').each(function () {
              var tabWidth = $(this).outerWidth();
              console.log(tabWidth);
              allTabsWidth = allTabsWidth + tabWidth;
          });
          scrollAmount = clientWidth - allTabsWidth - 60;

         console.log("hello from adjustChartTabs(). clientWidth: " + clientWidth + " allTabsWidth: " + allTabsWidth);
         if (clientWidth < that.allTabsWidth) {
             $('.scroller-right').show();
         } else {
             $('.scroller-right').hide();
         }

          d3.select('.scroller-right').on("click", function () {
              $('.scroller-left').fadeIn('slow');
              $('.scroller-right').fadeOut('slow');
              $('#chart-menu-tabs').animate({left: "+=" + scrollAmount + "px"}, 'fast', function () {
              });
          });

          d3.select('.scroller-left').on("click", function () {
              $('.scroller-right').fadeIn('slow');
              $('.scroller-left').fadeOut('slow');
              $('#chart-menu-tabs').animate({left: "-=" + scrollAmount + "px"}, 'fast', function () {
              });
          });
      };

     d3.select("#export-open").on("click", function () {
         $(".chart-menu-tab-li").removeClass('active');
         $(this).parent().addClass('active');
         $("#chartTitle").hide();
         $("#chartDescription").hide();
         $("#chartHelp").hide();
         $("#chartDiv").hide();
         $("#legendDiv").hide();
         $("#exportConfirmation").slideDown();

     });

     d3.select("#export-close").on("click", function () {
         var thisTab = '#chart-tab-' + getChartMetadata(measure).ord;
         $(".chart-menu-tab-li").removeClass('active');
         $(thisTab).parent().addClass('active');
         $('#legendDiv').show();
         $('#chartDiv').show();
         $("#chartHelp").show();
         $("#chartDescription").show();
         $('#chartTitle').show();
         $("#exportConfirmation").slideUp();
     });

     d3.select("#chart-img").on("click", function () {
         var style, rules; // grab the css from this page
         for (var k = 0; k < document.styleSheets.length; k++) {
             if (document.styleSheets[k].title == "analysis-styles") {
                 rules = document.styleSheets[k].rules;
             }
         }
         if (rules) {
             for (var j = 0; j < rules.length; j++) {
                 style += (rules[j].cssText + '\n');
             }
         }
         var svg = d3.select("svg"),
             img = new Image(),
             serializer = new XMLSerializer(),
             width = svg.node().getBBox().width,
             height = svg.node().getBBox().height;

         svg.insert('defs', ":first-child")
         d3.select("svg defs")
             .append('style')
             .attr('type', 'text/css')
             .html(style);

         var svgStr = serializer.serializeToString(svg.node());
         img.src = 'data:image/svg+xml;base64,' + window.btoa(unescape(encodeURIComponent(svgStr)));
         window.open().document.write('<img src="' + img.src + '"/>');
     });

     // load the data once
     that.loadProjectChartData = function (url, animalMetadataArray) {

         animalMetadata = d3.map();
         animalMetadataArray.sort(function (a, b) {
             return a.name.localeCompare(b.name);
         });
         animalMetadataArray.forEach(function (a) {
             animalMetadata.set(+a.id, {"name": a.name, "colour": a.colour, "visible": true});
         });

         extentMap = d3.map();
         d3.csv(url, type, function (error, data) {

             if (error) throw error;

             // set the globals that we don't want to read in each time
             extentMap.set("detectiontime", d3.extent(data, function (d) { return d.detectiontime }));
             extentMap.set("cumulative_distance", d3.extent(data, function (d) { return d.cumulative_distance; }));
             extentMap.set("displacement", d3.extent(data, function (d) { return d.displacement; }));
             extentMap.set("step_distance", d3.extent(data, function (d) { return d.step_distance; }));
             extentMap.set("step_speed", d3.extent(data, function (d) { return d.step_speed; }));

             dataNest = d3.nest()
                 .key(function (d) {
                     return d.animal_id;
                 })
                 .entries(data);

             // fire up the first chart once the data is loaded
             updateChart(chartMetadata[0].measure);
             drawLegend();
         });

     };

     function type(d) {
         d.project_day_index = +d.project_day_index;
         d.detectiontime = parseTime(d.detectiontime);
         d.animal_id = +d.animal_id;
         d.cumulative_distance = +d.cumulative_distance / 1000;
         d.displacement = +d.displacement / 1000;
         d.step_distance = +d.step_distance / 1000;
         d.step_speed = +d.step_duration == 0 ? 0 : 3.6 * +d.step_distance / +d.step_duration;
         return d;
     }

     function drawLegend() {

         var legendX = margin.left
             , legendY = 10
             , legendSquareSize = 10;

         var legendSvg = d3.select("#legendDiv")
             .attr("width", width)
             .attr("height", height + height2)
             .append("svg")
             .attr("id", "svgLegend")
             .attr("width", width - 50)
             .attr("height", (animalMetadata.size() * (legendSquareSize + 5)) + legendY * 2);

         legendSvg.selectAll("title_text")
             .data(["Click box to show/hide:"])
             .enter()
             .append("text")
             .attr("x", legendX)
             .attr("y", legendY)
             .style("font-family", "sans-serif")
             .style("font-size", "10px")
             .style("color", "Black")
             .text(function (d) {
                 return d;
             });

         legendY += 10; //wiggle down from the header
         var legendg = legendSvg.append("g")
             .attr("class", "legend")
             ;

         legendg.selectAll('rect')
             .data(animalMetadata.keys())
             .enter()
             .append("rect")
             .attr("id", function (d) { return "legend-" + d; })
             .attr("class", "legendSquare")
             .attr("width", legendSquareSize)
             .attr("height", legendSquareSize)
             .attr("x", legendX)
             .attr("y", function (d, i) { return (i * (legendSquareSize + 5)) + legendY; })
             .attr("fill", function (d) {
                 var o = animalMetadata.get(d);
                 return o.visible ? o.colour : "#F1F1F2"
             })
             .style("stroke", "#666666")
             .style("stroke-opacity", .5)
             .style("stroke-width", .3)
             .on("click", function (d) {
                 var o = animalMetadata.get(d);
                 var thisVisible = !(o.visible); // toggle
                 animalMetadata.set(d, {"name": o.name, "colour": o.colour, "visible": thisVisible});
                 legendg.select("#legend-" + d)
                     .transition()
                     .attr("fill", function () {
                         return thisVisible ? o.colour : "#F1F1F2";
                     });
                 y.domain([extentMap.get(measure)[0], findMaxY()]);
                 svg.select(".axis--y")
                     .transition().call(yAxis);
                 dataNest.map(function (fd) {
                     if (fd.key == d) {
                         draw(fd); // send this object to be drawn or removed
                     } else {
                         redraw(fd); // adjust all the others to the new y domain
                     }
                 });
             })
             .on("mouseover", function (d) {
                 var o = animalMetadata.get(d);
                 legendg.select("#legend-" + d)
                     .transition()
                     .attr("fill", o.colour)
             })
             .on("mouseout", function (d) {
                 var o = animalMetadata.get(d);
                 legendg.select("#legend-" + d)
                     .transition()
                     .attr("fill", o.visible ? o.colour : "#F1F1F2")
             });

         legendg.selectAll('text')
             .data(animalMetadata.values())
             .enter()
             .append("text")
             .attr("class", "legendText")
             .attr("x", legendX + legendSquareSize + 5)
             .attr("y", function (d, i) { return (i * (legendSquareSize + 5)) + legendY + legendSquareSize; })
             .text(function (d, i) { return d.name });
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
             .x(function (d) { return x(d.detectiontime); })
             .y(function (d) { return y(d[measure]); });

         line2
             .x(function (d) { return x2(d.detectiontime); })
             .y(function (d) { return y2(d[measure]); });

         focus.append("g")
             .attr("class", "axis axis--x")
             .attr("transform", "translate(0," + height + ")")
             .call(xAxis)
             .append("text")
             .attr("fill", "#000")
             .attr("y", 30)
             .attr("x", width)
             .style("text-anchor", "end")
             .style("font-weight", "bold")
             .text("Detection Date");

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
             .text(function () { return getChartMetadata(measure).y_axis_title; });

         navigation.append("g")
             .attr("class", "axis axis--x")
             .attr("transform", "translate(0," + height2 + ")")
             .call(xAxis2);

         navigation.append("g")
             .attr("class", "brush")
             .call(brush)
             .call(brush.move, x.range());

         dataNest.forEach(function (d) {
             draw(d);
             navigation.append("path")
                 .attr("id", "nav-line-" + d.key)
                 .attr("class", "line nav-line")
                 .attr("d", line2(d.values))
                 .style("stroke", animalMetadata.get(d.key).colour);
         });

         // set the navigation window to the first third of the chart
         navigation.select(".brush").call(brush.move, [x.range()[0], x.range()[1] / 3]);
     }

     function findMaxY() {
         var maxYValues = dataNest.map(function (fd) {
             if (animalMetadata.get(fd.key).visible) {
                 return d3.max(fd.values, function (value) {
                     return value[measure]
                 });
             }
         });
         return d3.max(maxYValues);
     }

     function draw(d) {
         var thisAnimal = animalMetadata.get(d.key);
         var unit = getChartMetadata(measure).unit;
         if (thisAnimal.visible) {
             focus.append("path")
                 .attr("id", "line-" + d.key)
                 .attr("class", "line")
                 .attr("d", line(d.values))
                 .style("stroke", thisAnimal.colour);
             focus.selectAll(".dot")
                 .data(d.values)
                 .enter().append("circle")
                 .attr("r", 3)
                 .attr("cx", function (d) {
                     return x(d.detectiontime);
                 })
                 .attr("cy", function (d) {
                     return y(d[measure]);
                 })
                 .attr("clip-path", "url(#clip)")
                 .attr("class", "point point-" + d.key)
                 .style("fill", thisAnimal.colour)
                 .style("stroke", "#666666")
                 .style("stroke-opacity", .5)
                 .style("stroke-width", .3)
                 .on("mouseover", function (d) {
                     tooltipDiv.transition()
                         .duration(200)
                         .style("opacity", .75);
                     tooltipDiv.html("<b>" + thisAnimal.name + "</b> " + formatTime(d.detectiontime) + " (" + (unit == "km/hr" ? roundNumber4(d[measure]) : roundNumber2(d[measure])) + unit + ")")
                         .style("left", (d3.event.pageX) + "px")
                         .style("top", (d3.event.pageY - 28) + "px")
                         .style("background", thisAnimal.colour)
                         .style("font-size", "smaller")
                         .style("stroke", "#666666")
                         .style("stroke-opacity", 1)
                         .style("stroke-width", .6);
                 })
                 .on("mouseout", function (d) {
                     tooltipDiv.transition()
                         .duration(500)
                         .style("opacity", 0)
                 });
         } else {
             focus.selectAll(".point-" + d.key).remove();
             focus.selectAll("#line-" + d.key).remove();
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
                     return y(d[measure])
                 });
         }
     }

     function brushed() {
         if (d3.event.sourceEvent && d3.event.sourceEvent.type === "zoom") return; // ignore brush-by-zoom
         var s = d3.event.selection || x2.range();
         x.domain(s.map(x2.invert, x2));
         dataNest.forEach(function (d) {
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
         dataNest.forEach(function (d) {
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
         navigation.select(".brush").call(brush.move, x.range().map(t.invertX, t));
     }
 };    

}(window.OzTrack = window.OzTrack || {}));
    
function  chartTabs() {

    var allTabsWidth=0, scrollAmount=0;
    $('#chart-menu-tabs li').each(function () {
        allTabsWidth = allTabsWidth + $(this).outerWidth();
    });
    scrollAmount = clientWidth - allTabsWidth - 60;

    if (clientWidth < allTabsWidth) {
        $('.scroller-right').show();
    } else {
        $('.scroller-right').hide();
    }

    d3.select('.scroller-right').on("click", function () {
        $('.scroller-left').fadeIn('slow');
        $('.scroller-right').fadeOut('slow');
        $('#chart-menu-tabs').animate({left: "+=" + scrollAmount + "px"}, 'fast', function () {
        });
    });

    d3.select('.scroller-left').on("click", function () {
        $('.scroller-right').fadeIn('slow');
        $('.scroller-left').fadeOut('slow');
        $('#chart-menu-tabs').animate({left: "-=" + scrollAmount + "px"}, 'fast', function () {
        });
    });

};