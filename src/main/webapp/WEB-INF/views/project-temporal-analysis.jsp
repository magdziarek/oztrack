<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<%@ taglib uri="/WEB-INF/functions.tld" prefix="oztrack" %>
<c:set var="isoDateFormatPattern" value="yyyy-MM-dd"/>
<tags:page title="${project.title}: View Tracks" fluid="true">
    <jsp:attribute name="description">
        View and analyse animal tracking data in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="navExtra">
        <tags:project-dropdown project="${project}"/>
    </jsp:attribute>
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">

        <style type="text/css" title="temporal-analysis-styles">

            #projectMapOptions {
                width: 45%;
            }
            #projectMapOptions #toggleSidebar {
                display: block;
                position: absolute;
                top: 0;
                right: 0;
                text-align: center;
            }
            #projectMapOptions.minimised,
            #projectMapOptions.minimised #toggleSidebar {
                width: 16px;
            }
            #projectMapOptions.minimised #toggleSidebar {
                background-color: #e6e6c0;
            }
            #projectCharts {
                background-color: #FBFEEE;
            }
            .line {
                fill: none;
                clip-path: url(#clip);
                stroke-width:2;
            }
            .nav-line {
                stroke-width: 1.5;
            }
            .point {
             stroke: "grey";
             stroke-width:0.5;
             fill-opacity:0.7;
            }
            #layer-control {
                display:list-item;
                width:40%;
            }
            rect.selection {
                fill: #c5c56d	;
                stroke: #a4a441;
                stroke-opacity: 0.5;
                shape-rendering: auto;

            }
            .zoom {
                cursor: move;
                fill: none;
                pointer-events: all;
            }
            div.tooltip {
                position: absolute;
                text-align: center;
                padding: 4px;
                border-radius: 3px;
                box-shadow: 0px 0px 0px 1px rgba(0,0,0,0.2);
                pointer-events: none;
            }
            #legendDiv   {
                padding: 5px 0px;
                overflow:auto;
                -webkit-column-count: 3; /* Chrome, Safari, Opera */
                -moz-column-count: 3; /* Firefox */
                column-count: 3;
                height:40%;
            }
            .legend {
                overflow: auto;
            }
            .legendSquare {
                position:absolute;
                cursor: pointer;
            }
            #chartTitle {
                font-weight: bold;
                margin-top:-5px;
                text-align: center;
            }
            #chart-menu {
                margin-top:8px;
            }
            #chart-menu-tabs > li {
                margin-bottom: 7px;
            }
            #chart-menu-tabs  > li > a {
                display: inline;
                background-color: #f0f0da;
                font-weight:normal;
            }
            .chart-menu-tab-li > a {
                text-decoration:none;
            }
            #chart-menu-tabs > .active > a, .chart-menu-tabs > .active > a:hover, .chart-menu-tabs > .active > a:focus {
                background-color: #FBFEEE;
                font-weight:bold;
            }
            #export-options-list {
                background-color:#f0f0da;
            }
            #export-options-list > li > a {
                background-color: #f0f0da;
                color:#555555;
                font-size: 1em;
            }
            #export-options-list > li > a:hover {
                color:#ef9800;
            }
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script src="${pageContext.request.scheme}://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/openlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/d3.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-map.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-analysis.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-temporal-chart.js"></script>
        <script type="text/javascript">

            $(document).ready(function() {

                $("#projectMapOptionsTabs").tabs();
                var projectBounds = new OpenLayers.Bounds(
                    ${projectBoundingBox.envelopeInternal.minX}, ${projectBoundingBox.envelopeInternal.minY},
                    ${projectBoundingBox.envelopeInternal.maxX}, ${projectBoundingBox.envelopeInternal.maxY}
                );
                analysisMap = null;
                onResize();
                analysisMap = new OzTrack.AnalysisMap('projectMap', {
                    project: {
                        id: '${project.id}',
                        title: '${oztrack:escapeJS(project.title)}',
                        <c:if test="${(project.access == 'OPEN') and (project.dataLicence != null)}">
                            dataLicence: {
                                title: '${project.dataLicence.title}',
                                infoUrl: '${project.dataLicence.infoUrl}',
                                imageUrl: '${pageContext.request.scheme}://${fn:substringAfter(project.dataLicence.imageUrl, "://")}'
                            },
                        </c:if>
                        crosses180: ${project.crosses180},
                        bounds: projectBounds,
                        minDate: new Date(${projectDetectionDateRange.minimum.time}),
                        maxDate: new Date(${projectDetectionDateRange.maximum.time})
                },
                animals: [
                    <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                    <c:set var="animalBoundingBox" value="${animalBoundingBoxes[animal.id]}"/>
                    {
                        id: '${animal.id}',
                        name: '${oztrack:escapeJS(animal.animalName)}',
                        <c:if test="${animalBoundingBox != null}">
                        <c:set var="env" value="${animalBoundingBox.envelopeInternal}"/>
                        bounds: new OpenLayers.Bounds(${env.minX}, ${env.minY}, ${env.maxX}, ${env.maxY}),
                        </c:if>
                        colour: '${animal.colour}'
                    }<c:if test="${!animalStatus.last}">,</c:if>
                    </c:forEach>
                ]
                });
               

                loadProjectChartData(${project.id}, analysisMap.projectMap.animals);

                // chart options
                var chartNav = [
                    { title: "Cumulative Distance Travelled", measure: "cumulative_distance", tab_name: "Cumulative Distance"}
                   ,{ title: "Distance from Release", measure: "displacement", tab_name: "Displacement"}
                ];
                $.each(chartNav, function(i,d) {

                    $("#chart-menu-tabs").append(
                            $('<li>').attr('class', 'chart-menu-tab-li')
                                     .attr('class', function(d1, i1) {
                                        if (i == 0) {
                                            $("#chartTitle").html(d.title);
                                            return 'chart-menu-tab-li active';
                                        }
                                    })
                                    .append(
                                            $('<a>').attr('id','chart-tab-'+i)
                                                    .attr('data-chart-type', d.measure)
                                                    .attr('href','#tab1')
                                                    .append(d.tab_name)
                                                    .click(function(e) {
                                                        e.preventDefault();
                                                        $(".chart-menu-tab-li").removeClass('active');
                                                        $(this).parent().addClass('active');
                                                        $("#chartTitle").html(d.title);
                                                        updateChart(d.measure);
                                                    })
                                    )
                    );
                });

                d3.select("#chart-img").on("click", function(){
                    // grab the css from this page
                    var style, rules;
                    for (var k=0; k < document.styleSheets.length; k++) {
                        if (document.styleSheets[k].title == "temporal-analysis-styles") {
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

                    svg.insert('defs',":first-child")
                    d3.select("svg defs")
                                .append('style')
                                .attr('type','text/css')
                                .html(style);

                    var svgStr = serializer.serializeToString(svg.node());
                    //console.log(svgStr);
                    img.src = 'data:image/svg+xml;base64,'+window.btoa(unescape(encodeURIComponent(svgStr)));

                    window.open().document.write('<img src="' + img.src + '"/>');
                });
            });

            d3.select("#csv-export").on("click", function() {
                $("#chartTitle").hide();
                $("#chartDiv").hide();
                $("#legendDiv").hide();
                $("#exportConfirmation").slideDown();
            });

            function onResize() {
                var mainHeight = $(window).height() - $('#header').outerHeight();
                $('#projectMapOptions').height(mainHeight);
                $('#toggleSidebar').height(
                        $('#projectMapOptions').hasClass('minimised')
                                ? $('#projectMapOptions').innerHeight()
                                : $('#projectMapOptionsTabs .ui-tabs-nav').innerHeight()
                );
                $('#toggleSidebar *').position({my: "center", at: "center", of: "#toggleSidebar"});
                $('#projectMapOptions .ui-tabs-panel').height(
                        $('#projectMapOptions').innerHeight() -
                        $('#projectMapOptions .ui-tabs-nav').outerHeight() -
                        parseInt($('#projectMapOptions .ui-tabs-panel').css('padding-top')) -
                        parseInt($('#projectMapOptions .ui-tabs-panel').css('padding-bottom'))
                );
                $('#projectMap').height(mainHeight);
                $('#projectMap').width($(window).width() - $('#projectMapOptions').width());
                if (analysisMap) {
                    analysisMap.updateSize();
                }

            }
        </script>
    </jsp:attribute>
    <jsp:body>
        <div id="mapTool" class="mapTool">
            <div id="projectMapOptions" class="projectMapCharts">
                <div id="projectMapOptionsInner">
                    <div id="projectMapOptionsTabs">
                        <ul>
                            <li><a href="#projectCharts">Temporal Analysis</a></li>
                        </ul>
                        <div id="projectCharts" width="100%">
                            <div id="chart-menu">
                                <ul id="chart-menu-tabs" class="nav nav-tabs">
                                    <li class="chart-menu-tab-li dropdown pull-right">
                                     <a href="#" id="export-dropdown" class="dropdown-toggle" data-toggle="dropdown">Export<b class="caret" style="border-top-color:#000000;margin-left:5px"></b>&nbsp;</a>
                                     <ul id="export-options-list" class="dropdown-menu">
                                         <li><a id="csv-export" href="#" class="export-option">CSV</a></li>
                                         <li><a id="chart-img" href="#" class="export-option">Chart Image</a></li>
                                     </ul>
                                    </li>
                                </ul>
                                <div class="tab-content">
                                    <div class="tab-pane" id="exp-conf" style="line-height:1px;">
                                    </div>
                                </div>
                            </div>
                            <div id="chartTitle"></div>
                                <div id="chartHelp" style="position: absolute; right:16px; margin-top:-16px;">
                                <div class="help-popover" title="Temporal Analysis">
                                    The graphs are interactive. The smaller graph is a navigator window for the larger graph. You can:
                                    <ul>
                                        <li>Zoom in by double-clicking on the graph canvas, or by using a mouse scroll</li>
                                        <li>Zoom out by shift-double-clicking</li>
                                        <li>Drag on either canvas to pan the graph</li>
                                        <li>Hover over a data point to see detail</li>
                                        <li>Click on an animal in the legend to add/remove it from the graph</li>
                                    </ul>
                                </div>
                                </div>
                            <div id="exportConfirmation" class="form-bordered exportConfirmation" style="display: none;">
                                <p>Data in this project are made available under the following licence:</p>
                                <p style="margin-top: 18px;">
                                    <a target="_blank" href="${project.dataLicence.infoUrl}"
                                    ><img src="${pageContext.request.scheme}://${fn:substringAfter(project.dataLicence.imageUrl, '://')}" /></a>
                                </p>
                                <p><span style="font-weight: bold;">${project.dataLicence.title}</span></p>
                                <p>${project.dataLicence.description} <a target="_blank" href="${project.dataLicence.infoUrl}">More information</a></p>
                                <p style="margin-top: 18px;">By downloading these data, you agree to the licence terms.</p>
                                <p>
                                    If you use these data in any type of publication then you must cite the project DOI (if available) or any
                                    published peer-reviewed papers associated with the study. We strongly encourage you to contact the data custodians
                                    to discuss data usage and appropriate accreditation.
                                </p>
                                <div class="form-actions">
                                    <a class="exportButton btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}/posfixstats">Export CSV</a>
                                    <button class="btn" onclick="$(this).closest('.exportConfirmation').slideUp();$('#legendDiv').show();$('#chartDiv').show();$('#chartTitle').show();">Close</button>
                                </div>
                            </div>
                            <div id="chartDiv"><svg id="svgChart"></svg></div>
                            <div id="legendDiv"></div>
                        </div>
                        <a id="toggleSidebar" href="#toggleSidebar"><i class="icon-chevron-left"></i></a>
                    </div>
                </div>
            </div>
            <div id="projectMap"></div>
            <div style="clear:both;"></div>
        </div>
        <div id="errorDialog"></div>
        <input id="projectMapCancel" class="btn" style="display: none; margin-left: 0.5em;" type="button" value="Cancel" />
        <div style="clear:both;"></div>
    </jsp:body>
</tags:page>

