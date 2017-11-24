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
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function () {
                $('#navTrack').addClass('active');
                $('#dataActionsDataFeeds').addClass('active');
                updateMomentTime();
                setInterval(function () {
                    updateMomentTime();
                }, 60000);

            });

            function updateMomentTime() {
                $('.lastPollDate').each(function (index) {
                    var lastPollDate = moment($(this).attr("value"));
                    console.log("lastPollDate provided: " + $(this).attr("value"))
                    var nowTime = moment();
                    var diffString = lastPollDate.from(nowTime);
                    var span = $(this).next();
                    span.text("Last Polled: " + moment(lastPollDate).format("DD/MM/YYYY HH:mm:ss Z") + " (" + diffString + ")");
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
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>Automated Downloads</h2>
        <c:forEach items="${dataFeeds}" var="dataFeed">
            <c:if test="${dataFeed.dataFeedSourceSystem.name == 'Argos'}">
                <h3>Argos</h3>
                <p>
                    <input type="hidden" class="lastPollDate"
                           value='<fmt:formatDate pattern="${momentDateTimeFormatPattern}" value="${dataFeed.lastPollDate}"/>'/>
                    <span class="lastPollInfo"></span>
                </p>
                <p>This data feed is set to poll every ${dataFeed.pollFrequencyHours} hour(s).</p>
                <c:if test="${not empty dataFeed.devices}">
                    <table class="table table-bordered table-condensed">
                        <thead>
                        <tr>
                            <th>Platform</th>
                            <th># Detections
                                <div class="help-inline">
                                    <div class="help-popover" title="Argos Detections">Argos sends detection information
                                        from the sensor even if no location was calculated.
                                    </div>
                                </div>
                            </th>
                            <th># Argos Locations
                            </th>
                            <th>Last Detection</th>
                            <th>Raw Data
                                <div class="help-inline">
                                    <div class="help-popover" title="Raw Data from Argos">
                                        The <b>Diagnostic</b> file contains extra information eg nbrMessages,
                                        errorRadius, semiMinor, semiMajor, orientation, hdop (1 row for each detection).<br/>
                                        The <b>Messages</b> file contains raw data for each message and encoded sensor
                                        data (many rows per detection).<br/>
                                        See the Argos User Manual for definitions of the fields in these files.
                                    </div>
                                </div>
                            </th>
                        </tr>
                        </thead>

                        <c:forEach items="${dataFeed.devices}" var="device">
                            <c:set var="locationsCount" value="0"/>
                            <c:set var="lastDetectionDate" value="${device.detections.get(0).detectionDate}"/>
                            <c:forEach items="${device.detections}" var="detection">
                                <c:if test="${not empty detection.locationDate}">
                                    <c:set var="locationsCount" value="${locationsCount + 1}"/>
                                </c:if>
                                <c:set var="timezone" value=" (${detection.timezoneId})"/>
                                <c:if test="${detection.detectionDate > lastDetectionDate}">
                                    <c:set var="lastDetectionDate" value="${detection.detectionDate}"/>
                                </c:if>
                            </c:forEach>
                            <tr>

                                <td>
                                    <div style="width: 12px; height: 12px; background-color: ${device.animal.colour};"/>
                                    <a style="margin-left:20px;"
                                       href="${pageContext.request.contextPath}/projects/${project.id}/animals/${device.animal.id}">${device.deviceIdentifier}</a>
                                </td>
                                <td>${device.detections.size()}</td>
                                <td>${locationsCount}</td>
                                <td><fmt:formatDate pattern="${dateTimeFormatPattern}"
                                                    value="${lastDetectionDate}"/> ${timezone}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/projects/${project.id}/argosraw?deviceId=${device.id}&rtype=diagnostic">Diagnostic</a>
                                    <a href="${pageContext.request.contextPath}/projects/${project.id}/argosraw?deviceId=${device.id}&rtype=messages">Messages</a>
                                </td>

                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:if>
            </c:if>
            <c:if test="${dataFeed.dataFeedSourceSystem.name == 'Spot'}">
                <h3>Spot</h3>
                <p>
                    <input type="hidden" class="lastPollDate"
                           value='<fmt:formatDate pattern="${momentDateTimeFormatPattern}" value="${dataFeed.lastPollDate}"/>'/>
                    <span class="lastPollInfo"></span>
                </p>
                <p>This data feed is set to poll every ${dataFeed.pollFrequencyHours} hour(s).</p>
                <c:if test="${not empty dataFeed.devices}">
                    <table class="table table-bordered table-condensed">
                        <thead>
                        <tr>
                            <th>Device</th>
                            <th># Locations</th>
                            <th>Last Detection</th>
                            <th>Raw Data
                                <div class="help-inline">
                                    <div class="help-popover" title="Raw Data">
                                        Contains raw json data for each device
                                    </div>
                                </div>
                            </th>
                        </tr>
                        </thead>

                        <c:forEach items="${dataFeed.devices}" var="device">
                            <c:set var="locationsCount" value="0"/>
                            <c:set var="lastDetectionDate" value="${device.detections.get(0).detectionDate}"/>
                            <c:forEach items="${device.detections}" var="detection">
                                <c:if test="${not empty detection.locationDate}">
                                    <c:set var="locationsCount" value="${locationsCount + 1}"/>
                                </c:if>
                                <c:set var="timezone" value=" (${detection.timezoneId})"/>
                                <c:if test="${detection.detectionDate > lastDetectionDate}">
                                    <c:set var="lastDetectionDate" value="${detection.detectionDate}"/>
                                </c:if>
                            </c:forEach>
                            <tr>
                                <td>
                                    <div style="width: 12px; height: 12px; background-color: ${device.animal.colour};"/>
                                    <a style="margin-left:20px;"
                                       href="${pageContext.request.contextPath}/projects/${project.id}/animals/${device.animal.id}">${device.deviceIdentifier}</a>
                                </td>
                                <td>${device.detections.size()}</td>
                                <td><fmt:formatDate pattern="${dateTimeFormatPattern}"
                                                    value="${lastDetectionDate}"/> ${timezone}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/projects/${project.id}/spotraw?deviceId=${device.id}">Download</a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:if>
            </c:if>
        </c:forEach>
    </jsp:body>
</tags:page>