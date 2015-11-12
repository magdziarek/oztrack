<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<c:set var="dateFormatPattern" value="yyyy-MM-dd"/>
<tags:page title="${project.title}: Update '${animal.animalName}'">
    <jsp:attribute name="description">
        Update animal '${animal.animalName}' in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/farbtastic.css" type="text/css" />
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/farbtastic.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navTrack').addClass('active');
                $('#animalActionsEdit').addClass('active');
                $('#colorpicker').farbtastic('#colour');
                $('#captureDateVisible').datepicker({
                    altField: "#captureDate",
                    defaultDate: new Date(${projectDetectionDateRange.minimum.time})
                });
                $('#releaseDateVisible').datepicker({
                    altField: "#releaseDate",
                    defaultDate: new Date(${projectDetectionDateRange.minimum.time})
                });
                $('#tagDeployStartDateVisible').datepicker({
                    altField: "#tagDeployStartDate",
                    defaultDate: new Date(${projectDetectionDateRange.minimum.time})
                });
                $('#tagDeployEndDateVisible').datepicker({
                    altField: "#tagDeployEndDate",
                    defaultDate: new Date(${projectDetectionDateRange.minimum.time})
                });
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects">Projects</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}">${project.title}</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}/animals">Animals</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/projects/${project.id}/animals/${animal.id}">${animal.animalName}</a>
        &rsaquo; <span class="active">Edit</span>
    </jsp:attribute>
    <jsp:attribute name="sidebar">
        <tags:project-menu project="${project}"/>
        <tags:animal-actions animal="${animal}"/>
        <tags:project-licence project="${project}"/>
    </jsp:attribute>
    <jsp:body>
        <h1 id="projectTitle"><c:out value="${project.title}"/></h1>
        <form:form cssClass="form-horizontal form-bordered" action="/projects/${project.id}/animals/${animal.id}" commandName="animal" method="PUT">
            <fieldset>
            <div class="legend">Animal details</div>
            <div class="control-group required">
                <label class="control-label" for="projectAnimalId">Animal ID</label>
                <div class="controls">
                    <form:input path="projectAnimalId" id="projectAnimalId"/>
                    <span class="help-inline">
                        <form:errors path="projectAnimalId" cssClass="formErrors"/>
                    </span>
                </div>
            </div>
            <div class="control-group required">
                <label class="control-label" for="animalName">Name</label>
                <div class="controls">
                    <form:input path="animalName" id="animalName"/>
                    <span class="help-inline">
                        <form:errors path="animalName" cssClass="formErrors"/>
                    </span>
                </div>
            </div>

            <div class="control-group required">
                <label class="control-label" for="colour">ZoaTrack Colour</label>
                <div class="controls">
                    <form:input path="colour" id="colour"
                        onclick="$('#colorpicker').fadeIn();"
                        onfocus="$('#colorpicker').fadeIn();"
                        onblur="$('#colorpicker').fadeOut();"
                        style="background-color: ${animal.colour};"/>
                    <div id="colorpicker" style="display: none; position: absolute; padding: 10px 13px 0 13px;"></div>
                    <input type="hidden" id="oldColour" name="oldColour" value="${animal.colour}"/>
                    <span class="help-inline">
                        <form:errors path="colour" cssClass="formErrors"/>
                    </span>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="sex">Sex</label>
                <div class="controls">
                    <label class="radio inline"><form:radiobutton path="sex" value="Female"/> Female </label>
                    <label class="radio inline"><form:radiobutton path="sex" value="Male"/> Male </label>
                    <label class="radio inline"><form:radiobutton path="sex" value="Unspecified"/> Unspecified </label>
                    <form:errors path="sex" element="div" cssClass="help-block formErrors"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="weight">Body Weight</label>
                <div class="controls">
                    <form:input path="weight" id="weight" cssClass="input-xxlarge" placeholder="Enter weight with units"/>
                    <div class="help-inline">
                        <div class="help-popover" title="Body Weight">
                            The weight of the animal. Please specify the units of measurement.
                        </div>
                    </div>
                    <form:errors path="weight" element="div" cssClass="help-block formErrors"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="dimensions">Dimensions</label>
                <div class="controls">
                    <form:input path="dimensions" id="dimensions" cssClass="input-xxlarge" placeholder="e.g. height, width, snout length, wing span"/>
                    <div class="help-inline">
                        <div class="help-popover" title="dimensions">
                            Any useful dimensions you have recorded for the animal. Specify the measurement units.
                        </div>
                    </div>
                    <form:errors path="dimensions" element="div" cssClass="help-block formErrors"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="lifePhase">Life Phase</label>
                <div class="controls">
                    <form:input path="lifePhase" id="lifePhase" cssClass="input-xxlarge" placeholder="e.g. hatchling, newborn, chick, juvenile, sub-adult, adult, or specify age"/>
                    <div class="help-inline">
                        <div class="help-popover" title="Life Phase">
                            Describe the lifephase of the animal, e.g. hatchling, newborn, chick, juvenile, sub-adult, adult; or describe the age of the animal, including units (days, months, years).
                        </div>
                    </div>
                    <form:errors path="lifePhase" element="div" cssClass="help-block formErrors"/>
                </div>
            </div>
                <div class="control-group">
                    <label class="control-label" for="animalDescription">Comments</label>
                    <div class="controls">
                        <form:textarea style="width: 400px; height: 50px;" path="animalDescription" id="animalDescription" placeholder="Any other useful details about the animal"/>
                    <span class="help-inline">
                        <form:errors path="animalDescription" cssClass="formErrors"/>
                    </span>
                    </div>
                </div>
            </fieldset>
            <fieldset>
            <div class="legend">Tag Deployment</div>
                <div class="control-group">
                    <label class="control-label" for="tagIdentifier">Tag Identifier</label>
                    <div class="controls">
                        <form:input path="tagIdentifier" id="tagIdentifier" placeholder="tag ID"/>
                        <form:errors path="tagIdentifier" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagManufacturerModel">Tag Manufacturer/Model</label>
                    <div class="controls">
                        <form:input path="tagManufacturerModel" id="tagManufacturerModel" cssClass="input-xxlarge" placeholder=""/>
                        <form:errors path="tagManufacturerModel" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="captureDate">Capture Date and Location</label>
                    <div class="controls">
                        <form:hidden path="captureDate" id="captureDate"/>
                        <input type="text" id="captureDateVisible" class="input-small" class="datepicker" placeholder="Capture Date"
                               value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.captureDate}"/>" />
                        &nbsp; Lat. <form:input path="captureLatitude" id="captureLatitude" class="input-small"/>
                        &nbsp; Long. <form:input path="captureLongitude" id="captureLongitude" class="input-small" />
                        <div class="help-inline">
                            <div class="help-popover" title="Capture Date and Location">
                                Location should be provided in WGS84/decimal degrees.
                            </div>
                        </div>
                    </div>
                    <form:errors path="captureLongitude" element="div" cssClass="help-block formErrors"/>
                </div>

                <div class="control-group">
                    <label class="control-label" for="captureDate">Release Date and Location</label>
                    <div class="controls">
                        <form:hidden path="releaseDate" id="releaseDate"/>
                        <input type="text" id="releaseDateVisible" class="input-small" class="datepicker" placeholder="Release Date"
                               value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.releaseDate}"/>" />
                        &nbsp; Lat. <form:input path="releaseLatitude" id="releaseLatitude" class="input-small"/>
                        &nbsp; Long. <form:input path="releaseLongitude" id="releaseLongitude" class="input-small"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Release Date and Location">
                                Location should be provided in WGS84/decimal degrees.
                            </div>
                        </div>
                    </div>
                    <form:errors path="releaseLongitude" element="div" cssClass="help-block formErrors"/>
                </div>


                <div class="control-group">
                <label class="control-label">Tag Deployment Dates</label>
                <div class="controls">
                    <form:hidden path="tagDeployStartDate" id="tagDeployStartDate"/>
                    <form:hidden path="tagDeployEndDate" id="tagDeployEndDate"/>
                    <input type="text" id="tagDeployStartDateVisible" class="datepicker" style="width: 80px;" placeholder="From"
                           value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.tagDeployStartDate}"/>" />
                    - <input type="text" id="tagDeployEndDateVisible" class="datepicker" style="width: 80px;" placeholder="To"
                             value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.tagDeployEndDate}"/>" />
                    <form:errors path="tagDeployStartDate" element="div" cssClass="help-block formErrors"/>
                    <form:errors path="tagDeployEndDate" element="div" cssClass="help-block formErrors"/>
                    <div class="help-inline">
                        <div class="help-popover" title="Tag Deployment Dates">
                            Specify the dates of useful data.
                        </div>
                    </div>
                </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="stateOnDetachment">Animal state on tag detachment</label>
                    <div class="controls">
                        <label class="radio inline"><form:radiobutton path="stateOnDetachment" value="Alive"/> Alive </label>
                        <label class="radio inline"><form:radiobutton path="stateOnDetachment" value="Dead"/> Dead </label>
                        <label class="radio inline"><form:radiobutton path="stateOnDetachment" value="Unknown"/> Unknown </label>
                        <form:errors path="stateOnDetachment" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="experimentalContext">Experimental Context</label>
                    <div class="controls">
                        <form:input path="experimentalContext" id="experimentalContext" cssClass="input-xxlarge" placeholder="e.g. translocation, manipulation, or re-introduction."/>
                        <div class="help-inline">
                            <div class="help-popover" title="Experimental Context">
                                Describe the nature of the tagging program, e.g. translocation, namipulation, or re-introduction.
                            </div>
                        </div>
                        <form:errors path="experimentalContext" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagDimensions">Tag Dimensions</label>
                    <div class="controls">
                        <form:input path="tagDimensions" id="tagDimensions" cssClass="input-xxlarge" placeholder="e.g. tag size and weight"/>
                        <form:errors path="tagDimensions" element="div" cssClass="help-block formErrors"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Tag Dimensions">
                                Specify the size and/or weight of the tag. Be sure to include the units of measurement.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagDutyCycleComments">Duty Cycle</label>
                    <div class="controls">
                        <form:input path="tagDutyCycleComments" id="tagDutyCycleComments" cssClass="input-xxlarge" placeholder="Describe intervals or the number of location fixes attempted per day"/>
                        <form:errors path="tagDutyCycleComments" element="div" cssClass="help-block formErrors"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Tag Duty Cycle">
                                Describe intervals or the number of location fixes attempted per day.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagAttachmentTechnique">Attachment Technique</label>
                    <div class="controls">
                        <form:input path="tagAttachmentTechnique" id="tagAttachmentTechnique" cssClass="input-xxlarge" placeholder="Where and how was the tag attached?"/>
                        <form:errors path="tagAttachmentTechnique" element="div" cssClass="help-block formErrors"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Tag Attachment Technique">
                                Describe where and how the tag was attached.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="dataRetrievalMethod">Data Retrieval Methods</label>
                    <div class="controls">
                        <form:input path="dataRetrievalMethod" id="dataRetrievalMethod" cssClass="input-xxlarge" placeholder="e.g. Argos, Globestar, Iridium, Bluetooth, VFH, Other"/>
                        <form:errors path="dataRetrievalMethod" element="div" cssClass="help-block formErrors"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Data Retrieval Methods">
                                Describe how the data for this tag was retrieved e.g. via Argos, Globestar, Iridium, Bluetooth, VFH, Other
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="dataManipulation">Data Quality and Manipulation</label>
                    <div class="controls">
                        <form:textarea path="dataManipulation" id="dataManipulation" cssStyle="width: 400px; height: 50px;"/>
                        <form:errors path="dataManipulation" element="div" cssClass="help-block formErrors"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Data Manipulation Techniques">
                                A description of any data manipulation, algorithms or filters that have been applied to raw data to derive location, such as least squares or Kalman filters. Also describe any data quality and cleansing measures applied to the data you're uploading to ZoaTrack.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagDeploymentComments">Other Comments</label>
                    <div class="controls">
                        <form:textarea style="width: 400px; height: 50px;" path="tagDeploymentComments" id="tagDeploymentComments" placeholder="Any other information about the tag deployment"/>
                    <span class="help-inline">
                        <form:errors path="tagDeploymentComments" cssClass="formErrors"/>
                    </span>
                    </div>
                </div>
            </fieldset>
           <div class="form-actions">
                <input class="btn btn-primary" type="submit" value="Update"/>
                <a class="btn" href="${pageContext.request.contextPath}/projects/${project.id}/animals/${animal.id}">Cancel</a>
            </div>
        </form:form>
    </jsp:body>
</tags:page>



