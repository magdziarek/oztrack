<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>

<tags:page>
    <jsp:attribute name="description">
        ZoaTrack is a free-to-use web-based platform for analysing and visualising
        individual-based animal location data. Upload your tracking data now.
    </jsp:attribute>
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">
        <style type="text/css">
            #welcome{
                background-color: #e6e6c0;
                padding: 6px;
                -khtml-border-radius: 8px;
                -webkit-border-radius: 8px;
                -moz-border-radius: 8px;
                -ms-border-radius: 8px;
                -o-border-radius: 8px;
                border-radius: 8px;
                margin-left:10px;
            }

            #homeMap{
                height:300px;
                background-color: #e6e6c0;
            }

            #map-instructions-container {
                position: relative;
                z-index: 1100;
            }
            #map-instructions {
                position: absolute;
                margin:2px 2px;
                background-color: white;
                opacity: 0.7;
                text-align: center;
                font-size: 12px;
                padding: 5px;
                -khtml-border-radius: 5px;
                -webkit-border-radius: 5px;
                -moz-border-radius: 5px;
                -ms-border-radius: 5px;
                -o-border-radius: 5px;
                border-radius: 5px;
            }
            .home-popup {
                margin-top: 0;
                padding: 0 10px;
                width: 400px;
            }
            .home-popup-title {
                margin-bottom: 1em;
                font-size: 15px;
                font-weight: bold;
            }
            .home-popup-attr-name {
                font-weight: bold;
                margin-bottom: 0.25em;
            }
            .home-popup-attr-value {
                margin-bottom: 0.75em;
            }
            .home-popup-footer {
                margin-top: 1em;
            }

            #welcome-table {
                background-color: #e6e6c0;
                font-size: 11px;
            }
            #welcome-table h1 {
                font-size: 13px;
                margin: 4px 0px;
            }

            #blog-table td a {
                text-decoration: none;
            }

            #blog-table td {
                padding-top:15px;
                padding-bottom:15px;
            }

            a.morelink {
                text-decoration:none;
                outline: none;
                color: #aaaaaa;
            }
            .morecontent span {
                display: none;
            }

            #project-list-div {
                margin:10px 0;
            }

            #project-list-div{
                font-size:11px;
            }

            #project-list-div select {
                width: 50px;
            }

            #project-list-div label, input, button, select, textarea {
                font-size: 11px;
            }

            table.dataTable thead th, table.dataTable thead td {
                padding: 0px 8px;
                vertical-align: middle;
            }


            tr.clickable-row { cursor: pointer; }

            #createprojectbutton {
                position:absolute;
                padding: 2px 20px;
                margin-left:200px;
            }

            #projects-table_length {
                float: right;
            }

            #projects-table_filter {
                float: left;
            }

        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script src="${pageContext.request.scheme}://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/openlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/home.js"></script>
        <script type="text/javascript">


            $(document).ready(function() {

                $('#navBrowse').addClass('active');

                $(".clickable-row").click(function() {
                    window.document.location = $(this).data('url');
                });

                var showChar = 50;
                var ellipsestext = "...";
                var moretext = "more";
                var lesstext = "less";

                $('.more').each(function() {

                    var content = $(this).html();
                    if(content.length > showChar) {

                        var c = content.substr(0, showChar);
                        var h = content.substr(showChar, content.length - showChar);

                        var html = c + '<span class="moreellipses">' + ellipsestext + ' </span>' +
                                '<span class="morecontent"><span>' + h +
                                '</span>  <a href="" class="morelink">' + moretext + '</a></span>';

                        $(this).html(html);
                    }
                });

                $(".morelink").click(function(){
                    if($(this).hasClass("less")) {
                        $(this).removeClass("less");
                        $(this).html(moretext);
                    } else {
                        $(this).addClass("less");
                        $(this).html(lesstext);
                    }
                    $(this).parent().prev().toggle();
                    $(this).prev().toggle();
                    return false;
                });

                $('#projects-table').DataTable({
                   "aLengthMenu": [[5, 10, 50, -1], [5, 10, 50, "All"]],
                    //"pageLength": 5,
                    "aoColumnDefs": [
                        // null,
                        // {"aTargets":[1], "mRender": function (data, type, row) { return ;}},
                        //    null,
                        {"aTargets":[4],"iDataSort" : 5 },
                        {"aTargets":[5],"bVisible": false},
                        {"aTargets":[0],"bVisible": false}
                    ],
                    "sDom": '<"H"f<"#createprojectbuttonarea">lr>t<"F"ip>',
                    "bProcessing": true,
                    "bDeferRender": true
                } );
                $( "#createprojectbuttonarea" ).html('<button id="createprojectbutton">Create a new ZoaTrack Project</button>');
                $("#createprojectbutton").click( function () {
                    window.document.location = "${pageContext.request.contextPath}/projects/new"
                });
                $('#table-loading').hide();
                $('#projects-table').show();
                map = createHomeMap('homeMap');


            });

        </script>
    </jsp:attribute>

    <jsp:body>
        <div class="row">
        <div class="span12" id="welcome">
            <div class="span12" id="homeMap">
                <div id="map-instructions-container">
                    <div id="map-instructions">
                        Click markers to view project details
                    </div>
                </div>
            </div>

            <div class="span12" id="project-list-div">
                <div class="span6 offset6" id="table-loading"><img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"></div>
                <table id="projects-table" class="table table-condensed table-hover"
                       data-page-length='5'
                       data-order='[[0, "desc"], [4, "desc"],[ 1, "desc" ]]'
                       style="display:none" >
                    <thead>
                    <tr>
                        <th></th>
                        <th class="span3">Title</th>
                        <th class="span3">Species</th>
                        <th class="span2">Spatial Coverage</th>
                        <th class="span1">Updated Date</th>
                        <th>Sortable Date</th>
                        <th class="span2">Access Type</th>
                        <c:if test="${currentUser != null}"><th>Role</th></c:if>
                        <th class="span1"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${projects}" var="project">
                        <c:set var="userAccessToTracks" value='false'/>
                        <c:set var="projectUrl" value="${pageContext.request.contextPath}/projects/${project.id}"/>
                        <c:set var="userRole" value=""/>
                        <c:forEach items="${project.projectUsers}" var="projectUser">
                            <c:if test="${(currentUser != null && projectUser.user == currentUser) || project.access == 'OPEN'}">
                                <c:set var="userAccessToTracks" value="true"/>
                                <c:set var="projectUrl" value="${pageContext.request.contextPath}/projects/${project.id}/analysis"/>
                                <c:if test="${(currentUser != null && projectUser.user == currentUser)}">
                                    <c:set var="userRole" value="${projectUser.role.title}"/>
                                </c:if>
                            </c:if>
                        </c:forEach>
                        <tr class="clickable-row" data-url="${projectUrl}">
                            <td>
                                <c:choose>
                                    <c:when test="${userRole == 'Manager'}">1003</c:when>
                                    <c:when test="${userRole == 'Writer'}">1002</c:when>
                                    <c:when test="${userRole == 'Reader'}">1001</c:when>
                                    <c:when test="${project.id == 1 || project.id == 3}">900</c:when>
                                    <c:when test="${project.access == 'OPEN'}">800</c:when>
                                </c:choose>
                            </td>
                            <td><c:out value="${project.title}"/></td>
                            <td><c:if test="${project.speciesScientificName != null}">
                                <span style="font-style: italic"><c:out value="${project.speciesScientificName}"/></span><br/>
                            </c:if>
                                <span class="more"><c:out value="${project.speciesCommonName}"/></span></td>
                            <td><c:out value="${project.spatialCoverageDescr}"/></td>
                            <td><fmt:formatDate value="${project.updateDate}" type="date" pattern="dd/MM/yyyy"/></td>
                            <td><fmt:formatDate value="${project.updateDate}" type="date" pattern="yyyyMMdd" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${project.access == 'OPEN'}">Open Access<br/></c:when>
                                    <c:when test="${project.access == 'CLOSED'}">Closed Access<br/></c:when>
                                    <c:when test="${project.access == 'EMBARGO'}">Delayed Access<br/></c:when>
                                </c:choose></td>
                            <c:if test="${currentUser != null}">
                                <td>
                                    <c:if test="${userRole != ''}"><c:out value="${userRole}"/></c:if>
                                </td></c:if>
                            <td><c:choose>
                                <c:when test="${userAccessToTracks == 'true'}">
                                    <span class="label label-success">Tracks</span></c:when>
                                <c:otherwise>
                                    <span class="label label-info">Metadata</span></c:otherwise>
                            </c:choose></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
     </jsp:body>
</tags:page>
