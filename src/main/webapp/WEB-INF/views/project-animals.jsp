<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="yyyy-MM-dd HH:mm"/>
<tags:page title="${project.title}: Animals">
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">
        <style type="text/css">

            #zoatrack-datatable-div {
                margin:10px 0;
                font-size:11px;
            }

            #zoatrack-datatable-div select {
                width: 55px;
            }

            table.dataTable thead th, table.dataTable thead td {
                padding: 8px;
                vertical-align: middle;
            }

            table.dataTable thead th {
                background-color: #f5ce7c;
            }


        </style>
    </jsp:attribute>
    <jsp:attribute name="description">
        Listing of animals tracked in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');
                $('#projectMenuAnimals').addClass('active');

                $('#animal-list-table').DataTable({
                    "aLengthMenu": [[5, 10, 50, -1], [5, 10, 50, "All"]],
                    "bProcessing": true,
                    "bDeferRender": true,
                    "aoColumnDefs": [
                        { "bSortable": false, "aTargets": [ 0, 3, 4 ] }
                    ]
                });
                $('#datatable-loading').hide();
                $('#animal-list-table').show();

            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <span class="active">Animals</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:animals-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>Animals</h2>
        <c:if test="${empty projectAnimalsList}">
        <p>
            There are currently no animals in this project.
        </p>
        <sec:authorize access="hasPermission(#project, 'write')">
        <p>
            Animals are created by <a href="${pageContext.request.contextPath}/projects/${project.id}/datafiles/new">uploading a data file</a>.
        </p>
        </sec:authorize>
        </c:if>

        <div class="span6 offset6" id="datatable-loading"><img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"></div>
        <div id="zoatrack-datatable-div">
        <table id="animal-list-table" class="table-condensed table-hover"
                data-page-length='10'
                data-order='[[2, "desc"], [1, "asc"]]'
                style="display:none">
        <thead>
        <tr>
            <th class="span1">ZoaTrack Colour</th>
            <th class="span2">Animal Identifier</th>
            <th class="span2">Last Updated</th>
            <th class="span2"></th>
            <th class="span2"></th>
        </tr>
        </thead>
        <tbody>
            <c:forEach items="${projectAnimalsList}" var="animal">
                <tr>
                    <td><div style="width: 18px; height: 18px; background-color: ${animal.colour};"></div></td>
                    <td><c:out value="${animal.animalName}"/></td>
                    <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${animal.updateDate}"/></td>
                    <td><a href="${pageContext.request.contextPath}/projects/${project.id}/animals/${animal.id}">Summary & Detections</a></td>
                    <td>
                    <sec:authorize access="hasPermission(#project, 'write')">
                        <a href="${pageContext.request.contextPath}/projects/${project.id}/animals/${animal.id}/edit">Edit Metadata</a>
                        <c:if test="${empty animal.positionFixes}">
                            <a href="javascript:void(0);" onclick="OzTrack.deleteEntity(
                                    '${pageContext.request.contextPath}/projects/${project.id}/animals/${animal.id}',
                                    '${pageContext.request.contextPath}/projects/${project.id}/animals',
                                    'Are you sure you want to delete this animal?'
                                    );"><img src="${pageContext.request.contextPath}/img/page_white_delete.png" /></a>
                        </c:if>
                    </sec:authorize>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>
    </jsp:body>
</tags:page>
