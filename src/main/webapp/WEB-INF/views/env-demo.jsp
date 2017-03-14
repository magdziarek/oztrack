<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="yyyy-MM-dd HH:mm:ss"/>
<tags:page title="${project.title}: Environment Data Demo">
    <jsp:attribute name="description">
        Environment Data Demo in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="head">
          <script charset="utf-8" type="text/javascript" src="https://d3js.org/d3.v4.min.js"></script>
        <style>

    .line {
        fill: none;
        stroke: #B3DE69;
        stroke-width: 1px;
    }
    #layer-control {
        position: absolute;
        margin-left:500px;
        margin-top:30px;
        width:300px;
        z-index: 1;
        font-size: x-small;
    }
    input[type=radio],
    input.radio {
        float: left;
        clear: none;
        margin: 2px 5px 2px 2px;
    }
    </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');

            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <span class="active">Environment Data Demo</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:data-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>Environment Data - Demonstration</h2>
        <p>These files contain environmental values for each detection location sourced via the Atlas of Living Australia.
        </p>
        <ul style="list-style: none">
        <c:forEach items="${project.animals}" var="animal">
            <li><div style="width: 10px; height: 10px; background-color: ${animal.colour}; display:inline-block"></div>
                <a href="${pageContext.request.contextPath}/projects/${project.id}/env?id=${animal.id}">
            ${animal.animalName}</a></li>
        </c:forEach>
            <li><a style="font-weight:bold" href="${pageContext.request.contextPath}/projects/${project.id}/env">Environmental layer metadata</a></li>
        </ul>

        <h2>Sample Environment Layer Data</h2>


        <div id="layer-control">
            <input name="layer" type="radio" value="el597" id="el597" checked>
            <label for="el597"> Rainfall erosivity (MJmm/ha/hr)</label>
            <input name="layer" type="radio" value="el1078" id="el1078">
            <label for="el1078"> Normalized Difference Vegetation Index</label>
            <input name="layer" type="radio" value="el815" id="el815">
            <label for="el815"> Valley bottom %</label>
            <input name="layer" type="radio" value="el836" id="el836">
            <label for="el836"> Topographic slope (%)</label>
            <input name="layer" type="radio" value="el848" id="el848">
            <label for="el848"> Bathymetry and Topography 9 sec</label>
        </div>
        <svg width="500" height="200"></svg>

        <script type="text/javascript" defer>
            console.log("working here");
            d3.select("#d3-test").append("p").text("D3 works!");

            var svg = d3.select("svg"),
                    margin = {top: 10, right: 10, bottom: 20, left: 50},
                    width = +svg.attr("width") - margin.left - margin.right,
                    height = +svg.attr("height") - margin.top - margin.bottom,
                    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            var x = d3.scaleLinear()
                    .rangeRound([0, width]);

            var y = d3.scaleLinear()
                    .rangeRound([height, 0]);

            var line = d3.line()
                    .x(function(d) { return x(d.ord); })
                    .y(function(d) { return y(d.env); });

            // el597: Rainfall erosivity (MJmm/ha/hr)
            // el1078: Normalized Difference Vegetation Index (2012-03-05)

            var columnName = "el597";
            updateChart(columnName);

            d3.selectAll("#layer-control input[name=layer]").on("change", function() {
                var v = this.value;
                console.log("change to: " + v);
                updateChart(v);

            });

            d3.select('#layer').on('click', function() {
                var newColumn = eval(d3.select(this).property('value'));
                console.log("change to : " + newColumn);
                updateChart(newColumn);
            });

            function updateChart(columnName) {

                d3.selectAll("g > *").remove();
                d3.csv("${pageContext.request.contextPath}/projects/${project.id}/env?id=5324"
                        ,function (d,i) {

                            d.ord  = i;
                            d.env  = +d[columnName];
                            return d;

                        },function (error, data) {

                            console.log("updateChart run");
                            if (error) throw error;

                            x.domain(d3.extent(data, function(d) { return d.ord; }));
                            y.domain(d3.extent(data, function(d) { return d.env; }));

                            g.append("g")
                                    .attr("class", "axis axis--x")
                                    .attr("transform", "translate(0," + height + ")")
                                    .call(d3.axisBottom(x));

                            g.append("g")
                                    .attr("class", "axis axis--y")
                                    .call(d3.axisLeft(y))
                                    .append("text")
                                    .attr("fill", "#000")
                                    .attr("transform", "rotate(-90)")
                                    .attr("y", 6)
                                    .attr("dy", "0.71em")
                                    .style("text-anchor", "end")
                                    .text("Vvv");

                            g.append("path")
                                    .datum(data)
                                    .attr("class", "line")
                                    .attr("d", line);

                        });
            }

        </script>

    </jsp:body>
</tags:page>