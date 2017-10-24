<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss z"/>
<tags:page title="${project.title}: Automated Downloads">
    <jsp:attribute name="description">
        Automated downloads into the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function () {
                $('#navTrack').addClass('active');
                $('#dataActionsDataFeeds').addClass('active');
            });
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
                <p>Last Polled: <fmt:formatDate pattern="${dateTimeFormatPattern}"
                                                value="${dataFeed.lastPollDate}"/></p>
                <p>Next Poll: <fmt:formatDate type="date" pattern="${dateTimeFormatPattern}"
                                              value="${dataFeed.nextPollDate}"/></p>
                <c:if test="${not empty dataFeed.devices}">
                    <table class="table table-bordered table-condensed">
                        <thead>
                        <tr>
                            <th></th>
                            <th>Platform</th>
                            <th># Detections</th>
                            <th># Locations</th>
                            <th>Last Detection Date</th>
                            <th>Raw Data</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${dataFeed.devices}" var="device">

                            <c:set var="locationsCount" value="0"/>
                            <c:forEach items="${device.detections}" var="detection">
                                <c:if test="${not empty detection.locationDate}">
                                    <c:set var="locationsCount" value="${locationsCount + 1}"/>
                                </c:if>
                            </c:forEach>

                            <tr>
                                <td>
                                    <div style="width: 15px; height: 15px; background-color: ${device.animal.colour};"></div>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/projects/${project.id}/animals/${device.animal.id}">${device.deviceIdentifier}</a>
                                </td>
                                <td>${device.detections.size()}</td>
                                <td>${locationsCount}</td>
                                <td><fmt:formatDate type="date" pattern="${dateTimeFormatPattern}"
                                                    value="${device.lastDetectionDate}"/></td>
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
        </c:forEach>
    </jsp:body>
</tags:page>