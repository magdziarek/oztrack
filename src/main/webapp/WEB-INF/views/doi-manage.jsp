<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateTimeFormatPattern" value="dd/MM/yyyy HH:mm:ss"/>
<tags:page title="${project.title}: DOI Request">
        <jsp:attribute name="description">
        Request a DOI on the dataset in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');
            //    $('#doi-loading').hide();
             //   $('#doi-div').show();
             //   $('#doi-actions').show();

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
        <tags:project-actions project="${project}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <style type="text/css">

            .labelName {
                text-align: right;
                font-weight:bold;
            }
            .row {
                padding-top:5px;
                padding-bottom:5px;
            }
            .label {
                padding:5px;
            }

            .well {
                margin-bottom:5px;
            }
        </style>

        <h1>DOI Request</h1>

        <c:choose>
            <c:when test="${doi.status == 'DRAFT'}"><c:set var="labelclass" value="label-warning"/><c:set var="alertclass" value="alert-warning"/></c:when>
            <c:when test="${doi.status == 'REQUESTED'}"><c:set var="labelclass" value="label-info"/><c:set var="alertclass" value="alert-info"/></c:when>
            <c:when test="${doi.status == 'REJECTED'}"><c:set var="labelclass" value="label-important"/><c:set var="alertclass" value="alert-important"/></c:when>
            <c:when test="${doi.status == 'FAILED'}"><c:set var="labelclass" value="label-important"/><c:set var="alertclass" value="alert-important"/></c:when>
            <c:when test="${doi.status == 'COMPLETED'}"><c:set var="labelclass" value="label-success"/><c:set var="alertclass" value="alert-success"/></c:when>
        </c:choose>

        <div class="span9" id="doi-loading" style="display:none; text-align:center">
            <div class="row">
                <img src="${pageContext.request.contextPath}/img/ui-anim_basic_16x16.gif"><br/>
                <p>Rebuilding Archive</p>
            </div>
        </div>

        <div class="span9" id="doi-div">
            <div class="row">
                <div class="well ${alertclass}">
                    <div class="span2"><span class="label ${labelclass}"><c:out value="${doi.status}"/></span></div>
                    <div class="span5" style="font-weight:bold; font-style:larger">http://dx.doi.org/10.4225/01/TBA</div>
                </div>
            </div>

            <div class="row">
                <div class="span6" font-size:larger"><img src="${pageContext.request.contextPath}/img/compress.png"/>
                    <a href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/doi-zip">
                        <c:out value="${doi.filename}"/></a></div>
            </div>
            <div class="row">
                <p>The data files in this archive have been published by ZoaTrack within the Atlas of Living Australia on <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/>.
                    The data is available in the attached files and at the time of publication is available on ZoaTrack (http://zoatrack.org) in the project entitled
                    '<c:out value="${doi.project.title}"/>' at the url <c:out value="${doi.url}"/>.</p>
            </div>
            <div class="row">
                <div class="span2 labelName">Created Date:</div><div class="span6"><fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.createDate}"/></div>
                <div class="span2 labelName">Title:</div><div class="span6"><c:out value="${doi.title} - ZoaTrack Dataset"/></div>
                <div class="span2 labelName">Creators:</div><div class="span6">
                <c:set var="authors" value="${fn:split(doi.creators,',')}"/>
                <c:forEach var="author" items="${authors}">
                    <c:out value="${author}"/></br>
                </c:forEach>
            </div>
                <div class="span2 labelName">Publisher:</div><div class="span6">Atlas of Living Australia</div>
                <div class="span2 labelName">Publication Year:</div><div class="span6"><fmt:formatDate pattern="yyyy" value="${doi.createDate}"/></div>
                <br/>
            </div>
            <div class="row">
                <p>The Citation to be used for this dataset is:<br/>
                    <span style="font-weight: bold"><c:out value="${doi.citation}"/></span></p>
            </div>
            <div class="row">
                <p>The archive, <c:out value="${doi.filename}"/>, contains 3 files:
                <ul>
                    <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'metadata.txt')}"/></span>: overall project
                        metadata and ZoaTrack data definitions</li>
                    <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'reference.txt')}"/></span>: metadata for each animal
                        and tag deployment in the project</li>
                    <li><span style="font-weight: bold"><c:out value="${fn:replace(doi.filename, 'zoatrack.zip', 'zoatrack-data.csv')}"/></span>: project data exported
                        from the ZoaTrack database</li>
                </ul></p>
                <!-- <img src="${pageContext.request.contextPath}/img/compress.png"/>
        <a href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/doi-zip">Download</a>-->
            </div>

            <div class="row">
                <div class="well ${alertclass}">
                    <p style="font-weight:bold">${fn:toUpperCase(fn:substring(doi.status,0 ,1 ))}${fn:toLowerCase(fn:substring(doi.status,1,-1))}
                        Status - What happens next?</p>
                    <p><c:out value="${doi.status.explanation}"/></p>
                    <c:choose>
                        <c:when test="${doi.status == 'REJECTED'}">
                            <p>Rejected on <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.rejectDate}"/><br/>
                                Reason: <c:out value="${doi.rejectMessage}"/></p></c:when>
                        <c:when test="${doi.status == 'COMPLETED'}"><p>Minted on <fmt:formatDate pattern="${dateTimeFormatPattern}" value="${doi.mintDate}"/></p></c:when>
                    </c:choose>
                </div>
            </div>

        </div>


        <div id="doi-actions" class="span9">
            <div class="row">
                <c:choose>
                    <c:when test="${doi.status == 'DRAFT' || doi.status == 'REJECTED'}">
                        <div class="span3">
                            <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/delete">Delete Archive</a>
                        </div>
                        <div class="span3 offset3" style="text-align:right">
                            <a id="rebuild-btn" class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/new" >Rebuild Archive</a>
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/request" > Mint DOI </a>
                        </div>
                    </c:when>
                    <c:when test="${doi.status == 'REQUESTED'}">
                        <div class="span5 offset4" style="text-align:right;">
                            <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/doi-manage/cancel" >Cancel this DOI Request</a>&nbsp;&nbsp;
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}" > Return to Project </a>
                        </div>
                    </c:when>
                </c:choose>
            </div>
        </div>
    </jsp:body>
</tags:page>