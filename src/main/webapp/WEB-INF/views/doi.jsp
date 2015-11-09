<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="yyyy-MM-dd HH:mm:ss"/>
<tags:page title="${project.title}: DOI Requests">
    <jsp:attribute name="description">
        Request a DOI on the dataset in the ${project.title} project.
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
        &rsaquo; <span class="active">DOI Requests</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>DOI Requests</h2>
        <!-- need to add that the user agrees to oaipmh -->
        <!-- need to add that the user agrees to oaipmh -->

        <c:if test="${not empty doiList}">

            <table id="dataFileStatusTable" class="table table-bordered">
            <col style="width: 230px;" />
            <col style="width: 300px;" />
            <col style="width: 100px;" />
            <col style="width: 70px;" />
            <thead>
            <tr>
                <th>DOI</th>
                <th>Status</th>
                <th>Last Updated</th>
                <th>Created Date</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${doiList}" var="doi">
                <tr>
                    <td><a href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi/${doi.id}">
                        <c:out value="${doi.doi}"></c:out></a></td>
                    <td><c:out value="${doi.status}"></c:out></td>
                    <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/></td>
                    <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.updateDate}"/></td>
                </tr>
            </c:forEach>
            </tbody>
            </table>
        </c:if>

    </jsp:body>
</tags:page>
