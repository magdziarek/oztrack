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
        <h2>Request a DOI</h2>
        <!-- need to add that the user agrees to oaipmh -->

        <c:if test="${not empty doiChecklistMap}">
            <c:set var="doiready" value="true"/>
            <p>You can request to mint a DOI on the data in this project if the following criteria are satisfied:</p>

            <c:forEach items="${doiChecklistMap}" var="check">

                <div class="row" style="padding-top:15px">
                    <div class="span7">
                        <c:out value="${check.key.description}"/><br/>
                    </div>
                    <div class="span2">
                        <c:choose>
                            <c:when test="${check.value == true}"> <i class="icon-ok icon-white" style="background-color:green"></i></c:when>
                            <c:otherwise><i class="icon-remove icon-white" style="background-color:red"></i><c:set var="doiready" value="false"/></c:otherwise>
                        </c:choose>
                        <div class="help-inline">
                            <div class="help-popover" title="${check.key.title}"><c:out value="${check.key.requirements}"/></div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <div class="row" style="padding-top:15px">

                <c:choose>
                    <c:when test="${doiready eq true}">
                        <div class="span6">
                            <p>By requesting a DOI package, you agree that the project metadata will be shared with <a href="https://researchdata.ands.org.au/search/#!/group=OzTrack/">Research Data Australia</a>.</p>
                        </div>
                        <div class="span3">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/new">Build a DOI data package</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="span3 offset6">
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/toolkit/doi">How do I fix these?</a>
                        </div>
                    </c:otherwise>

                </c:choose>

            </div>
        </c:if>

    </jsp:body>
</tags:page>
