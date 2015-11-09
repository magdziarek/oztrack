<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss"/>
<tags:page title="${project.title}: DOI Request">
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

        <div class="row">
            <div class="span5">
                <h2>DOI Request</h2>
        Created Date: <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/><br/>
        Title: <c:out value="${project.title} - ZoaTrack Dataset"/><br/>
        Creators: <c:forEach items="${project.projectContributions}" var="projectContribution">
        <c:out value="${projectContribution.contributor.firstName} ${projectContribution.contributor.lastName}"/>
        </c:forEach><br/>
        Publisher: Atlas of Living Australia<br/>
        Publication Year: <fmt:formatDate pattern="yyyy" value="${doi.createDate}"/><br/><br/>
                </div>
                <div class="span4">
                    <div class="alert alert-warning">
                        <span class="label label-important">Status: <c:out value="${doi.status}"/></span><br/>
                        <p><c:out value="${doi.status.explanation}"/></p>
                        <a href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/doi-zip">
                            <i class="icon-download"></i>&nbsp;&nbsp;Download</a><br/>
                        <a href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/delete">
                            <i class="icon-remove"></i>&nbsp;&nbsp;Remove</a><br/>
                        <a href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/new">
                            <i class="icon-repeat"></i>&nbsp;&nbsp;Rebuild</a><br/>
                </div>
                </div>
            </div>
        <div class="row">
            <div class="span9"/>
        <p>The Citation to be used for this dataset is:<br/>
        <span style="font-weight: bold"><c:out value="${doi.citation}"/></span></p>

        <p>The data files in this package have been published by ZoaTrack within the Atlas of Living Australia on <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/>.
        The data is available in the attached files and at the time of publication is available on ZoaTrack (http://zoatrack.org) in the project entitled
        '<c:out value="${project.title}"/>' at the url <c:out value="${doi.url}"/>.</p>

        <p>The archive, <c:out value="${doi.filename}"/>, contains 3 files:
        <ul>
            <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'metadata.txt')}"/></span>: overall project
            metadata and ZoaTrack data definitions</li>
            <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'reference.txt')}"/></span>: metadata for each animal
            and tag deployment in the project</li>
            <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'zoatrack-data.csv')}"/></span>: project data exported
            from the ZoaTrack database</li>
        </ul></p>

            </div>
            </div>




    </jsp:body>
</tags:page>