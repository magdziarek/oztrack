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

                $('#searchSpeciesName').autocomplete({
                    source: function(request, response) {
                        $.ajax({
                            url: '${pageContext.request.contextPath}/proxy/bie.ala.org.au/search/auto.json',
                            data: {
                                q: request.term,
                                idxType: 'TAXON',
                                limit: 10
                            },
                            dataType: "jsonp",
                            success: function(data, textStatus, jqXHR) {
                                response($.map(data.autoCompleteList, function(item) {
                                    // The label property is displayed in the suggestion menu.
                                    var label = $.trim(item.scientificNameMatches[0] || item.name || '');
                                    if (item.commonNameMatches && item.commonNameMatches.length > 0) {
                                        label += ' (' + item.commonNameMatches.join(', ') + ')';
                                    }
                                    else if (item.commonName) {
                                        label += ' (' + $.trim(item.commonName) + ')';
                                    }
                                    // The value will be inserted into the input element when a user selects an item.
                                    var value = $.trim(item.name || '');
                                    if (item.commonName) {
                                        value += ' (' + $.trim(item.commonName) + ')';
                                    }
                                    return {
                                        label: label.replace(/\s+/g, ' '),
                                        value: value.replace(/\s+/g, ' '),
                                        speciesScientificName: $.trim((item.name || '').replace(/\s+/g, ' ')),
                                        speciesCommonName: $.trim((item.commonName || '').replace(/\s+/g, ' '))
                                    };
                                }));
                            }
                        });
                    },
                    minLength: 2,
                    select: function(event, ui) {
                        jQuery('#speciesScientificName').val(ui.item ? ui.item.speciesScientificName : '');
                        jQuery('#speciesCommonName').val(ui.item ? ui.item.speciesCommonName : '');
                    }
                });
                $('#overrideSpeciesCheckbox').change(function(e) {
                    var readonly = !e.target.checked;
                    $('#speciesScientificName').prop('readonly', readonly);
                    $('#speciesCommonName').prop('readonly', readonly);
                });
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
                <label class="control-label" for="mass">Mass</label>
                <div class="controls">
                    <form:input path="mass" id="mass" cssClass="input-xxlarge" placeholder="Enter mass with units"/>
                    <div class="help-inline">
                        <div class="help-popover" title="Mass">
                            The mass of the animal. Please specify the units of measurement.
                        </div>
                    </div>
                    <form:errors path="mass" element="div" cssClass="help-block formErrors"/>
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
                    <label class="control-label" for="captureDate">Capture and Release Dates</label>
                    <div class="controls">
                        <form:hidden path="captureDate" id="captureDate"/>
                        <form:hidden path="releaseDate" id="releaseDate"/>
                        <input type="text" id="captureDateVisible" class="datepicker" style="width: 80px;" placeholder="Capture Date"
                               value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.captureDate}"/>" />
                        <input type="text" id="releaseDateVisible" class="datepicker" style="width: 80px;" placeholder="Release Date"
                               value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.releaseDate}"/>" />
                    </div>
                    <form:errors path="captureDate" element="div" cssClass="help-block formErrors"/>
                </div>
                <div class="control-group">
                    <label class="control-label" for="releaseDate">Capture Date</label>
                    <div class="controls">
                        <form:hidden path="captureDate" id="captureDate"/>
                        <input type="text" id="captureDateVisible" class="datepicker" style="width: 80px;" placeholder=""
                               value="<fmt:formatDate pattern="${dateFormatPattern}" value="${animal.captureDate}"/>" />
                    </div>
                    <form:errors path="captureDate" element="div" cssClass="help-block formErrors"/>
                </div>
                <div class="control-group">
                    <label class="control-label" for="captureLocation">Capture Location</label>
                    <div class="controls">
                        <form:input path="captureLocation" id="captureLocation" cssClass="input-xxlarge" placeholder=""/>
                        <div class="help-inline">
                            <div class="help-popover" title="Capture Location">
                                Plain text description of the location.
                            </div>
                        </div>
                        <form:errors path="captureLocation" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="animalDescription">Comments</label>
                    <div class="controls">
                        <form:textarea style="width: 400px; height: 100px;" path="animalDescription" id="animalDescription" placeholder="Any other useful details about the animal"/>
                    <span class="help-inline">
                        <form:errors path="animalDescription" cssClass="formErrors"/>
                    </span>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="legend">Species</div>
                <div class="control-group">
                    <label class="control-label" for="searchSpeciesName">Search species name</label>
                    <div class="controls">
                        <input id="searchSpeciesName" class="input-xxlarge" type="text" placeholder="Search Atlas of Living Australia"/>
                        <div class="help-inline">
                            <div class="help-popover" title="Search species name">
                                <p>
                                    Start typing a species name to search the
                                    <a href="http://www.ala.org.au/australias-species/">Atlas of Living Australia</a>
                                    species database.
                                </p>
                                <p>If your desired species name isn't returned, it can be manually entered below.</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="control-group" style="margin-bottom: 9px;">
                    <div class="controls">
                        <label class="checkbox">
                            <input type="checkbox" id="overrideSpeciesCheckbox" />
                            Manually enter or override species name
                        </label>
                    </div>
                </div>
                <div class="control-group required" style="margin-bottom: 9px;">
                    <label class="control-label" for="speciesScientificName">Scientific Name</label>
                    <div class="controls">
                        <form:input path="speciesScientificName" id="speciesScientificName" cssClass="input-xxlarge" readonly="true"/>
                    </div>
                </div>
                <div class="control-group required">
                    <label class="control-label" for="speciesCommonName">Common Name</label>
                    <div class="controls">
                        <form:input path="speciesCommonName" id="speciesCommonName" cssClass="input-xxlarge" readonly="true"/>
                        <form:errors path="speciesScientificName" element="div" cssClass="help-block formErrors"/>
                        <form:errors path="speciesCommonName" element="div" cssClass="help-block formErrors"/>
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
                <label class="control-label" for="">Tag Deployment Dates</label>
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
                <label class="control-label" for="tagManufacturerModel">Tag Manufacturer/Model</label>
                <div class="controls">
                    <form:input path="tagManufacturerModel" id="tagManufacturerModel" cssClass="input-xxlarge" placeholder=""/>
                    <form:errors path="tagManufacturerModel" element="div" cssClass="help-block formErrors"/>
                </div>
            </div>
                <div class="control-group">
                    <label class="control-label" for="tagDimensions">Tag Dimensions</label>
                    <div class="controls">
                        <form:input path="tagDimensions" id="tagDimensions" cssClass="input-xxlarge" placeholder="e.g. tag size and weight"/>
                        <form:errors path="tagDimensions" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagDutyCycleComments">Duty Cycle</label>
                    <div class="controls">
                        <form:input path="tagDutyCycleComments" id="tagDutyCycleComments" cssClass="input-xxlarge" placeholder="Describe intervals or the number of location fixes attempted per day"/>
                        <form:errors path="tagDutyCycleComments" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagAttachmentTechnique">Attachment Technique</label>
                    <div class="controls">
                        <form:input path="tagAttachmentTechnique" id="tagAttachmentTechnique" cssClass="input-xxlarge" placeholder="Where and how was the tag attached?"/>
                        <form:errors path="tagAttachmentTechnique" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="dataRetrievalMethod">Data Retrieval Methods</label>
                    <div class="controls">
                        <form:input path="dataRetrievalMethod" id="dataRetrievalMethod" cssClass="input-xxlarge" placeholder="e.g. Argos, Globestar, Iridium, Bluetooth, VFH, Other"/>
                        <form:errors path="dataRetrievalMethod" element="div" cssClass="help-block formErrors"/>
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" for="tagDeploymentComments">Other Comments</label>
                    <div class="controls">
                        <form:textarea style="width: 400px; height: 100px;" path="tagDeploymentComments" id="tagDeploymentComments" placeholder="Any other information about the tag deployment"/>
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



