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

                $('#mint-btn').click(function() {
                    $('#admin-buttons').hide();
                    $('#doi-loading').show();
                    //show loading thingy
                });
                $('#reject-btn').click(function() {
                    //hide stuff button
                    //show loading thingy
                });
                $('#xml-btn').click(function(e){
                    $('#doi-xml').fadeToggle();
                })

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

            .doi-status-div {
                padding: 10px 10px;
            }

            .label {

                margin-right:10px;
            }

            .tag{
                width:30%;
                padding-right:10px;
                font-weight:bold;
                vertical-align:top;
            }

        </style>
        <h1><c:out value="${fn:replace(doi.filename, '-zoatrack.zip', '')} Admin"/></h1>

        <c:choose>
            <c:when test="${doi.status == 'DRAFT'}"><c:set var="style" value="warning"/></c:when>
            <c:when test="${doi.status == 'REQUESTED'}"><c:set var="style" value="info"/></c:when>
            <c:when test="${doi.status == 'REJECTED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'FAILED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'COMPLETED'}"><c:set var="style" value="success"/></c:when>
        </c:choose>

        <div class="span10">
            <div class="sidebar-actions doi-status-div">
            <table id="doi-admin-table">
                <tr><td class="tag">Status:</td><td><span class="label label-${style}"><c:out value="${doi.status}"/></span>
                    <a class="btn btn-${style}" style="float:right" href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi/file">
                         Download ZIP </a></td></tr>
                <tr><td class="tag">Title:</td><td><a href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi"><c:out value="${doi.title}"/></a>
                    </td>
                    </tr>
                <tr><td class="tag">Creators:</td><td><c:out value="${doi.creators}"/></td></tr>
                <tr><td class="tag">Landing URL:</td><td><c:out value="${doi.url}"/></td></tr>
                <c:if test="${doi.status == 'COMPLETED'}">
                    <tr><td class="tag">DOI URL:</td><td>http://dx.doi.org/<c:out value = "${doi.doi}"/></td></tr>
                </c:if>
                <tr><td class="tag">Draft Created:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.draftDate}"/></td></tr>
                <tr><td class="tag">Request Submitted:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.submitDate}"/></td></tr>
                <c:if test="${doi.cancelDate != null}">
                    <tr><td class="tag">Request Cancelled:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.cancelDate}"/></td></tr>
                </c:if>
                <c:if test="${doi.rejectDate != null}">
                    <tr><td class="tag">Request Rejected:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.rejectDate}"/> <br/>
                                              Rejection Message: <c:out value="${doi.rejectMessage}"/></td></tr>
                </c:if>
                <c:if test="${doi.mintDate != null}">
                <tr><td class="tag">DOI Minted:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/><br/>
                    <c:out value="${doi.mintResponse}"/></td></tr>
                </c:if>
                <tr><td class="tag">Created:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/> by <c:out value="${doi.createUser.fullName}"/></td></tr>
                <tr><td class="tag">Last Updated:</td><td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.updateDate}"/> by <c:out value="${doi.updateUser.fullName}"/></td></tr>
                <tr><td class="tag">Project Manager:</td><td><c:forEach items="${doi.project.projectUsers}" var="projectUser">
                                                    <c:if test="${projectUser.role == 'MANAGER'}">
                                                        <c:out value="${projectUser.user.fullName}"/>
                                                        (last login <c:out value="${projectUser.user.lastLoginDate}"/>)<br/>
                                                    </c:if>
                                                 </c:forEach>
                <tr><td class="tag">XML:</td><td><a id="xml-btn">View XML ...</a>
                            <div id="doi-xml" style="display:none"><c:out value="${doi.xml}"/></div></td></tr>



                </td></tr>

            </table>

            </div>
        </div>


        <c:choose>
        <c:when test="${doi.status == 'DRAFT'}">
            <div class="row span6 alert-${style}">
                <p>A request to mint a DOI has not been submitted yet. No action is required.</p>
            </div>
        </c:when>
            <c:when test="${doi.status == 'REJECTED'}">
                <div class="row span6 alert-${style}">
                    <p>This request has been rejected by the admin. No action is required until the project manager submits again.</p>
                </div>
            </c:when>
        <c:when test="${(doi.status == 'REQUESTED') || (doi.status == 'FAILED')}">
            <div class="row span6" id="admin-buttons">
                <a id="reject-reason-toggle" class="btn" href="#reject-reason-form">Reject this Request</a>
                &nbsp;&nbsp;<a class="btn btn-primary" id="mint-btn" href="${pageContext.request.contextPath}/settings/doi/${doi.id}/mint" > Mint DOI </a>
            </div>
            <div class="span9" id="doi-loading" style="display:none; text-align:center">
                <div class="row">
                    <img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"><br/>
                    <p>I'm doing it now ...</p>
                </div>
            </div>
            <c:if test="${errorMessage != null}">
                <div class="span6" style="color:red"><p><c:out value="${errorMessage}"/></p></div>
            </c:if>
            <div class="row span6" id="reject-reason-form" style="display: none;">
                <div class="admin-action-div">
                    <form:form method="PUT" action="/settings/doi/${doi.id}/reject" commandName="doi" name="doi" enctype="multipart/form-data">
                        <div style="margin-bottom: 5px;">
                            <label for="reject-reason">Reason for rejection<i class="required-marker">*</i></label>
                            <form:input type="text" id="reject-reason" path="rejectMessage" cssClass="input-xxlarge" placeholder="e.g. This does not seem to be an Australian research project"/>
                        </div>
                        <a id="reject-cancel-btn" class="btn">Cancel</a>
                        <input class="btn" type="submit" id="reject-btn" value="Reject this Request"/>
                    </form:form>
                </div>
            </div>

        </c:when>
        </c:choose>






    </jsp:body>
</tags:page>


