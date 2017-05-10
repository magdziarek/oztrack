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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">
        <style type="text/css" title="analysis-styles">
            #main {
                padding-bottom: 0;
            }
            #form-context {
                padding-left:0px;
                padding-top:0px;
            }
            #homeRangeCalculatorPanel .accordion {
                margin-bottom: 9px;
            }
            #animalsFilter {
                height: 90px;
                border: 1px solid #ccc;
                overflow-y: scroll;
            }
            .animalsFilterCheckbox {
                float: left;
                width: 15px;
                margin: 0;
                padding: 0;
            }
            .animalsFilterCheckbox input[type="checkbox"] {
                margin: 0 0 2px 0;
            }
            .animalsFilterSmallSquare {
                float: left;
                width: 12px;
                height: 12px;
                margin: 2px 5px;
                padding: 0;
            }
            .animalsFilterLabel {
                margin-left: 40px;
                padding: 0;
            }
            .animalCheckbox {
                float: left;
                width: 15px;
                margin: 5px 0;
            }
            .smallSquare {
                display: block;
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
            .animalInfo {
                margin: 0;
            }
            .animalInfo table {
                margin-top: 5px;
            }
            .layerInfoTitle {
                padding: 3px 0;
            }
            .layerInfoActions a {
                color:#666;
                font-weight:bold;
                text-decoration: none;
                font-size:smaller;
            }
            .layerInfoActions a:hover {
                color:#ef9800;
            }
            .layerExplanationExpander {
                display: block;
                padding: 4px 0 9px 0;
            }
            #savedAnalysesList .analysis-header {
                padding: 2px 4px;
                border-bottom: 1px solid #ccc;
                background-color: #D8E0A8;
            }
            #savedAnalysesList .analysis-header a {
                color: #444;
                font-weight: normal;
                text-decoration: none;
            }
            .analysis-header-timestamp {
                float: right;
                font-size: 11px;
                color: #666;
            }
            #savedAnalysesList .analysis-content {
                margin: 0 0 9px 0;
            }
            #previousAnalysesList .analysis-content {
                margin: 6px 0 9px 0;
                background-color: #DBDBD0;
                border: 1px solid transparent;
            }
            #previousAnalysesList .analysis-content-description {
                padding-top: 3px;
                padding-bottom: 3px;
                border-bottom: 1px solid #CCC;
            }
            .analysis-content-description {
                margin: 6px;
            }
            .analysis-content-description .analysis-content-description-text,
            .analysis-content-description .editable-container {
                font-style: italic;
            }
            .analysis-content-description .editable-empty {
                color: #666;
            }
            .analysis-content-params {
                margin: 6px;
            }
            #previousAnalysesList .analysis-content-footer {
                padding-top: 3px;
                padding-bottom: 3px;
            }
            #projectMapOptions #toggleSidebar {
                display: block;
                position: absolute;
                top: 0;
                right: 0;
                text-align: center;
            }
            #projectMapOptions.minimised,
            #projectMapOptions.minimised #toggleSidebar {
                width: 16px;
            }
            #projectMapOptions.minimised #toggleSidebar {
                background-color: #e6e6c0;
            }
            #projectMapOptions {
                width: 40%;
            }
            .line {
                fill: none;
                clip-path: url(#clip);
                stroke-width:2;
            }
            .nav-line {
                stroke-width: 1.5;
            }
            .point {
                stroke: "grey";
                stroke-width:0.5;
                fill-opacity:0.7;
            }
            #layer-control {
                display:list-item;
                width:40%;
            }
            rect.selection {
                fill: #c5c56d	;
                stroke: #a4a441;
                stroke-opacity: 0.5;
                shape-rendering: auto;
            }
            .zoom {
                cursor: move;
                fill: none;
                pointer-events: all;
            }
            div.tooltip {
                position: absolute;
                text-align: center;
                padding: 4px;
                border-radius: 3px;
                box-shadow: 0px 0px 0px 1px rgba(0,0,0,0.2);
                pointer-events: none;
            }
            #legendDiv   {
                padding: 5px 0px;
                overflow:auto;
                -webkit-column-count: 3; /* Chrome, Safari, Opera */
                -moz-column-count: 3; /* Firefox */
                column-count: 3;
                height:40%;
            }
            .legend {
                overflow: auto;
            }
            .legendSquare {
                position:absolute;
                cursor: pointer;
            }
            #chart-menu-tabs {
                margin-bottom: 5px;
            }
            #chart-tab-wrapper {
                position:relative;
                margin:0 auto;
                overflow:hidden;
                padding:5px;
                height:25px;
            }
            #chart-menu-tabs {
                position:absolute;
                left:0px;
                top:0px;
                min-width:700px;
                margin-left:10px;
                margin-top:0px;
            }
            #chart-menu-tabs > li {
                margin-bottom: 7px;
                display:table-cell;
                position:relative;
                text-align:center;
                cursor:grab;
                cursor:-webkit-grab;
                vertical-align:middle;
            }
            #chart-menu-tabs  > li > a {
                background-color: #f0f0da;
                font-weight:normal;
            }
            .chart-menu-tab-li > a {
                text-decoration:none;
            }
            #chart-menu-tabs > .active > a, .chart-menu-tabs > .active > a:hover, .chart-menu-tabs > .active > a:focus {
                background-color: #FBFEEE;
                font-weight:bold;
            }
            #chartArea {
                background-color: #FBFEEE;
                -moz-border-radius: 6px;
                border-radius: 6px;
                padding-top: 15px;
                padding-bottom: 15px;
            }
            #chartTitle {
                font-weight: bold;
                text-align: center;
            }
            #chartDescription {
                text-align: center;
                font-size:0.9em;
                font-style: italic;
                margin: 5px 5px;
            }
            #chartHelp {
                position: absolute;
                right: 20px;
                margin-top:-20px;
            }
           .exportConfirmation {
                margin: 0 15px;
                padding: 10px;
            }
            .scroller {
                text-align:center;
                cursor:pointer;
                display:none;
                padding:10px 10px;
                white-space:nowrap;
                vertical-align:middle;
            }
            .scroller-right{
                float:right;
            }
            .scroller-left {
                float:left;
            }
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script src="${pageContext.request.scheme}://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/openlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-map.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-analysis.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/d3.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/project-temporal-chart.js"></script>

        <script type="text/javascript">
            $(document).ready(function() {

                $('#navTrack').addClass('active');
                $('#projectMenuAnalysis').addClass('active');
                var temporalTabIndex = 2;
                $("#projectMapOptionsTabs").tabs({
                   activate: function(event, ui) {
                        if (ui.newTab.index() == temporalTabIndex) {
                            chartTabs();
                        }
                    }
                });
                $('#fromDateVisible').datepicker({
                    altField: '#fromDate',
                    minDate: new Date(${projectDetectionDateRange.minimum.time}),
                    maxDate: new Date(${projectDetectionDateRange.maximum.time}),
                    defaultDate: new Date(${projectDetectionDateRange.minimum.time})
                });
                $('#toDateVisible').datepicker({
                    altField: '#toDate',
                    minDate: new Date(${projectDetectionDateRange.minimum.time}),
                    maxDate: new Date(${projectDetectionDateRange.maximum.time}),
                    defaultDate: new Date(${projectDetectionDateRange.maximum.time})
                });
                <c:forEach items="${analysisTypeList}" var="analysisType">
                <c:forEach items="${analysisType.parameterTypes}" var="parameterType">
                <c:if test="${parameterType.dataType == 'date'}">
                $('#paramField-${analysisType}-${parameterType.identifier}Visible').datepicker({
                    altField: '#paramField-${analysisType}-${parameterType.identifier}'
                });
                </c:if>
                </c:forEach>
                </c:forEach>
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

                $('#filter-animal-all').prop('checked', $('.filter-animal:not(:checked)').length == 0);
                $('.filter-animal').change(function (e) {
                    $('#filter-animal-all').prop('checked', $('.filter-animal:not(:checked)').length == 0);
                });
                $('#filter-animal-all').change(function (e) {
                    $('.filter-animal').prop('checked', $(this).prop('checked'));
                });

                $('#layerTypeSelect-MCP').trigger('click');

                $('.layerExplanationExpander').click(function(e) {
                    e.preventDefault();
                    var prev = $(this).prev();
                    var maxHeight = prev.css('max-height');
                    var newMaxHeight = (maxHeight === 'none') ? '54px' : 'none';
                    prev.css('max-height', newMaxHeight);
                });
                
                $('#homeRangeCalculatorPanel .accordion .collapse').on('show', function() {
                    $('#homeRangeCalculatorPanel .accordion')
                        .not($(this).closest('.accordion'))
                        .find('.collapse.in')
                        .collapse('hide');
                });

                $('.form-projectLayer').submit(function(e) {
                    e.preventDefault();
                    analysisMap.addProjectMapLayer(
                        $(e.target).find('input[name="layerTypeValue"]').val(),
                        $(e.target).find('input[name="layerTypeLabel"]').val()
                    );
                });
                $('.form-analysisLayer').submit(function(e) {
                    e.preventDefault();
                    $(e.target).find('button[type="submit"]')
                        .prop('disabled', true)
                        .after($('#projectMapCancel').fadeIn());
                    analysisMap.addProjectMapLayer(
                        $(e.target).find('input[name="layerTypeValue"]').val(),
                        $(e.target).find('input[name="layerTypeLabel"]').val()
                    );
                });
                $('#projectMapCancel').click(function() {
                    analysisMap.deleteCurrentAnalysis();
                    $(this).prev().prop('disabled', false);
                    $('#projectMapCancel').fadeOut();
                });
                var projectBounds = new OpenLayers.Bounds(
                    ${projectBoundingBox.envelopeInternal.minX}, ${projectBoundingBox.envelopeInternal.minY},
                    ${projectBoundingBox.envelopeInternal.maxX}, ${projectBoundingBox.envelopeInternal.maxY}
                );
                analysisMap = null;
                onResize();
                analysisMap = new OzTrack.AnalysisMap('projectMap', {
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
                    onAnalysisCreate: function(layerName, analysis) {
                        addAnalysis(layerName, analysis.url, moment(analysis.createDate, 'YYYY-MM-DDTHH:mm:ss').toDate(), false);
                    },
                    onAnalysisDelete: function(analysis) {
                        $('.analysisInfo-' + analysis.id).fadeOut({complete: function() {$(this).remove();}});
                    },
                    onAnalysisError: function() {
                        $('#projectMapCancel').fadeOut().prev().prop('disabled', false);
                    },
                    onAnalysisSuccess: function(analysis) {
                        $('#projectMapCancel').fadeOut().prev().prop('disabled', false);
                        $('a[href="#animalPanel"]').trigger('click');
                    },
                    onLayerSuccess: function() {
                      //  $('a[href="#animalPanel"]').trigger('click'); // not ideal
                    },
                    onUpdateAnimalInfoFromLayer: function(layerName, layerId, animalId, animalIds, fromDate, toDate, layerAttrs) {
                        var html = '<div class="layerInfoHeader">';
                        html += '<span class="layerInfoActions">' + '<button class="btn btn-small btn-layer-info" onclick="analysisMap.deleteProjectMapLayer(' + layerId + ');"><i class="icon-trash"></i></button>' + '</span>';
                        html += '<span class="layerInfoTitle">' + layerName + '</span>';
                        html += '</div>';
                        var statsHtml = '';
                        statsHtml += '<span class="layerInfoStat">';
                        statsHtml += 'Dates: ' + fromDate + ' - ' + toDate;
                        statsHtml += '</span>';
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
                        var exportHtml = '';
                        if ((layerName == 'Detections') || (layerName == 'Trajectory')) {
                            var exportBaseUrl =
                                '${pageContext.request.contextPath}/' +
                                ((layerName == 'Detections') ? 'detections' : 'trajectory') +
                                '?projectId=' + ${project.id} +
                                '&animalIds=' + animalId + // animalIds.join(',') +
                                '&fromDate=' + fromDate +
                                '&toDate=' + toDate;
                            exportHtml += '<a class="icon kml" href="' + exportBaseUrl + '&format=kml">KML</a> ';
                            exportHtml += '<a class="icon shp" href="' + exportBaseUrl + '&format=shp">SHP</a>';
                        }
                        if (exportHtml != '') {
                            html += '<div class="layerInfoExport">Download: <span class="layerInfoActions">' + exportHtml + '</span></div>';
                        }
                        $('#animalInfo-' + animalId).append('<div class="layerInfo projectMapLayerInfo-' + layerId + '">' + html + '</div>');
                    },
                    onUpdateAnimalInfoFromAnalysisCreate: function(layerName, animalId, analysis, fromDate, toDate) {
                        <tags:analysis-info-create
                            headerActionsJsExpr="
                                $('<button>')
                                .addClass('btn')
                                .addClass('btn-small')
                                .addClass('btn-layer-info')
                                .attr('onclick', 'analysisMap.deleteAnalysis(\\'' + analysis.id + '\\', true);')
                                .append($('<i>').addClass('icon-trash'))

                            "
                            alaActionJsExpr="
                                     $('<button>')
                                    .addClass('btn')
                                    .addClass('btn-small')
                                    .addClass('btn-layer-info')
                                    .addClass('ala-btn')
                                    .attr('onclick', 'analysisMap.openAlaPolygon(\\'' + analysis.id + '\\', \\'' + animalId + '\\');')
                                    .attr('data-toggle','tooltip')
                                    .attr('title','Open this analysis in the Atlas of Living Australia Spatial Portal')
                                    .append($('<img>').attr('src','../../img/ala-logo-sm.png'))
                                    "
                            parentIdJsExpr="'animalInfo-' + animalId"
                            childIdJsExpr="'analysisInfo-' + animalId + '-' + analysis.id"
                            statsIdJsExpr="'analysis-stats-' + animalId + '-' + analysis.id"
                            classNameJsExpr="' analysisInfo-' + analysis.id"
                            analysisTypeList="${analysisTypeList}"/>
                    },
                    onUpdateAnimalInfoFromAnalysisSuccess: function(animalId, analysis, animalAttributes) {
                        <tags:analysis-info-success
                            childIdJsExpr="'analysisInfo-' + animalId + '-' + analysis.id"
                            statsIdJsExpr="'analysis-stats-' + animalId + '-' + analysis.id"
                            helpPopoverIdJsExpr="'analysisHelpPopover-' + animalId + '-' + analysis.id"
                            project="${project}"
                            analysisTypeList="${analysisTypeList}"/>
                    }
                });
                distanceCharts = null;
                distanceCharts = new OzTrack.DistanceCharts();
                var url = "${pageContext.request.contextPath}/projects/${project.id}/analysis/posfixstats";
                distanceCharts.loadProjectChartData(url, analysisMap.projectMap.animals);
                <c:if test="${not empty temporal && temporal}">
                    $('a[href="#temporalPanel"]').trigger('click');
                </c:if>
                <c:if test="${not empty bccvlApiUrl}">
                    <c:set var="baseUrl" value="${fn:replace(pageContext.request.requestURL, pageContext.request.requestURI, '')}"/>
                    $('a[href="#temporalPanel"]').trigger('click');
                    if ($("#exportTemporal").is(":visible")) {$("#exportTemporal").slideUp();}
                    $(".chart-menu-tab-li").removeClass('active');
                    $("#export-traits").parent().addClass('active');
                    hideChart();
                    $("#exportTraits").slideDown();
                 if (window.location.hash.length != 0) {
                    $("#bccvl-message").html("<p>You have successfully authorised and connected to the BCCVL. Now you can export your data to your BCCVL account.</p>");
                    $("#bccvl-button").text('Export data to BCCVL')
                            .attr("href","#")
                            .on('click', function() {
                                //var auth = "Bearer " + window.location.hash; //.split('&')[0].split('=')[1]
                                var json = {
                                    "source": "zoatrack",
                                    "species": "${project.speciesScientificName}",
                                    "url": "${baseUrl}${pageContext.request.contextPath}/projects/${project.id}/analysis/traitexport"};
                                console.log(json);
                                console.log(JSON.stringify(json));
                                $("#bccvl-message").html('<p>Exporting trait data to BCCVL. Wait...</p>');
                                $("#bccvl-button").hide();
                                $("#bccvl-loading").show();
                                $.ajax({
                                    type: 'POST',
                                    url: "/proxy/bccvlapi",
                                    contentType: 'application/json',
                                    headers: {
                                        Accept: "application/json",
                                        Authorization: "Bearer " +  window.location.hash.split('&')[0].split('=')[1]
                                        },
                                    data: JSON.stringify(json),
                                    error: function(xhr, textStatus, errorThrown) {
                                        $("#bccvl-loading").hide();
                                        $("#bccvl-message").css({'color':'red'});
                                        $("#bccvl-message").html('<p>' + xhr.responseText + '</p>');
                                        $("#refresh-button").show();
                                    },
                                    complete: function (xhr, textStatus) {
                                        if (textStatus == 'success') {
                                            $("#bccvl-loading").hide();
                                            var location = xhr.getResponseHeader('Location');
                                            $("#bccvl-message").html('<p>Export to BCCVL successful. You can now open the BCCVL and use your data in modelling experiments. Click the button below to launch the BCCVL.</p>' +
                                            '<a class="btn btn-primary" target="_blank" href="' + location + '">Open BCCVL and view the exported data</a>');
                                        }
                                    }
                                })
                            });
                 }
                </c:if>

                <c:forEach items="${savedAnalyses}" var="analysis">
                addAnalysis(
                    '${analysis.analysisType.displayName}',
                    '${pageContext.request.contextPath}/projects/${analysis.project.id}/analyses/${analysis.id}',
                    new Date(${analysis.createDate.time}),
                    true
                );
                </c:forEach>
                <c:forEach items="${previousAnalyses}" var="analysis">
                addAnalysis(
                    '${analysis.analysisType.displayName}',
                    '${pageContext.request.contextPath}/projects/${analysis.project.id}/analyses/${analysis.id}',
                    new Date(${analysis.createDate.time}),
                    false
                );
                </c:forEach>
                $(window).resize(onResize);
                $('#toggleSidebar').click(function(e) {
                    e.preventDefault();
                    $(this).find('i').toggleClass('icon-chevron-left').toggleClass('icon-chevron-right');
                    $('#projectMapOptions').toggleClass('minimised');
                    onResize();
                });

            });

            function addAnalysis(layerName, analysisUrl, analysisCreateDate, saved) {
                var analysisContainer = $('<li class="analysis">');
                var analysisHeader = $('<div class="analysis-header">');
                if (!saved) {
                    var analysisTimestamp = $('<span class="analysis-header-timestamp">')
                        .text(moment(analysisCreateDate).format('YYYY-MM-DD HH:mm'));
                    analysisHeader.append(analysisTimestamp);
                }
                var analysisLink = $('<a>')
                    .attr('href', 'javascript:void(0);')
                    .text(layerName)
                    .click(function(e) {
                        var parent = $(this).closest('.analysis');
                        var content = parent.find('.analysis-content');
                        if (content.length != 0) {
                            content.slideToggle();
                        }
                        else {
                            parent.append(getAnalysisContent(layerName, analysisUrl, analysisCreateDate, saved));
                        }
                    });
                analysisHeader.append(analysisLink);
                analysisContainer.append(analysisHeader);
                if (saved) {
                    analysisContainer.append(getAnalysisContent(layerName, analysisUrl, analysisCreateDate, saved));
                    $('#savedAnalysesTitle').fadeIn();
                    $('#savedAnalysesList').fadeIn().prepend(analysisContainer);
                }
                else {
                    $('#previousAnalysesTitle').fadeIn();
                    $('#previousAnalysesList').fadeIn().prepend(analysisContainer);
                }
            }
            function getAnalysisContent(layerName, analysisUrl, analysisCreateDate, saved) {
                var div = $('<div class="analysis-content">').hide();
                $.ajax({
                    url: analysisUrl,
                    type: 'GET',
                    error: function(xhr, textStatus, errorThrown) {
                    },
                    complete: function (xhr, textStatus) {
                        if (textStatus == 'success') {
                            var analysis = $.parseJSON(xhr.responseText);
                            if (saved) {
                                var descriptionDiv = $('<div class="analysis-content-description">');
                                <sec:authorize access="hasPermission(#project, 'write')">
                                var editLink = $('<a style="float: right; padding: 0 6px;">')
                                    .attr('href', 'javascript:void(0);')
                                    .append($('<img src="${pageContext.request.contextPath}/img/page_white_edit.png" />'))
                                    .click(function(e) {
                                        e.stopPropagation();
                                        $(this).closest('.analysis-content').find('.analysis-content-description .analysis-content-description-text').editable('toggle');
                                    });
                                descriptionDiv.append(editLink);
                                </sec:authorize>
                                descriptionDiv.append($('<div class="analysis-content-description-text">')
                                    .text(analysis.description || '')
                                    <sec:authorize access="hasPermission(#project, 'write')">
                                    .editable({
                                        type: 'textarea',
                                        toggle: 'manual',
                                        emptytext: 'No description entered.',
                                        url: function(params) {
                                            jQuery.ajax({
                                                url: analysisUrl + '/description',
                                                type: 'PUT',
                                                contentType: "text/plain",
                                                data: params.value,
                                                success: function() {
                                                },
                                                error: function() {
                                                    alert('Could not save description.');
                                                }
                                            });
                                        }
                                    })
                                    </sec:authorize>
                                );
                                div.append(descriptionDiv);
                            }

                            var paramsTable = $('<table class="analysis-content-params">');
                            if (analysis.params.fromDate) {
                                paramsTable.append(
                                    '<tr>' +
                                    '<td class="layerInfoLabel">Date From:</td>' +
                                    '<td>' + analysis.params.fromDate + '</td>' +
                                    '</tr>'
                                );
                            }
                            if (analysis.params.toDate) {
                                paramsTable.append(
                                    '<tr>' +
                                    '<td class="layerInfoLabel">Date To:</td>' +
                                    '<td>' + analysis.params.toDate + '</td>' +
                                    '</tr>'
                                );
                            }
                            paramsTable.append(
                                '<tr>' +
                                '<td class="layerInfoLabel">Animals: </td>' +
                                '<td>' + analysis.params.animalNames.join(', ') + '</td>' +
                                '</tr>'
                            );
                            <c:forEach items="${analysisTypeList}" var="analysisType">
                            if (analysis.analysisType == '${analysisType}') {
                                <c:forEach items="${analysisType.parameterTypes}" var="parameterType">
                                if (analysis.params.${parameterType.identifier}) {
                                    paramsTable.append(
                                        '<tr>' +
                                        '<td class="layerInfoLabel">${parameterType.displayName}: </td>' +
                                        '<td>' + analysis.params.${parameterType.identifier} + ' ${parameterType.units}</td>' +
                                        '</tr>'
                                    );
                                }
                                </c:forEach>
                            }
                            </c:forEach>
                            div.append(paramsTable);

                            var footerList = $('<ul class="analysis-content-footer icons">');
                            if (analysis.status == 'COMPLETE') {
                                footerList.append($('<li>')
                                    .addClass('add-layer')
                                    .append(
                                        $('<a>')
                                            .attr('href', 'javascript:void(0);')
                                            .text('Add anlaysis to map')
                                            .click(function(e) {
                                                analysisMap.addAnalysisLayer(analysisUrl, layerName, 'analysis');
                                            })
                                    )
                                );
                                <sec:authorize access="hasPermission(#project, 'write')">
                                footerList.append($('<li>')
                                    .addClass(saved ? 'delete' : 'create')
                                    .append(
                                        $('<a>')
                                            .attr('href', 'javascript:void(0);')
                                            .text(saved ? 'Remove analysis' : 'Save analysis')
                                            .click(function(e) {
                                                jQuery.ajax({
                                                    url: analysisUrl + '/saved',
                                                    type: 'PUT',
                                                    contentType: "application/json",
                                                    data: (saved ? 'false' : 'true'),
                                                    success: function() {
                                                        addAnalysis(layerName, analysisUrl, analysisCreateDate, !saved);
                                                        var li = $(e.target).closest('li.analysis');
                                                        if (li.siblings().length == 0) {
                                                            li.parent().prev().andSelf().fadeOut();
                                                        }
                                                        li.remove();
                                                    },
                                                    error: function() {
                                                        alert('Could not save analysis.');
                                                    }
                                                });
                                            })
                                    )
                                );
                                </sec:authorize>
                            }
                            else if ((analysis.status == 'NEW') || (analysis.status == 'PROCESSING')) {
                                footerList.append($('<li>')
                                    .addClass('processing')
                                    .append('Processing')
                                );
                            }
                            else if (analysis.status == 'FAILED') {
                                footerList.append($('<li>')
                                    .addClass('error')
                                    .append('Error: ' + analysis.message || 'unknown error')
                                );
                            }
                            div.append(footerList);

                            div.slideDown();
                        }
                    }
                });
                return div;
            }
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
                //distanceCharts.adjustChartTabs();
                chartTabs();

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
                <li><a href="#homeRangeCalculatorPanel">Spatial</a></li>
                <li><a href="#temporalPanel">Temporal</a></li>
                <li><a href="#previousAnalysesPanel">History</a></li>
                <li><a href="#metadataPanel">Metadata</a></li>
            </ul>
            <div id="animalPanel">

                <div id="allAnimals" class="layerInfo">
                    <div class="layerInfoHeader">All Animals</div>
                    <div class="layerInfoStats">
                        <span class="layerInfoStat">Date Range:
                        <fmt:formatDate pattern="${isoDateFormatPattern}" value="${projectDetectionDateRange.minimum}"/> to
                        <fmt:formatDate pattern="${isoDateFormatPattern}" value="${projectDetectionDateRange.maximum}"/></span>
                        <span class="layerInfoStat">Animals: ${projectAnimalsList.size()}</span>
                    </div>
                    <div class="layerInfoExport">
                        <div>
                        Detections Layer
                        <span class="layerInfoActions">
                            <a class="icon kml" href="${pageContext.request.contextPath}/detections?projectId=${project.id}&format=kml">KML</a>
                            <a class="icon shp" href="${pageContext.request.contextPath}/detections?projectId=${project.id}&format=shp">SHP</a>
                        </span></div>
                        <div style="margin-top:5px">
                        Trajectory Layer
                        <span class="layerInfoActions">
                            <a class="icon kml" href="${pageContext.request.contextPath}/trajectory?projectId=${project.id}&format=kml">KML</a>
                            <a class="icon shp" href="${pageContext.request.contextPath}/trajectory?projectId=${project.id}&format=shp">SHP</a>
                        </span></div>
                    </div>
                </div>

                <div class="animalHeader" style="margin-top: 0; border-bottom: 1px solid #ccc;">
                <div class="animalCheckbox">
                    <input
                        id="select-animal-all"
                        type="checkbox"
                        style="float: left; margin: 0;" />
                </div>
                <div class="smallSquare" style="background-color: transparent;"></div>
                <div>Select all</div>
                </div>

                <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                    <c:set var="showAnimalInfo" value='false'/>
                    <div class="animalHeader">
                        <div class="btn-group" style="float: right;">
                            <button
                                class="btn btn-small"
                                title="Zoom to animal"
                                onclick="analysisMap.zoomToAnimal('${animal.id}');">
                                <i class="icon-zoom-in"></i>
                            </button>
                            <button
                                id="buttonShowHide${animal.id}"
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
                    <div id="animalInfo-${animal.id}" class="animalInfo" style="display: ${showAnimalInfo ? 'block' : 'none'};">
                    </div>
                </c:forEach>
            </div>

            <div id="homeRangeCalculatorPanel">

                <form id="form-context" class="form-vertical" style="margin: 0;" method="POST" onsubmit="return false;">
                    <input id="projectId" type="hidden" value="${project.id}"/>
                    <fieldset>
                    <div style="margin-bottom: 9px; font-weight: bold;">
                        <span>Dates</span>
                        <div class="help-popover" title="Dates">
                            Choose a date range from within your data file for analysis.
                            If left blank, all data for the selected animals will be included in the analysis.
                        </div>
                    </div>
                    <div class="control-group" style="margin-bottom: 9px;">
                        <div class="controls">
                            <input id="fromDate" type="hidden"/>
                            <input id="toDate" type="hidden"/>
                            <input id="fromDateVisible" type="text" class="datepicker" placeholder="From" style="margin-bottom: 0px; width: 80px;"/> -
                            <input id="toDateVisible" type="text" class="datepicker" placeholder="To" style="margin-bottom: 0px; width: 80px;"/>
                        </div>
                    </div>
                    <div style="margin-bottom: 9px; font-weight: bold;">
                        <span>Animals</span>
                        <div class="help-popover" title="Animals">
                            Choose one or more animals for analysis and visualisation.
                            ZoaTrack can generate layers for multiple animals at a time; however, the processing time is
                            positively related to the number of animals and location fixes included in the analysis.
                        </div>
                    </div>
                    <div class="control-group" style="margin-bottom: 9px;">
                        <div id="animalsFilter" class="controls">
                            <div style="background-color: #d8e0a8;">
                            <div class="animalsFilterCheckbox">
                                <input
                                    id="filter-animal-all"
                                    type="checkbox"
                                    style="width: 15px;" />
                            </div>
                            <div class="animalsFilterSmallSquare" style="background-color: transparent;"></div>
                            <div class="animalsFilterLabel">Select all</div>
                            </div>
                            <div style="clear: both;"></div>
                            <c:forEach items="${projectAnimalsList}" var="animal" varStatus="animalStatus">
                            <a style="display: inline-block; float: right;" href="javascript:analysisMap.zoomToAnimal('${animal.id}');"><i class="icon-zoom-in"></i></a>
                            <div class="animalsFilterCheckbox">
                                <input
                                    id="filter-animal-${animal.id}"
                                    class="filter-animal"
                                    name="animal"
                                    type="checkbox"
                                    value="${animal.id}"
                                    style="width: 15px;"
                                    checked="checked" />
                            </div>
                            <div class="animalsFilterSmallSquare" style="background-color: ${animal.colour};"></div>
                            <div class="animalsFilterLabel">${animal.animalName}</div>
                            <div style="clear: both;"></div>
                            </c:forEach>
                        </div>
                    </div>
                    </fieldset>
                </form>

                <div style="margin-bottom: 9px; font-weight: bold;">Project layers</div>
                <div class="accordion" id="accordion-projectLayers">
                    <c:forEach items="${mapLayerTypeList}" var="mapLayerType">
                    <div class="accordion-group">
                        <div class="accordion-heading">
                            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion-projectLayers" href="#accordion-body-${mapLayerType}">
                                ${mapLayerType.displayName}
                            </a>
                        </div>
                        <div id="accordion-body-${mapLayerType}" class="accordion-body collapse">
                            <div class="accordion-inner">
                                <form id="form-${mapLayerType}" class="form-projectLayer form-vertical" style="margin: 0;">
                                <input type="hidden" name="layerTypeValue" value="${mapLayerType}" />
                                <input type="hidden" name="layerTypeLabel" value="${mapLayerType.displayName}" />
                                <fieldset>
                                <div class="control-group" style="margin-bottom: 9px;">
                                <div class="controls">
                                    <div class="layerExplanation">
                                        ${mapLayerType.explanation}
                                    </div>
                                </div>
                                </div>
                                <div>
                                    <button class="btn btn-primary" type="submit">Show layer</button>
                                </div>
                                </fieldset>
                                </form>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
                </div>

                <div style="margin-bottom: 9px; font-weight: bold;">Analysis layers</div>
                <div class="accordion" id="accordion-analysisLayers">
                    <c:forEach items="${analysisTypeList}" var="analysisType">
                    <div class="accordion-group">
                        <div class="accordion-heading">
                            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion-analysisLayers" href="#accordion-body-${analysisType}">
                                ${analysisType.displayName}
                            </a>
                        </div>
                        <div id="accordion-body-${analysisType}" class="accordion-body collapse">
                            <div class="accordion-inner">
                                <form id="form-${analysisType}" class="form-analysisLayer form-vertical" style="margin: 0;">
                                <input type="hidden" name="layerTypeValue" value="${analysisType}" />
                                <input type="hidden" name="layerTypeLabel" value="${analysisType.displayName}" />
                                <fieldset>
                                <div class="control-group" style="margin-bottom: 9px;">
                                <div class="controls">
                                    <c:if test="${not empty analysisType.explanation}">
                                    <div class="layerExplanation" style="max-height: 54px; overflow-y: hidden;">
                                        ${analysisType.explanation}
                                    </div>
                                    <a class="layerExplanationExpander" href="#read-more">
                                        Read more
                                    </a>
                                    </c:if>
                                    <div id="paramContainer-${analysisType}" class="paramContainer">
                                        <tags:analysis-param-fields analysisType="${analysisType}"/>
                                    </div>
                                </div>
                                </div>
                                <div>
                                    <button class="btn btn-primary" type="submit">Calculate</button>
                                </div>
                                </fieldset>
                                </form>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </div>

            <div id="temporalPanel">
                <div id="projectCharts" width="100%">
                    <div id="chart-menu">
                        <div class="scroller scroller-left"><i class="icon-chevron-left"></i></div>
                        <div class="scroller scroller-right"><i class="icon-chevron-right"></i></div>
                        <div id="chart-tab-wrapper">
                            <ul id="chart-menu-tabs" class="nav nav-tabs">
                                <c:if test="${currentUser.admin}">
                                    <li class="chart-menu-tab-li"><a id="export-traits-open">Species Traits</a></li>
                                </c:if>
                                <li class="chart-menu-tab-li"><a id="export-open">Export</a></li>
                            </ul>
                        </div>
                        <div class="tab-content">
                            <div class="tab-pane" id="exp-conf" style="line-height:1px;">
                            </div>
                        </div>
                    </div>
                    <div id="chartArea">
                    <div id="chartTitle"></div>
                    <div id="chartHelp">
                        <div class="help-popover" title="Temporal Analysis">
                            The graphs are interactive. The smaller graph is a navigator window for the larger graph. You can:
                            <ul>
                                <li>Zoom in by double-clicking on the graph canvas, or by using a mouse scroll</li>
                                <li>Zoom out by shift-double-clicking</li>
                                <li>Drag on either canvas to pan the graph</li>
                                <li>Hover over a data point to see detail</li>
                                <li>Click on an animal in the legend to add/remove it from the graph</li>
                            </ul>
                        </div>
                    </div>
                    <div id="chartDescription"></div>
                    <div id="exportTemporal" class="form-bordered exportConfirmation" style="display: none;">
                        <p>Data in this project are made available under the following licence:</p>
                        <p style="margin-top: 18px;">
                            <a target="_blank" href="${project.dataLicence.infoUrl}"
                            ><img src="${pageContext.request.scheme}://${fn:substringAfter(project.dataLicence.imageUrl, '://')}" /></a>
                        </p>
                        <p><span style="font-weight: bold;">${project.dataLicence.title}</span></p>
                        <p>${project.dataLicence.description} <a target="_blank" href="${project.dataLicence.infoUrl}">More information</a></p>
                        <p style="margin-top: 18px;">By downloading these data, you agree to the licence terms.</p>
                        <p>
                            If you use these data in any type of publication then you must cite the project DOI (if available) or any
                            published peer-reviewed papers associated with the study. We strongly encourage you to contact the data custodians
                            to discuss data usage and appropriate accreditation.
                        </p>
                        Download:<br/>
                        <div class="form-actions">
                            <a class="exportButton btn btn-primary" href="${pageContext.request.contextPath}/projects/${project.id}/analysis/posfixexport" download>Data</a>
                            <a class="exportButton btn btn-primary" id="chart-img">Image</a>
                            <button id="export-close" class="btn" style="position: absolute; right: 50px;">Close</button>
                        </div>
                    </div>

                    <c:if test="${currentUser.admin}">
                        <div id="exportTraits" class="form-bordered exportConfirmation" style="display:none;">
                            <img src="${pageContext.request.contextPath}/img/logo_bccvl.png" style="margin-bottom:10px;"/>

                            <c:choose>
                            <c:when test="${project.access == 'OPEN'}">
                                <c:set var="bccvlMsg" value=""/>
                                <c:set var="bccvlButtonText" value="Authorise BCCVL modelling capability"/>
                                <c:set var="bccvlButtonUrl" value="${pageContext.request.contextPath}/projects/${project.id}/analysis/bccvl-init"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="bccvlMsg" value="<p>To do this you can download the trait data using the link below. Login to BCCVL, upload the dataset then navigate to Experiments to create a new Species Trait Modelling Experiment.</p>"/>
                                <c:set var="bccvlButtonText" value="Open BCCVL"/>
                                <c:set var="bccvlButtonUrl" value="http://bccvl.org.au"/>
                                <c:set var="bccvlNewWindow" value="target='_blank'"/>
                            </c:otherwise>
                            </c:choose>
                            <span id="bccvl-actions">
                                <span id="bccvl-message"><p>The temporal data in this project can be exported as species traits to the BCCVL for use in a
                                    Generalized Linear Mixed Model Experiment. This model allows you to test the effect of environmental variables on species traits.</p>
                                    ${bccvlMsg}</span>
                                <div id="bccvl-loading" style="display:none"><img src="${pageContext.request.contextPath}/img/map-loading.gif"/></div>
                                <a id="bccvl-button" class="exportButton btn btn-primary" href="${bccvlButtonUrl}" ${bccvlNewWindow}>${bccvlButtonText}</a>
                                <a id="refresh-button" class="btn btn-primary" onClick="window.location.reload()" style="display:none">Refresh</a>
                                <a id="traits-button" class="btn" style="position: absolute; right: 110px;" href="${pageContext.request.contextPath}/projects/${project.id}/analysis/traitexport">Download Traits Data</a>
                                <button id="export-traits-close" class="btn" style="position: absolute; right: 50px;">Close</button>
                            </span>
                        </div>
                    </c:if>
                    <div id="chartDiv"><svg id="svgChart"></svg></div>
                    <div id="legendDiv"></div>
                    </div>
                </div>
            </div>

            <div id="previousAnalysesPanel">
                <div id="savedAnalysesTitle" style="display: none; margin-bottom: 9px; font-weight: bold;">Saved Analyses</div>
                <ul id="savedAnalysesList" class="unstyled" style="display: none;">
                </ul>
                <div id="previousAnalysesTitle" style="display: none; margin-bottom: 9px; font-weight: bold;">Previous Analyses</div>
                <ul id="previousAnalysesList" class="icons" style="display: none;">
                </ul>
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
