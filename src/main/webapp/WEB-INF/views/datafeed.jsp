<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<jsp:useBean id="now" class="java.util.Date"/>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss"/>
<c:set var="momentDateTimeFormatPattern" value="yyyy-MM-dd HH:mm:ss Z"/>
<c:set var="rightNow" value="${now}"/>
<tags:page title="${project.title}: Automated Downloads">
    <jsp:attribute name="description">
        Automated downloads into the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="head">
        <style type="text/css">
            .table-condensed td {
                vertical-align: middle;
            }

            rect.selection {
                fill: #c5c56d;
                stroke: #a4a441;
                stroke-opacity: 0.5;
                shape-rendering: auto;
            }

            div.tooltip {
                position: absolute;
                text-align: left;
                padding: 4px;
                border-radius: 3px;
                box-shadow: 0px 0px 0px 1px rgba(0, 0, 0, 0.2);
                pointer-events: none;
            }

            .zoom {
                cursor: move;
                fill: none;
                pointer-events: all;
            }
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/d3.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/datafeed-chart.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                $('#navTrack').addClass('active');
                $('#dataActionsDataFeeds').addClass('active');
                updateMomentTime();
                setInterval(function () {
                    updateMomentTime();
                }, 60000);

                $('.dataFeedPlotArea').each(function (index) {
                    var id = $(this).attr("id").replace("dataFeedPlotArea-", "");
                    var animalsList = [];
                    <c:forEach items="${dataFeeds}" var="dataFeed">
                    if (id == ${dataFeed.id}) {
                        <c:forEach items="${dataFeed.devices}" var="device">
                        animalsList.push({
                            device_ident: "${device.deviceIdentifier}",
                            device_id: "${device.id}",
                            animal_id: ${device.animal.id},
                            name: "${device.animal.animalName}",
                            colour: "${device.animal.colour}"
                        });
                        </c:forEach>
                    }
                    </c:forEach>
                    var source = $(this).find('#source').attr("value");
                    var project_id = $(this).find('#project_id').attr("value");
                    var dataFeedChart = new OzTrack.DataFeedChart();
                    dataFeedChart.loadChartData(id, source, project_id, animalsList);
                });
            });

            function updateMomentTime() {
                $('.lastPollDate').each(function (index) {
                    var lastPollDate = moment($(this).attr("value"));
                    var nowTime = moment();
                    var diffString = lastPollDate.from(nowTime);
                    var span = $(this).next();
                    span.html("<strong>Last Polled:</strong> " + moment(lastPollDate).format("DD/MM/YYYY HH:mm:ss Z") + " (" + diffString + "). ");
                });
            }
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <span class="active">Data Feeds</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:data-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h2>Automated Downloads</h2>

        <c:forEach items="${dataFeeds}" var="dataFeed">
            <div id="dataFeedPlots">
                <h3>${dataFeed.dataFeedSourceSystem.name} Locations</h3>
                <input type="hidden" class="lastPollDate"
                           value='<fmt:formatDate pattern="${momentDateTimeFormatPattern}" value="${dataFeed.lastPollDate}"/>'/>
                    <span class="lastPollInfo"></span>
                <br/>The most recent data points are highlighted with a dark outline.
                <br/><b>Poll Frequency: </b> every ${dataFeed.pollFrequencyHours} hour(s).<br/><br/>

                <div id="chartHelp"><span style="float:left">Help using this chart&nbsp;</span>
                    <div class="help-popover" title="Data Feed Chart" style="float:left">
                        This is an interactive chart - the smaller chart at the bottom is a navigator window for the
                        larger area. You can:
                        <ul>
                            <li>Zoom in by double-clicking on the graph canvas, or by using a mouse scroll</li>
                            <li>Zoom out by shift-double-clicking</li>
                            <li>Drag on either canvas to pan the chart</li>
                            <li>Hover over a data point to see detail</li>
                            <li>Data points with a black outline were harvested in the last poll</li>
                            <c:if test="${dataFeed.dataFeedSourceSystem.name == 'Argos'}">
                                <li>Lighter coloured data points are detections from Argos that contain no location
                                    information
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>

                <div id="dataFeedPlotArea-${dataFeed.id}" class="dataFeedPlotArea">
                    <svg id="svg-${dataFeed.id}"></svg>
                    <input id="source" type="hidden" value="${dataFeed.dataFeedSourceSystem.name}"/>
                    <input id="project_id" type="hidden" value="${dataFeed.project.id}"/>
                </div>
            </div>
        </c:forEach>
    </jsp:body>
</tags:page>