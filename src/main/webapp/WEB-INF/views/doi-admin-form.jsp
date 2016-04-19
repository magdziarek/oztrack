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
        <h1>DOI Admin</h1>

        <c:choose>
            <c:when test="${doi.status == 'DRAFT'}"><c:set var="style" value="warning"/></c:when>
            <c:when test="${doi.status == 'REQUESTED'}"><c:set var="style" value="info"/></c:when>
            <c:when test="${doi.status == 'REJECTED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'FAILED'}"><c:set var="style" value="important"/></c:when>
            <c:when test="${doi.status == 'COMPLETED'}"><c:set var="style" value="success"/></c:when>
        </c:choose>
        <div class="span10">
        <div class="sidebar-actions doi-status-div">
            <h2>DOI Details</h2>
            <dl class="dl-horizontal">
                <dt>Status:</dt><dd><span class="label label-${style}" style="margin-bottom:5px">${doi.status}</span></dd>
                <dt>Title:</dt><dd><a target="_blank" href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi">${doi.title}</a></dd>
                <dt>Creators:</dt><dd>${fn:replace(doi.creators,",","<br/>")}</dd>
                <dt>Landing URL:</dt><dd>${doi.url}</dd>
                <dt>DOI URL:</dt><dd>http://dx.doi.org/${doi.doi}</dd>
                <br/>
                <dt>Draft Created:</dt><dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.draftDate}"/></dd>

                <c:if test="${doi.submitDate != null}">
                    <dt>Request Submitted:</dt><dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.submitDate}"/></dd>
                </c:if>
                <c:if test="${doi.cancelDate != null}">
                    <dt>Request Cancelled:</dt><dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.cancelDate}"/></dd>
                </c:if>
                <c:if test="${doi.rejectDate != null}">
                    <dt>Request Rejected:</dt>
                    <dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.rejectDate}"/><br/>
                            ${doi.rejectMessage}
                    </dd>
                </c:if>
                <c:if test="${doi.mintDate != null}">
                    <dt>DOI Minted:</dt>
                    <dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/><br/>
                        <c:out value="${doi.mintResponse}"/></dd>
                </c:if>
                <dt>XML:</dt><dd><a id="xml-btn">View XML ...</a><div id="doi-xml" style="display:none"><c:out value="${doi.xml}"/></div></dd>
                <br/>
                <c:if test="${doi.status != 'COMPLETED'}">
                    <dt> </dt><dd><a class="btn btn-${style}" href="${pageContext.request.contextPath}/projects/${doi.project.id}/doi/file">
                Download ZIP (${fileSize})</a></dd>
                </c:if>
            </dl>

            <h2>Project Details</h2>
            <dl class="dl-horizontal">
                <dt>Last Updated: </dt><dd><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.project.updateDate}"/></dd>
                <dt>Data Licence:</dt><dd>${doi.project.dataLicence.identifier} (${doi.project.dataLicence.title})</dd>
                <dt>Number of animals:</dt><dd>${doi.project.animals.size()}</dd>
                <dt>Contributors:</dt><dd><c:forEach items="${doi.project.projectContributions}" var="projectContribution">
                    ${projectContribution.contributor.fullName}<br/></c:forEach>
                </dd>
                <br/>
                <dt> </dt><dd>
                    <a class="btn btn-${style}" href="${pageContext.request.contextPath}/projects/${doi.project.id}" target="_blank">Metadata</a>
                    <a class="btn btn-${style}" href="${pageContext.request.contextPath}/projects/${doi.project.id}/analysis" target="_blank">Tracks</a>
                </dd>
            </dl>
            <h2>People</h2>
            <table  class="table table-bordered table-striped">
                <th>Role</th>
                <th>Name</th>
                <th>Username</th>
                <th>Email</th>
                <th>Last Login Date</th>
                <tr>
                    <td>DOI Creator</td>
                    <td>${doi.createUser.fullName}</td>
                    <td>${doi.createUser.username}</td>
                    <td>${doi.createUser.person.email}</td>
                    <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createUser.lastLoginDate}"/></td>
                </tr>
                <c:forEach items="${doi.project.projectUsers}" var="projectUser">
                    <tr>
                        <td>${projectUser.role}</td>
                        <td>${projectUser.user.person.fullName}</td>
                        <td>${projectUser.user.username}</td>
                        <td>${projectUser.user.person.email}</td>
                        <td><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${projectUser.user.lastLoginDate}"/></td>
                    </tr>
                </c:forEach>
            </table>

        </div>
        </div>
        <c:if test="${doi.project.updateDate > doi.draftDate}">
            <c:set var="warning" value="Warning! The project has been updated since this draft was created!"/>
        </c:if>
        <c:if test="${not empty doi.rejectDate && doi.draftDate < doi.rejectDate}">
            <c:set var="warning" value="Warning! This DOI draft hasn't been rebuilt since it was rejected."/>
        </c:if>
        <c:if test="${not empty warning}">
            <div class="row span6" style="color:red; font-weight:bold">${warning}</div>
        </c:if>
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


