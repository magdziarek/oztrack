<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="datePattern" value="dd/MM/yyyy"/>
<tags:page title="${project.title}: DOI Request">
    <jsp:attribute name="description">
        DOI on the dataset in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="head">
        <style type="text/css">
            .doi-check-icon-td {
                width: 16px;
                height:16px;
                padding-right:5px;
                vertical-align:top;
           }

            hr {
                border-bottom:none;
                margin: 5px 0px 10px 0px;
            }
            .btn-group {
                float:right;
                font-size:11px;
            }
            #doi-checks-div {
                border-radius: 10px;
                margin-left: 0px;
                padding: 8px 8px 0 8px;
                background-color: #e6e6c0;
            }

            .doi-check-table td{
                padding-bottom:10px;
            }

        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');

                var popoverOptions = {
                    content:'These problems need to be resolved before you can apply for a DOI.',
                    title: 'Doi Check',
                    placement:'bottom',
                    trigger:'manual',
                    container:'body'
                };

                $('.no-btn').click(function(e) {
                    $(e.target).addClass("btn-danger");
                    $(e.target).next().removeClass("btn-success");
                    checkReadyForDoi();
                });

                $('.yes-btn').click(function(e) {
                    if ($(e.target).siblings('.doi-ready-check').val() == "true") {
                        $(e.target).popover('destroy');
                        $(e.target).addClass("btn-success");
                        $(e.target).prev().removeClass("btn-danger");
                        checkReadyForDoi();
                    } else {
                        $(e.target).popover(popoverOptions);
                        $(e.target).popover('show');
                    }

                });

                $('html').click(function(e) {
                    if (typeof $(e.target).data('original-title') == 'undefined') {
                        $('[data-original-title]').popover('hide');
                    }
                });


                function checkReadyForDoi() {
                    var readyToGo = true;
                    $('.yes-btn').each( function (i) {
                        if (!$(this).hasClass("btn-success")) readyToGo = false;
                    });
                    <c:forEach items="${doiChecklistMap}" var="check">
                    <c:if test="${check.value eq false}">readyToGo = false;</c:if>
                    </c:forEach>
                    if (readyToGo) {
                        $('#refresh-checklist-btn').hide();
                        $('#build-doi-btn').show();
                    } else {
                        $('#build-doi-btn').hide();
                        $('#refresh-checklist-btn').show();
                    }
                }

                $('#build-doi-btn').click(function() {
                    $('#build-doi-btn').hide();
                    $('#doi-loading').show();
                });

            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <span class="active">DOI Requests</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>You have requested to mint a DOI for this project</h2>

        <p>This will only occur if the data collection satisfies the necessary criteria as set by the Australian National Data
        Service. See the <a href="${pageContext.request.contextPath}/toolkit/doi" target="_blank">Toolkit pages</a> for more
            information about minting DOIs.</p>

        <div class="span6">
        <p style="font-weight:bold">Click 'Yes' to confirm that you agree with each of the statements below.</p>
        <table class="doi-check-table">
            <tr><td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/error.png"/></td>
                <td>You may need to update your project metadata to satisfy the minimum requirements for a DOI application. </td>
        </tr></table>
        </div>

        <div id="doi-checks-div" class="span8">
            <div class="span6">
                <p style="font-weight:bold">These data are to become a citable resource under a Creative Commons Licence and discoverable within Research Data Australia.</p>
            </div>
            <div class="btn-group">
                <btn class="btn no-btn btn-danger">No</btn><btn class="btn yes-btn">Yes</btn>
                <input type="hidden" class="doi-ready-check" value="${doiChecklistMap['access'] && doiChecklistMap['cc_licence']}"/>
            </div>
            <div class="span6">
                <table class="doi-check-table">
                    <tr>
                        <c:if test="${doiChecklistMap['access'] eq true}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                            <td>The data in this project is Open access. </td>
                        </c:if>
                        <c:if test="${doiChecklistMap['access'] eq false}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/cross.png"/></td>
                            <td>
                                <c:if test="${project.access eq 'CLOSED'}">
                                    This project is Closed Access.
                                </c:if>
                                <c:if test="${project.access eq 'EMBARGO'}">
                                    Open access to this data has been delayed until <c:out value="${project.embargoDate}"/>.
                                </c:if>
                                ZoaTrack will only mint a DOI on projects with openly accessible data.
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/edit#accessrights" target="_blank">Edit Project Access</a>
                            </td>
                        </c:if>
                    </tr>
                    <tr>
                        <c:if test="${doiChecklistMap['cc_licence'] eq true}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                            <td>The data in this project is available under a <c:out value="${project.dataLicence.title}"/>
                                (<c:out value="${project.dataLicence.identifier}"/>) licence.
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/edit#datalicence" target="_blank">Edit</a></td>
                            </td>
                        </c:if>
                        <c:if test="${doiChecklistMap['cc_licence'] eq false}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/cross.png"/></td>
                            <td>This data in this project must be available under a CC-BY licence.
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/edit#datalicence" target="_blank">Update licence</a></td>
                            </td>
                        </c:if>
                    </tr>
                </table>
            </div>
            <hr class="span5 offset1"/>


            <div class="span6">
                <p style="font-weight:bold">The published data collection will be closed for perpetuity and cannot be edited, deleted or added to.</p>
            </div>
            <div class="btn-group">
                <btn class="btn no-btn btn-danger">No</btn><btn class="btn yes-btn">Yes</btn>
                <input type="hidden" class="doi-ready-check" value="${doiChecklistMap['data']}"/>
            </div>
            <div class="span6">
                <table class="doi-check-table">
                    <tr>
                        <c:if test="${doiChecklistMap['data'] eq true}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                            <td>There are <c:out value="${project.animals.size()}"/> animal tracks in this project.</td>
                        </c:if>
                        <c:if test="${doiChecklistMap['data'] eq false}">
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/cross.png"/></td>
                            <td>No data has been uploaded. <a href="${pageContext.request.contextPath}/projects/${project.id}/datafiles/new" target="_blank">Upload data</a> </td>
                        </c:if>
                    </tr>
                </table>
           </div>

            <hr class="span5 offset1"/>

            <div class="span6">
                <p style="font-weight:bold">The project authorship is correct.</p>
            </div>
            <div class="btn-group">
                <btn class="btn no-btn btn-danger">No</btn><btn class="btn yes-btn">Yes</btn>
                <input type="hidden" class="doi-ready-check" value="${doiChecklistMap['author_count'] && doiChecklistMap['australian_research']}"/>
            </div>
            <div class="span6">
                <table class="doi-check-table">
                    <c:if test="${doiChecklistMap['author_count'] eq true}">
                        <tr>
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                            <td>The data creators (<a href="${pageContext.request.contextPath}/projects/${project.id}/edit#contributorslist" target="_blank">contributors</a>) listed in your project are:
                                <ol>
                                    <c:forEach items="${project.projectContributions}" var="projectContribution">
                                       <li><c:out value="${projectContribution.contributor.fullName}"/> (<c:out value="${projectContribution.contributor.email}"/>)</li>
                                    </c:forEach>
                                </ol>
                            </td>
                        </tr>
                    </c:if>
                    <c:if test="${doiChecklistMap['author_count'] eq false}">
                        <tr>
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/cross.png"/></td>
                            <td>No data creators have been specified.
                                You need to add <a href="${pageContext.request.contextPath}/projects/${project.id}/edit#contributorslist" target="_blank">project contributors</a>
                                to your project. Note that this is a different list of people to the ZoaTrack users who have read or write
                                access to your project.</td>
                        </tr>
                    </c:if>
                    <c:if test="${doiChecklistMap['australian_research'] eq true}">
                        <tr>
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                            <td>At least one author has an affiliation with an Australian research institution.</td>
                        </tr>
                    </c:if>
                    <c:if test="${doiChecklistMap['australian_research'] eq false}">
                        <tr>
                            <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/cross.png"/></td>
                            <td>No data creators have an affiliation with an Australian research institution. <a href="${pageContext.request.contextPath}/projects/${project.id}/edit#contributorslist" target="_blank">Change</a></td>
                        </tr>
                    </c:if>
                </table>
            </div>
            <hr class="span5 offset1"/>

            <div class="span6">
                <p style="font-weight:bold">Sufficient metadata has been provided at both the project and animal track level to enable a
                third party to reuse the data.</p>
            </div>
            <div class="btn-group">
                <btn class="btn no-btn btn-danger">No</btn><btn class="btn yes-btn">Yes</btn>
                <input type="hidden" class="doi-ready-check" value="true"/>
            </div>
            <div class="span6">
                <table class="doi-check-table">
                    <tr>
                        <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/accept.png"/></td>
                        <td>The overall project metadata was last updated on
                            <fmt:formatDate pattern="${datePattern}" value="${project.updateDate}"/>.<a href="${pageContext.request.contextPath}/projects/${project.id}/edit" target="_blank">Review</a></td>
                    </tr>
                    <tr>
                        <td class="doi-check-icon-td"><img src="${pageContext.request.contextPath}/img/error.png"/></td>
                        <td>Is the metadata for each animal tag deployment ready for publication? <a href="${pageContext.request.contextPath}/projects/${project.id}/animals" target="_blank">Review</a></td>
                    </tr>
                </table>
            </div>
            <div class="span7"></div>
            <div id="doi-action-div" style="float:right; position:relative; display:inline-block; margin-bottom:10px;">
                <a id="refresh-checklist-btn" class="btn btn-primary"
                   href="${pageContext.request.contextPath}/projects/${project.id}/doi">Refresh</a>
                <a id="build-doi-btn" class="btn btn-primary" style="display:none"
                   href="${pageContext.request.contextPath}/projects/${project.id}/doi/new">Build a DOI data package</a>
                <div id="doi-loading" style="display:none;text-align:center">
                    <img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"></div>
            </div>


        </div>



    </jsp:body>
</tags:page>
