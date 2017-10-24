<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ attribute name="project" type="org.oztrack.data.model.Project" required="true" %>
<sec:authorize access="hasPermission(#project, 'write')">
<div class="sidebar-actions">
    <div class="sidebar-actions-title">Manage Animals</div>
    <ul class="icons sidebar-actions-list">
        <li class="create-file"><a href="${pageContext.request.contextPath}/projects/${project.id}/datafiles/new">Upload data file</a></li>
        <c:if test="${not empty project.dataFeeds}">
            <li id="dataActionsDataFeeds" class="datafeed-manage"><a
                    href="${pageContext.request.contextPath}/projects/${project.id}/datafeed">Automated downloads</a>
            </li>
        </c:if>
        <c:if test="${not empty project.animals}">
        <li class="edit-track"><a href="${pageContext.request.contextPath}/projects/${project.id}/cleanse">Edit tracks</a></li>
        </c:if>
    </ul>
</div>
</sec:authorize>