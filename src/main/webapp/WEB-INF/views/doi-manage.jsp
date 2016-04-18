<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<%@ page import="org.oztrack.app.OzTrackApplication" %>
<c:set var="baseUrl"><%= OzTrackApplication.getApplicationContext().getBaseUrl() %></c:set>
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
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <span class="active">DOI Request</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:project-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
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

        <h1>DOI Request</h1>

        <c:choose>
            <c:when test="${doi.status == 'DRAFT'}"><c:set var="style" value="warning"/></c:when>
            <c:when test="${doi.status == 'REQUESTED'}"><c:set var="style" value="info"/></c:when>
            <c:when test="${doi.status == 'REJECTED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'FAILED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'COMPLETED'}"><c:set var="style" value="success"/></c:when>
        </c:choose>

        <div class="span9" id="doi-loading" style="display:none; text-align:center">
            <div class="row">
                <img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"><br/>
                <p>Rebuilding package</p>
            </div>
        </div>

        <c:choose>
        <c:when test="${errorMessage != null}">
            <div class="span9" style="text-align:center; color:red">
                <div class="row">
                    <p><c:out value="${errorMessage}"/></p>
                    <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi" >Go back to DOI request</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
        <div id="doi-div">
            <p><c:out value="${doi.status.explanation}"/></p>
            <c:if test="${doi.status == 'DRAFT'}">
              <p>View and edit the project using the links to the left. Once completed, click the Create DOI Request link to rebuild.</p>
            </c:if>
            <div class="span9 sidebar-actions">
                <h2>ZoaTrack Dataset</h2>
                <dl>
                    <dt>Status</dt>
                    <dd><span class="label label-${style}"><c:out value="${doi.status}"/></span>
                        <div class="help-inline">
                            <div class="help-popover" title="${doi.status}">
                                <p><c:out value="${doi.status.shortMessage}"/></p>
                            </div>
                        </div>
                        <c:if test="${doi.status == 'REJECTED'}">
                             <div style="margin: 8px; color:red">Reject Date: <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.rejectDate}"/><br/>
                                Reject Reason: <c:out value="${doi.rejectMessage}"/><br/>
                            </div>
                        </c:if>
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
                    <c:choose>
                        <c:when test="${doi.status != 'COMPLETED'}">
                            <c:set var="fileUrl" value="${pageContext.request.contextPath}/projects/${project.id}/doi/file"/>
                            <dd>TBA</dd>
                        </c:when>
                        <c:when test="${doi.status == 'COMPLETED'}">
                            <c:set var="landingUrl" value="${baseUrl}/publication/${doi.uuid}"/>
                            <c:set var="fileUrl" value="${landingUrl}/file"/>
                            <c:set var="doiUrl" value="http://dx.doi.org/${doi.doi}"/>
                            <dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/></dd>
                            <dt>Landing Page Url</dt>
                            <dd><a href="${landingUrl}" target="_blank">${landingUrl}</a></dd>
                            <dt>Doi Url</dt>
                            <dd><a href="${doiUrl}" target="_blank">${doiUrl}</a></dd>
                        </c:when>
                    </c:choose>

                </dl>
                <a style="margin-bottom:10px" class="btn btn-${style}" href="${fileUrl}">
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
        </div>
        </c:otherwise>
        </c:choose>

        <div id="doi-actions" class="span9">
            <div class="row">
                <c:choose>
                    <c:when test="${doi.status == 'DRAFT' || doi.status == 'REJECTED'}">
                        <div style="float:left">
                            <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi/delete">Delete Request</a>
                        </div>
                        <div style="float:right">
                            <c:if test="${doi.status == 'REJECTED'}"><a id="rebuild-btn" class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi/new" >Rebuild Request</a></c:if>
                            <c:if test="${doi.status == 'DRAFT'}"><a class="btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}/doi/request"> Submit request to mint DOI </a></c:if>
                        </div>
                    </c:when>
                    <c:when test="${doi.status == 'REQUESTED'}">
                        <div style="float:right;">
                            <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi/cancel" >Cancel this DOI Request</a>&nbsp;&nbsp;
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}" > Return to Project </a>
                        </div>
                    </c:when>
                </c:choose>
            </div>
        </div>

    </jsp:body>
</tags:page>