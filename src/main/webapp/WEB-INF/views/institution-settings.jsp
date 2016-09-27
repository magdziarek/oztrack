<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy"/>
<tags:page title="Settings">
    <jsp:attribute name="description">
        Update institution records in ZoaTrack.
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/settings">Settings</a>
        &rsaquo; <span class="active">Institutions</span>
    </jsp:attribute>
    <jsp:attribute name="head">
           <style type="text/css">
                #institution-list-table_length {
                    float: right;
                }

                #institution-list-table_filter {
                    float: left;
                }
            </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/oztrack.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {

                $('#institution-list-table').DataTable({
                    "aLengthMenu": [[5, 10, 50, -1], [5, 10, 50, "All"]],
                    "bProcessing": true,
                    "bDeferRender": true,
                    "aoColumnDefs": [
                        { "bSortable": false, "aTargets": [ 6 ] }
                    ]
                });
                $('#datatable-loading').hide();
                $('#institution-list-table').show();

            });
        </script>
    </jsp:attribute>
    <jsp:body>
        <h1>Institutions</h1>

        <div class="span9 offset3" id="datatable-loading"><img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"></div>
        <div id="zoatrack-datatable-div">
            <table id="institution-list-table" class="table-condensed table-hover"
                   data-page-length='30'
                   data-order='[[0, "desc"]]'
                   style="display:none">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Domain</th>
                    <th>Country</th>
                    <th>Last Updated</th>
                    <th>Nbr Peeps</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${institutions}" var="institution">
                    <tr>
                        <td>${institution.id}</td>
                        <td>${institution.title}</td>
                        <td>${institution.domainName}</td>
                        <td>${institution.country.title}</td>
                        <td>
                            <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${institution.updateDate}"/>
                            <c:if test="${institution.updateDate == null}">
                                <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${institution.createDate}"/>
                            </c:if>
                        </td>
                        <td>${institution.people.size()}</td>
                        <td><a class="btn" href="${pageContext.request.contextPath}/institutions/${institution.id}/edit">Edit</a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </jsp:body>
</tags:page>