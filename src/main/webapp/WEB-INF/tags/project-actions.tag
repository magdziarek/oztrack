<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ tag import="org.oztrack.app.OzTrackApplication" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ attribute name="project" type="org.oztrack.data.model.Project" required="true" %>
<%@ attribute name="itemsOnly" type="java.lang.Boolean" required="false" %>
<c:set var="dataSpaceEnabled"><%= OzTrackApplication.getApplicationContext().isDataSpaceEnabled() %></c:set>
<sec:authorize access="hasPermission(#project, 'write')">
<c:if test="${itemsOnly == null || itemsOnly == false}">
<div class="sidebar-actions">
    <div class="sidebar-actions-title">Manage Project</div>
    <ul class="icons sidebar-actions-list">
</c:if>
        <li class="create-file"><a href="${pageContext.request.contextPath}/projects/${project.id}/datafiles/new">Upload data file</a></li>
        <c:if test="${not empty project.dataFiles}">
        <li id="projectActionsCleanse" class="edit-track"><a href="${pageContext.request.contextPath}/projects/${project.id}/cleanse">Edit tracks</a></li>
        </c:if>
        <li class="edit-project"><a href="${pageContext.request.contextPath}/projects/${project.id}/edit">Edit project</a></li>
        <sec:authorize access="hasPermission(#project, 'manage')">
        <c:if test="${dataSpaceEnabled}">
        <li class="publish-project"><a href="${pageContext.request.contextPath}/projects/${project.id}/publish">Publish project</a></li>
        </c:if>
        <c:if test="${empty project.dataSpaceURI}">
        <li class="delete-project"><a href="javascript:void(OzTrack.deleteEntity('${pageContext.request.contextPath}/projects/${project.id}', '${pageContext.request.contextPath}/projects', 'Are you sure you want to delete this project?'));">Delete project</a></li>
        </c:if>
        </sec:authorize>
<c:if test="${itemsOnly == null || itemsOnly == false}">
    </ul>
</div>
</c:if>
</sec:authorize>