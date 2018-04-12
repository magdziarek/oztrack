<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<%@ taglib uri="/WEB-INF/functions.tld" prefix="oztrack" %>
<c:set var="isoDateFormatPattern" value="yyyy-MM-dd"/>
<tags:page title="${project.title}: View Tracks" fluid="true">
    <jsp:attribute name="description">
        View and analyse animal tracking data in the ${project.title} project.
    </jsp:attribute>
    <jsp:attribute name="navExtra">
        <tags:project-dropdown project="${project}"/>
    </jsp:attribute>
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css"/>
        <style type="text/css">
            .animalCheckbox {
                float: left;
                width: 15px;
                margin: 5px 0;
            }
            .smallSquare {
                display: block;
                border-radius:3px;
                height: 14px;
                width: 14px;
                float: left;
                margin: 5px;
            }
            .animalHeader {
                padding: 0;
                height: 24px;
                line-height: 24px;
                margin-top: 10px;
                margin-bottom: 0.5em;
            }
            .animalLabel {
                font-weight: bold;
                margin-left: 40px;
                margin-right: 65px;
                white-space: nowrap;
                overflow: hidden;
            }
            a.animalInfoToggle {
                text-decoration: none;
            }
            .animalInfo  {
                margin-top: 5px;
            }
            .layerInfoStat {
                min-width:55%
            }
            #projectMapOptions {
                width: 30%;
            }

        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script src="${pageContext.request.scheme}://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/openlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-map.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/simple-map.js"></script>
        <script type="text/javascript">
            $(document).ready(function() {

                $('#navTrack').addClass('active');
                $('#projectMenuAnalysis').addClass('active');
                $("#projectMapOptionsTabs").tabs();
                <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                $('input[id=select-animal-${animal.id}]').change(function() {
                    $('#filter-animal-${animal.id}').prop('disabled', !this.checked);
                    analysisMap.setAnimalVisible('${animal.id}', this.checked);
                });
                </c:forEach>
                $('#select-animal-all').prop('checked', $('.select-animal:not(:checked)').length == 0);
                $('.select-animal').change(function (e) {
                    $('#select-animal-all').prop('checked', $('.select-animal:not(:checked)').length == 0);
                });
                $('#select-animal-all').change(function (e) {
                    $('.select-animal').prop('checked', $(this).prop('checked')).trigger('change');
                });
                var projectBounds = new OpenLayers.Bounds(
                        ${projectBoundingBox.envelopeInternal.minX}, ${projectBoundingBox.envelopeInternal.minY},
                        ${projectBoundingBox.envelopeInternal.maxX}, ${projectBoundingBox.envelopeInternal.maxY}
                );
                analysisMap = null;
                onResize();
                analysisMap = new OzTrack.SimpleMap('projectMap', {
                    project: {
                        id: '${project.id}',
                        title: '${oztrack:escapeJS(project.title)}',
                        <c:if test="${(project.access == 'OPEN') and (project.dataLicence != null)}">
                        dataLicence: {
                            title: '${project.dataLicence.title}',
                            infoUrl: '${project.dataLicence.infoUrl}',
                            imageUrl: '${pageContext.request.scheme}://${fn:substringAfter(project.dataLicence.imageUrl, "://")}'
                        },
                        </c:if>
                        crosses180: ${project.crosses180},
                        bounds: projectBounds,
                        minDate: new Date(${projectDetectionDateRange.minimum.time}),
                        maxDate: new Date(${projectDetectionDateRange.maximum.time})
                    },
                    animals: [
                        <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                        <c:set var="animalBoundingBox" value="${animalBoundingBoxes[animal.id]}"/>
                        {
                            id: '${animal.id}',
                            name: '${oztrack:escapeJS(animal.animalName)}',
                            <c:if test="${animalBoundingBox != null}">
                            <c:set var="env" value="${animalBoundingBox.envelopeInternal}"/>
                            bounds: new OpenLayers.Bounds(${env.minX}, ${env.minY}, ${env.maxX}, ${env.maxY}),
                            </c:if>
                            colour: '${animal.colour}'
                        }<c:if test="${!animalStatus.last}">,
                        </c:if>
                        </c:forEach>
                    ],
                    onUpdateAnimalInfoFromLayer: function(layerName, layerId, animalId, animalIds, fromDate, toDate, layerAttrs) {

                        var html = '';
                        var statsHtml = '';
                        if (layerName == 'Detections') {
                            statsHtml += '<span class="layerInfoStat">';
                            statsHtml += 'Date Range: ' + fromDate + ' - ' + toDate;
                            statsHtml += '</span>';
                        }
                        $.each(layerAttrs, function(key, value) {
                            if (value !== null && value !== undefined) {
                                statsHtml += '<span class="layerInfoStat">';
                                statsHtml += key + ': ' + value;
                                statsHtml += '</span>';
                            }
                        });
                        if (statsHtml != '') {
                            html += '<div class="layerInfoStats">' + statsHtml + '</div>';
                        }
                        $('#animalInfo-' + animalId).append(html);
                    }
                });
                <c:if test="${projectAnimalsList.size() == 1}">
                    analysisMap.zoomToAnimal("${projectAnimalsList[0].id}");
                </c:if>
                $(window).resize(onResize);
                $('#toggleSidebar').click(function(e) {
                    e.preventDefault();
                    $(this).find('i').toggleClass('icon-chevron-left').toggleClass('icon-chevron-right');
                    $('#projectMapOptions').toggleClass('minimised');
                    onResize();
                });
            });
            function onResize() {
                var mainHeight = $(window).height() - $('#header').outerHeight();
                $('#projectMapOptions').height(mainHeight);
                $('#toggleSidebar').height(
                        $('#projectMapOptions').hasClass('minimised')
                                ? $('#projectMapOptions').innerHeight()
                                : $('#projectMapOptionsTabs .ui-tabs-nav').innerHeight()
                );
                $('#toggleSidebar *').position({my: "center", at: "center", of: "#toggleSidebar"});
                $('#projectMapOptions .ui-tabs-panel').height(
                        $('#projectMapOptions').innerHeight() -
                        $('#projectMapOptions .ui-tabs-nav').outerHeight() -
                        parseInt($('#projectMapOptions .ui-tabs-panel').css('padding-top')) -
                        parseInt($('#projectMapOptions .ui-tabs-panel').css('padding-bottom'))
                );
                $('#projectMap').height(mainHeight);
                $('#projectMap').width($(window).width() - $('#projectMapOptions').width());
                if (analysisMap) {
                    analysisMap.updateSize();
                }
            }
        </script>
    </jsp:attribute>
    <jsp:body>
        <div id="mapTool" class="mapTool">

            <div id="projectMapOptions">
                <div id="projectMapOptionsInner">
                    <div id="projectMapOptionsTabs">
                        <ul>
                            <li><a href="#animalPanel">Animals</a></li>
                            <li><a href="#metadataPanel">Metadata</a></li>
                        </ul>
                        <div id="animalPanel">

                            <div id="allAnimals" class="layerInfo">
                                <div class="layerInfoHeader"><h3>${project.title}</h3></div>

                                <div class="layerInfoStats">
                                    <p>${project.description}</p>

                                    <span class="layerInfoStat">${projectAnimalsList.size()} animals from
                                        <fmt:formatDate pattern="${isoDateFormatPattern}" value="${projectDetectionDateRange.minimum}"/> to
                                        <fmt:formatDate pattern="${isoDateFormatPattern}" value="${projectDetectionDateRange.maximum}"/></span>

                                </div>
                            </div>

                            <div class="animalHeader" style="margin-top: 0; border-bottom: 1px solid #ccc;">
                                <div class="animalCheckbox"> <input id="select-animal-all" type="checkbox" style="float: left; margin: 0;" /> </div>
                                <div class="smallSquare" style="background-color: transparent;"></div> <div>Select all</div>
                            </div>

                            <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                                <c:set var="showAnimalInfo" value='false'/>
                                <div class="animalHeader">
                                    <div class="btn-group" style="float: right;">
                                        <button class="btn btn-small"
                                                title="Zoom to animal"
                                                onclick="analysisMap.zoomToAnimal('${animal.id}');">
                                            <i class="icon-zoom-in"></i>
                                        </button>
                                        <button id="buttonShowHide${animal.id}"
                                                class="btn btn-small"
                                                title="Show/hide animal details"
                                                onclick="var infoElem = $(this).parent().parent().next(); $(this).find('i').toggleClass('icon-chevron-up').toggleClass('icon-chevron-down'); infoElem.slideToggle();">
                                            <i class="${showAnimalInfo ? 'icon-chevron-up' : 'icon-chevron-down'}"></i>
                                        </button>
                                    </div>

                                    <div class="animalCheckbox">
                                        <input id="select-animal-${animal.id}" class="select-animal" style="float: left; margin: 0;" type="checkbox" name="animalCheckbox" value="${animal.id}" checked="checked">
                                    </div>

                                    <div class="smallSquare" style="background-color: ${animal.colour};"></div>

                                    <div id="animalLabel-${animal.id}" class="animalLabel">
                                        <a class="animalInfoToggle" href="javascript:void(0);" onclick="$('#buttonShowHide${animal.id}').click();">${animal.animalName}</a>
                                    </div>
                                </div>
                                <div id="animalInfo-${animal.id}" class="animalInfo layerInfo" style="display: ${showAnimalInfo ? 'block' : 'none'};">
                                    <div class="layerInfoHeader">Summary Statistics</div>
                                </div>
                            </c:forEach>
                        </div>
                        <div id="metadataPanel">
                            <h2>Project Summary</h2>
                            <dl>
                                <dt>Species</dt>
                                <dd>
                                    <p>
                                        <c:if test="${!empty project.speciesScientificName}">
                                            <i><c:out value="${project.speciesScientificName}"/></i>
                                            <c:if test="${!empty project.speciesCommonName}">
                                                <br/>
                                            </c:if>
                                        </c:if>
                                        <c:if test="${!empty project.speciesCommonName}">
                                            <c:out value="${project.speciesCommonName}"/>
                                        </c:if>
                                    </p>
                                </dd>
                                <dt>Location</dt>
                                <dd>
                                    <p><c:out value="${project.spatialCoverageDescr}"/></p>
                                </dd>
                                <c:if test="${not empty projectDetectionDateRange}">
                                    <dt>Date Range</dt>
                                    <dd>
                                        <c:set var="dateFormatPattern" value="yyyy-MM-dd"/>
                                        <p><fmt:formatDate pattern="${dateFormatPattern}" value="${projectDetectionDateRange.minimum}"/> to <fmt:formatDate pattern="${dateFormatPattern}" value="${projectDetectionDateRange.maximum}"/></p>
                                    </dd>
                                </c:if>
                                <c:if test="${not empty projectAnimalsList}">
                                    <dt>Animals</dt>
                                    <dd>
                                        <p><a href="${pageContext.request.contextPath}/projects/${project.id}/animals">${fn:length(projectAnimalsList)} animals</a></p>
                                    </dd>
                                </c:if>
                                <c:if test="${not empty project.srsIdentifier}">
                                    <dt>Spatial Reference System</dt>
                                    <dd>
                                        <c:url var="srsHref" value="http://spatialreference.org/ref/">
                                            <c:param name="search">${project.srsIdentifier}</c:param>
                                        </c:url>
                                        <p><a target="_blank" href="${srsHref}"><c:out value="${project.srsIdentifier}"/></a></p>
                                    </dd>
                                </c:if>
                            </dl>
                            <c:set var="dataAccessRowClass">
                                <c:choose>
                                    <c:when test="${project.access == 'OPEN'}">
                                        project-access-open
                                    </c:when>
                                    <c:when test="${project.access == 'EMBARGO'}">
                                        project-access-embargo
                                    </c:when>
                                    <c:otherwise>
                                        project-access-closed
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <div class="row ${dataAccessRowClass}" style="margin-left: 0; padding: 5px">

                                <c:choose>
                                    <c:when test="${project.access == 'OPEN'}">
                                        <p class="project-access-open-title">Open Access</p>
                                        <p>
                                            The data in this project is publicly available under a <a target="_blank" href="${project.dataLicence.infoUrl}">${project.dataLicence.title}</a>.
                                            If you use these data in any type of publication then you must cite the project DOI (if available) or any
                                            published peer-reviewed papers associated with the study. We strongly encourage you to contact the data custodians
                                            to discuss data usage and appropriate accreditation.
                                        </p>
                                    </c:when>
                                    <c:when test="${project.access == 'EMBARGO'}">
                                        <p class="project-access-embargo-title">Delayed Open Access</p>
                                        <p>
                                            The data in this project are under embargo until
                                            <fmt:formatDate pattern="${dateFormatPattern}" value="${project.embargoDate}"/>.
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="project-access-closed-title">Closed Access</p>
                                        <p>
                                            The data in this project are not publicly available.
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${not empty project.rightsStatement}">
                                    <p><span style="font-weight:bold">Rights Statement</span><br/>
                                        <c:out value="${project.rightsStatement}"/></p>
                                </c:if>
                                <dl>
                                    <dt>Contact</dt>
                                    <dd>
                                        <ul class="unstyled">
                                            <li><c:out value="${project.createUser.fullName}"/></li>
                                            <c:set var="institutions">
                                                <c:forEach var="institution" items="${project.createUser.institutions}" varStatus="status">
                                                    ${institution.title}
                                                    <c:if test="${not status.last}"> / </c:if>
                                                </c:forEach>
                                            </c:set>
                                            <c:if test="${not empty institutions}">
                                                <li><c:out value="${institutions}"/></li>
                                            </c:if>
                                            <li><a href="mailto:<c:out value="${project.createUser.email}"/>"><c:out value="${project.createUser.email}"/></a></li>
                                        </ul>
                                    </dd>
                                </dl>
                            </div>

                            <c:if test="${not empty project.publications or (not empty project.dois and project.dois.get(0).status == 'COMPLETED')}">
                                <h2>Citations</h2>
                                <dl>
                                    <c:if test="${not empty project.dois and project.dois.get(0).status == 'COMPLETED'}">
                                        <dt>ZoaTrack Dataset</dt>
                                        <dd>
                                            <ul>
                                                <c:forEach var="doi" items="${project.dois}">
                                                    <c:if test="${doi.status == 'COMPLETED'}">
                                                        <li><c:out value="${doi.citation}"/></li>
                                                    </c:if>
                                                </c:forEach>
                                            </ul>
                                        </dd>
                                    </c:if>
                                    <c:if test="${not empty project.publications}">
                                        <dt>Related Publications</dt>
                                        <dd>
                                            <ol>
                                                <c:forEach var="publication" items="${project.publications}">
                                                    <li>
                                                        <c:out value="${publication.reference}"/>
                                                        <c:if test="${not empty publication.url}">
                                                            [<a target="_blank" href="<c:out value="${publication.url}"/>">Link</a>]
                                                        </c:if>
                                                    </li>
                                                </c:forEach>
                                            </ol>
                                        </dd>
                                    </c:if>
                                </dl>
                            </c:if>
                        </div>


                        <a id="toggleSidebar" href="#toggleSidebar"><i class="icon-chevron-left"></i></a>
                    </div>
                </div>
            </div>

            <div id="projectMap"></div>
            <div style="clear:both;"></div>

        </div>

        <div id="errorDialog"></div>

        <input id="projectMapCancel" class="btn" style="display: none; margin-left: 0.5em;" type="button" value="Cancel" />
    </jsp:body>
</tags:page>