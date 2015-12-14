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
        ZoaTrack DOI Administration
    </jsp:attribute>
    <jsp:attribute name="head">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">
    <style type="text/css">

        #doi-list-div{
            font-size:11px;
            margin:10px 0;
        }

        #doi-list-div label, input, button, select, textarea {
            font-size: 11px;
        }
        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 8px;
            vertical-align: middle;
        }

        tr.clickable-row { cursor: pointer; }

    </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/doi-admin.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');

                $('#published-doi-table').DataTable({
                    "aLengthMenu": [[5, 10, 50, -1], [5, 10, 50, "All"]],
                    "bProcessing": true,
                    "bDeferRender": true
                });
                $('#doi-admin-table-loading').hide();
                $('#published-doi-table').show();

                $(".clickable-row").click(function() {
                    window.document.location = $(this).data('url');
                });
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <span class="active">Publications</span>
    </jsp:attribute>
    <jsp:body>
        <h1>ZoaTrack Dataset Publications</h1>

        <div class="span12" id="doi-list-div">
        <div class="span6 offset6" id="doi-admin-table-loading"><img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"></div>
        <table id="published-doi-table" class="table table-condensed table-hover"
               data-page-length='10'
               data-order='[[0, "asc"], [4, "desc"]]'
               style="display:none">
            <thead>
            <tr>
                <th class="span1">Status</th>
                <th class="span2">DOI</th>
                <th class="span3">Project Title</th>
                <th class="span2">Requested By</th>
                <th class="span2">Created Date</th>
                <th class="span2">Last Updated Date</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${doiList}" var="doi">
                <c:if test="${not empty doiList}">
                    <c:set var="doiUrl" value="${pageContext.request.contextPath}/publication/${doi.uuid}"/>
                    <c:choose>
                        <c:when test="${doi.status == 'DRAFT'}"><c:set var="labelclass" value="label-warning"/></c:when>
                        <c:when test="${doi.status == 'REQUESTED'}"><c:set var="labelclass" value="label-info"/></c:when>
                        <c:when test="${doi.status == 'REJECTED'}"><c:set var="labelclass" value="label-important"/></c:when>
                        <c:when test="${doi.status == 'FAILED'}"><c:set var="labelclass" value="label-important"/></c:when>
                        <c:when test="${doi.status == 'COMPLETED'}"><c:set var="labelclass" value="label-success"/></c:when>
                    </c:choose>

                    <tr class="clickable-row" data-url="${doiUrl}">
                        <td><span class="label ${labelclass}"><c:out value="${doi.status}"/></span></td>
                        <td><c:out value="${doi.doi}"/></td>
                        <td><c:out value="${doi.project.title}"/></td>
                        <td><c:out value="${doi.updateUser.fullName}"/></td>
                        <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/></td>
                        <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.updateDate}"/></td>
                    </tr>
                </c:if>
            </c:forEach>
            </tbody>
        </table>

    </jsp:body>
</tags:page>
