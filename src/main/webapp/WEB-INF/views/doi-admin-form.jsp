<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss"/>
<tags:page title="DOI Request Admin">
     <jsp:attribute name="description">
        Admin page for ZoaTrack DOIs
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');
                $('#reject-reason-toggle').click(function(e) {
                    e.preventDefault();
                    $('#reject-reason-form').fadeToggle();
                    $('#admin-buttons').fadeToggle();
                });
                $('#reject-cancel-btn').click(function(e) {
                    e.preventDefault();
                    $('#reject-reason-form').fadeToggle();
                    $('#admin-buttons').fadeToggle();
                });

            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/settings">Settings</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/settings/doi">DOI Admin</a>
        &rsaquo; <span class="active">${doi.project.title}</span>
    </jsp:attribute>
    <jsp:body>
        <style type="text/css">
            .admin-action-div {
                display: inline-block;
                padding: 12px;
                border: 1px solid #ccc;
                border-radius: 4px;
                background-color: #F0F0E2;
                box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.08);
            }

            #doi-admin-table td{
                padding-left:10px;
            }
        </style>
        <h1><c:out value="${fn:replace(doi.filename, '-zoatrack.zip', '')} Admin"/></h1>

        <c:choose>
            <c:when test="${doi.status == 'DRAFT'}"><c:set var="labelclass" value="label-warning"/><c:set var="alertclass" value="alert-warning"/></c:when>
            <c:when test="${doi.status == 'REQUESTED'}"><c:set var="labelclass" value="label-info"/><c:set var="alertclass" value="alert-info"/></c:when>
            <c:when test="${doi.status == 'REJECTED'}"><c:set var="labelclass" value="label-important"/><c:set var="alertclass" value="alert-important"/></c:when>
            <c:when test="${doi.status == 'FAILED'}"><c:set var="labelclass" value="label-important"/><c:set var="alertclass" value="alert-important"/></c:when>
            <c:when test="${doi.status == 'COMPLETED'}"><c:set var="labelclass" value="label-success"/><c:set var="alertclass" value="alert-success"/></c:when>
        </c:choose>

        <div class="span8">
            <div class="well well-large ${alertclass}">
            <table id="doi-admin-table">
                <tr><td>Status:</td><td><span class="label ${labelclass}"><c:out value="${doi.status}"/></span></td><td style="text-align:right"><a href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi-manage/${doi.id}/>">Landing Page</a></td></tr>
                <tr><td>Title:</td><td><c:out value="${doi.title}"/></td><td style="text-align:right"><a href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi-manage/doi-zip>">Download Archive</a></td></tr>
                <tr><td>Creators:</td><td><c:out value="${doi.creators}"/></td></tr>
                <tr><td>Draft Created:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.draftDate}"/></td></tr>
                <tr><td>Request Submitted:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.submitDate}"/></td></tr>
                <tr><td>Request Cancelled:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.cancelDate}"/></td></tr>
                <tr><td>Request Rejected:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.rejectDate}"/><br/>
                                          <c:out value="${doi.rejectMessage}"/></td></tr>
                <tr><td>DOI Minted:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/><br/>
                    <c:out value="${doi.mintResponse}"/></td></tr>
                <tr><td>Created:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/> by <c:out value="${doi.createUser.fullName}"/></td></tr>
                <tr><td>Last Updated:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.updateDate}"/> by <c:out value="${doi.updateUser.fullName}"/></td></tr>
                <tr><td>Project Manager:</td><td><c:forEach items="${doi.project.projectUsers}" var="projectUser">
                                                    <c:if test="${projectUser.role == 'MANAGER'}">
                                                        <c:out value="${projectUser.user.fullName}"/>
                                                        (last login <c:out value="${projectUser.user.lastLoginDate}"/>)
                                                    </c:if>
                                                 </c:forEach>

                </td></tr>

            </table>

            </div>
        </div>


        <c:choose>
        <c:when test="${doi.status == 'DRAFT'}">
            <div class="row span6">
                <p>A request to mint a DOI has not been submitted yet. No action is required.</p>
            </div>
        </c:when>
        <c:when test="${(doi.status == 'REQUESTED') || (doi.status == 'FAILED')}">
            <div class="row span6" id="admin-buttons">
                <a id="reject-reason-toggle" class="btn" href="#reject-reason-form">Reject this Request</a>
                &nbsp;&nbsp;<a class="btn btn-primary" href="${pageContext.request.contextPath}/settings/doi/${doi.id}/mint" > Mint DOI </a>
            </div>

            <div class="row span6" id="reject-reason-form" style="margin-top: 18px; display: none;">
                <div class="admin-action-div">
                    <div style="margin-bottom: 5px;">
                        <label for="reject-reason">Reason for rejection<i class="required-marker">*</i></label>
                        <input type="text" id="reject-reason" class="input-xxlarge" placeholder="e.g. This does not seem to be an Australian research project">
                    </div>
                    <a id="reject-cancel-btn" class="btn">Cancel</a>
                    <a class="btn" href="${pageContext.request.contextPath}/settings/doi/${doi.id}/reject">Reject this Request</a>
                </div>
            </div>

        </c:when>
        </c:choose>






    </jsp:body>
</tags:page>


