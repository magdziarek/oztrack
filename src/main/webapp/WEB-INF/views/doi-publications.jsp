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
                $('#navPub').addClass('active');

                $('#published-doi-table').DataTable({
                    "aLengthMenu": [[5, 10, -1], [5, 10, "All"]],
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
               data-order='[[0, "asc"], [3, "desc"]]'
               style="display:none">
            <thead>
            <tr>
                <th class="span2">DOI</th>
                <th class="span4">Project Title</th>
                <th class="span3">Dataset Creators</th>
                <th class="span2">Publication Date</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${doiList}" var="doi">
                <c:if test="${not empty doiList}">
                    <c:set var="doiUrl" value="${pageContext.request.contextPath}/publication/${doi.uuid}"/>
                    <tr class="clickable-row" data-url="${doiUrl}">
                        <td style="font-weight:bold"><c:out value="${doi.doi}"/></td>
                        <td><c:out value="${doi.project.title}"/></td>
                        <td><c:set var="authors" value="${fn:split(doi.creators,',')}"/>
                            <c:forEach var="author" items="${authors}">
                                <c:out value="${author}"/><br/>
                            </c:forEach>
                        </td>
                        <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/></td>
                    </tr>
                </c:if>
            </c:forEach>
            </tbody>
        </table>

    </jsp:body>
</tags:page>
