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
        &rsaquo; <a href="${pageContext.request.contextPath}/publications">Publications</a>
        &rsaquo; <span class="active">${doi.title}</span>
    </jsp:attribute>
    <jsp:body>
        <style type="text/css">

            .labelName {
                text-align: right;
                font-weight:bold;
            }
            .row {
                padding-top:5px;
                padding-bottom:5px;
            }

        </style>

        <h1><c:out value="${doi.title}"/></h1>

        <div class="span9" id="doi-div">

            <div class="row">
                <div class="span2 labelName">Title:</div><div class="span6"><c:out value="${doi.title} - ZoaTrack Dataset"/></div>
                <div class="span2 labelName">Creators:</div><div class="span6">
                <c:set var="authors" value="${fn:split(doi.creators,',')}"/>
                <c:forEach var="author" items="${authors}">
                    <c:out value="${author}"/><br/>
                </c:forEach>
            </div>
                <div class="span2 labelName">Created Date:</div><div class="span6"><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/></div>
                <div class="span2 labelName">Publisher:</div><div class="span6">Atlas of Living Australia</div>
                <div class="span2 labelName">Publication Date:</div><div class="span6"><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/></div>
                <div class="span2 labelName">Citation:</div><div class="span6"><c:out value="${doi.citation}"/></div>
                <div class="span6 offset2" style="margin-top:10px"><a class="btn" href="${pageContext.request.contextPath}/publication/${doi.uuid}/file">
                    <i class="icon-download icon-white"></i> Download ZIP</a></div>
            </div>
            <div class="row">
                <p>The archive contains 3 files:
                <ul>
                    <li><span style="font-weight: bold">metadata.txt</span>: overall project metadata and ZoaTrack data definitions</li>
                    <li><span style="font-weight: bold">reference.txt</span>: metadata for each animal and tag deployment in the project</li>
                    <li><span style="font-weight: bold">zoatrack-data.csv</span>: detections data exported from the ZoaTrack database</li>
                </ul></p>
            </div>
        </div>
        </div>
    </jsp:body>
</tags:page>