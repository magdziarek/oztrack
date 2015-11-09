<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateFormatPattern" value="yyyy-MM-dd"/>
<tags:page title="${project.title}: '${animal.animalName}'">
    <jsp:attribute name="description">
        Animal '${animal.animalName}' in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="head">
        <style type="text/css">
            .animalInfoLabel {
                text-align: right;
                font-weight:bold
            }
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');
                $('#animalActionsView').addClass('active');
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}/animals">Animals</a>
        &rsaquo; <span class="active">${animal.animalName}</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:animal-actions animal="${animal}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <h2>Animal Details</h2>

        <div class="row">
            <div class="span6" >
                <table>
                    <tr>
                        <td style="padding: 5px 5px 0 0; vertical-align: top;">
                            <div style="width: 18px; height: 18px; background-color: ${animal.colour};"></div>
                        </td>
                        <td style="padding: 5px 5px 0 5px; vertical-align: top;">
                            <p>
                                <span style="font-weight: bold; color: #333;"><c:out value="${animal.animalName}"/></span>
                            </p>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <c:if test="${not empty project.speciesScientificName}">
            <div class="row">
                <div class="span3 animalInfoLabel">Species</div>
                <div class="span6">
                    <c:if test="${not empty project.speciesScientificName}"><span style="font-style:italic"><c:out value="${project.speciesScientificName}"/></span>
                        <c:if test="${not empty project.speciesCommonName}">
                            <br />
                        </c:if>
                    </c:if>
                    <c:if test="${not empty project.speciesCommonName}">
                        <c:set var="commonNameList" value="${fn:split(project.speciesCommonName,',')}"/>
                        <c:out value="${commonNameList[0]}"/>
                    </c:if>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty animal.sex}">
            <div class="row">
                <div class="span3 animalInfoLabel">Sex</div><div class="span6"><c:out value="${animal.sex}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.weight}">
            <div class="row">
                <div class="span3 animalInfoLabel">Body Weight</div><div class="span6"><c:out value="${animal.weight}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.dimensions}">
            <div class="row">
                <div class="span3 animalInfoLabel">Dimensions</div><div class="span6"><c:out value="${animal.dimensions}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.lifePhase}">
            <div class="row">
                <div class="span3 animalInfoLabel">Life Phase</div><div class="span6"><c:out value="${animal.lifePhase}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.animalDescription}">
            <div class="row">
                <div class="span3 animalInfoLabel">Description</div><div class="span6"><c:out value="${animal.animalDescription}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagIdentifier}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Identifier</div><div class="span6"><c:out value="${animal.tagIdentifier}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagManufacturerModel}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Manufacturer/Model</div><div class="span6"><c:out value="${animal.tagManufacturerModel}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.captureDate}">
            <div class="row">
                <div class="span3 animalInfoLabel">Capture</div><div class="span6">
                    <fmt:formatDate pattern="${dateFormatPattern}" value="${animal.captureDate}"/>
                    <c:if test="${not empty animal.captureGeometry}"> (<c:out value="${animal.captureLatitude}"/>,<c:out value="${animal.captureLongitude}"/>)</c:if>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty animal.releaseDate}">
            <div class="row">
                <div class="span3 animalInfoLabel">Release</div><div class="span6">
                    <c:out value="${animal.releaseDate}"/>
                    <c:if test="${not empty animal.releaseGeometry}"> (<c:out value="${animal.releaseLatitude}"/>,<c:out value="${animal.releaseLongitude}"/>)</c:if>
            </div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagDeployStartDate}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Deployment Start</div><div class="span6"><c:out value="${animal.tagDeployStartDate}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagDeployEndDate}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Deployment End</div><div class="span6"><c:out value="${animal.tagDeployEndDate}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.stateOnDetachment}">
            <div class="row">
                <div class="span3 animalInfoLabel">Animal state on tag detachment</div><div class="span6"><c:out value="${animal.stateOnDetachment}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.experimentalContext}">
            <div class="row">
                <div class="span3 animalInfoLabel">Experimental Context</div><div class="span6"><c:out value="${animal.experimentalContext}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagAttachmentTechnique}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Attachment Technique</div><div class="span6"><c:out value="${animal.tagAttachmentTechnique}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagDimensions}">
            <div class="row">
                <div class="span3 animalInfoLabel">Tag Dimensions</div><div class="span6"><c:out value="${animal.tagDimensions}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagDutyCycleComments}">
            <div class="row">
                <div class="span3 animalInfoLabel">Duty Cycle</div><div class="span6"><c:out value="${animal.tagDutyCycleComments}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.dataRetrievalMethod}">
            <div class="row">
                <div class="span3 animalInfoLabel">Data Retrieval Methods</div><div class="span6"><c:out value="${animal.dataRetrievalMethod}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.dataManipulation}">
            <div class="row">
                <div class="span3 animalInfoLabel">Data Manipulation Techniques</div><div class="span6"><c:out value="${animal.dataManipulation}"/></div>
            </div>
        </c:if>
        <c:if test="${not empty animal.tagDeploymentComments}">
            <div class="row">
                <div class="span3 animalInfoLabel">Additional Comments</div><div class="span6"><c:out value="${animal.tagDeploymentComments}"/></div>
            </div>
        </c:if>

        <sec:authorize access="hasPermission(#animal.project, 'write')">
        <c:if test="${not empty animal.createDescription}">
        <p style="color: #666;">
            ${animal.createDescription}
        </p>
        </c:if>
        </sec:authorize>
        <tags:search-results positionFixPage="${positionFixPage}" individualAnimal="true" includeDeleted="false"/>
    </jsp:body>
</tags:page>
