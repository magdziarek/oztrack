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
                $('#rebuild-btn').click(function() {
                    $('#doi-div').hide();
                    $('#doi-actions').hide();
                    $('#doi-loading').show();
                });
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/publication">Publications</a>
        &rsaquo; <span class="active">${doi.title}</span>
    </jsp:attribute>
    <jsp:body>
        <style type="text/css">

            .row {
                padding-top:5px;
                padding-bottom:5px;
            }

            .label {
                margin-right:10px;
            }

            dd {
                margin-bottom:15px;
                margin-left:5px;
            }
        </style>
        <div class="span9 sidebar-actions">
            <h2>ZoaTrack Dataset</h2>
            <dl>
                <dt>Status</dt>
                <dd><span class="label label-success"><c:out value="${doi.status}"/></span>
                    <div class="help-inline">
                        <div class="help-popover" title="${doi.status}">
                            <p><c:out value="${doi.status.shortMessage}"/></p>
                        </div>
                    </div>
                </dd>
                <dt>Citation</dt>
                <dd><c:out value="${doi.citation}"/><c:if test="${doi.status != 'COMPLETED'}"> TBA </c:if></dd>
                <dt>Title</dt>
                <dd><c:out value="${doi.title} - ZoaTrack Dataset"/></dd>
                <dt>Creators</dt>
                <dd><c:set var="authors" value="${fn:split(doi.creators,',')}"/>
                    <c:forEach var="author" items="${authors}">
                        <c:out value="${author}"/><br/>
                    </c:forEach></dd>
                <dt>Created Date</dt>
                <dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/></dd>
                <dt>Publisher</dt>
                <dd>Atlas of Living Australia</dd>
                <dt>Publication Date</dt>
                <dd><c:choose>
                    <c:when test="${doi.status != 'COMPLETED'}">TBA </c:when>
                    <c:when test="${doi.status == 'COMPLETED'}"><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/></c:when>
                </c:choose></dd>
            </dl>
            <a style="margin-bottom:10px" class="btn btn-${style}"
               href="${pageContext.request.contextPath}/projects/${project.id}/doi/file">
                <i class="icon-download icon-white"></i> Download zip</a>
            <div class="help-inline" style="margin-bottom: 5px;">
                <div class="help-popover" title="DOI Zip Package">
                    <p>The zip contains 3 files:</p>
                    <ul>
                        <li><span style="font-weight: bold">metadata.txt</span>: overall project metadata and ZoaTrack data definitions</li>
                        <li><span style="font-weight: bold">reference.txt</span>: metadata for each animal and tag deployment in the project</li>
                        <li><span style="font-weight: bold">zoatrack-data.csv</span>: detections data exported from the ZoaTrack database</li>
                    </ul>
                </div>
            </div>
        </div>

    </jsp:body>
</tags:page>