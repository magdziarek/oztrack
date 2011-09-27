<%@ include file="header.jsp" %>
<!--script type="text/javascript" src="http://maps.google.com/maps?file=api&v=2&key=${initParam['api-key']}"></script-->
<script src="http://maps.google.com/maps/api/js?v=3.2&sensor=false"></script>
<script type="text/javascript" src="js/openlayers/OpenLayers.js"></script>
<script type="text/javascript" src="js/oztrackmaps.js"></script>

<h1><c:out value="${project.title}"/></h1>

<p style="color:red;"><c:out value="${errorMessage}"/></p>

<div class="mapTool">
<div id="projectMap"></div>
<div id="projectMapOptions">

<input type="hidden" value="${project.id}" id="projectId"/>
<input type="hidden" value="${project.boundingBox}" id="projectBoundingBox"/>

    <div id="mapDescription"></div>

    <form method="POST" id="mapToolForm" onsubmit="addProjectMapLayer(); return false;">

    <div id="accordion">

        <h3><a href="#">Map Layers</a></h3>
        <div id="customLayerSwitcher"></div>

        <h3><a href="#">Animals</a></h3>
        <div>
            <style>
                .legend {
                    border-collapse: collapse;
                    border-spacing: 2px;
                }
                .legend td {
                    border: 5px solid white;
                 }

            </style>
            <table class="legend">
            <c:forEach items="${projectAnimalsList}" var="animal">
                <tr>
                    <td><input type="checkbox" class="shortInputCheckbox" name="animalCheckbox" id="select-animal-${animal.projectAnimalId}" value="${animal.projectAnimalId}"/></td>
                    <td class="legend-colour" id="legend-colour-${animal.projectAnimalId}"><a href="#" onclick="zoomToTrack(${animal.projectAnimalId});">${animal.animalName}</a></td>
                    <script type="text/javascript">
                        $('input[id=select-animal-${animal.projectAnimalId}]').change(function() {
                                toggleAnimalFeature("${animal.projectAnimalId}",this.checked);
                        });
                    </script>
                    <td>
		        		<a href="<c:url value="exportKML"><c:param name="projectId" value="${project.id}"/><c:param name="animalId" value="${animal.id}"/></c:url>">
                		KML
                		</a>
            		</td>
                </tr>

                <!--
                need this style:
                .legend .legend-colour {
                    width: 12px;
                }
                <tr>
                    <td><input type="checkbox" class="shortInputCheckbox" name="selectAnimal" value="${animal.projectAnimalId}"/></td>
                    <td class="legend-value"><a href="#" onclick="zoomToTrack(${animal.projectAnimalId});">${animal.animalName}</a></td>
                    <td class="legend-colour" id="legend-colour-${animal.projectAnimalId}">&nbsp;</td>
                </tr>
                -->

            </c:forEach>
            </table>
        </div>

        <h3><a href="#">Filters</a></h3>
        <div>
            <b>Date Range:</b>
            <table>
             <tr>
                <td><b>From:</b></td>
                <td><input id="fromDatepicker" class="shortInputBox"/></td>
             </tr>
             <tr>
                <td><b>To:</b></td>
                <td><input id="toDatepicker" class="shortInputBox"/></td>
             </tr>
            </table>
        </div>

        <h3><a href="#">Layer Types</a></h3>
        <div>
         <style>
                .mapQueryType {
                    border-collapse: collapse;
                    border-spacing: 2px;
                }
                .mapQueryType td {
                    border: 5px solid white;
                 }

         </style>
             <label class="shortInputLabel">Add A Layer:</label> <br>
                <table class="mapQueryType">
                <c:forEach items="${mapQueryTypeList}" var="mapQueryType">
                    <c:if test="${!fn:contains(mapQueryType,'ALL_')}">
                        <tr>
                         <td><input class="shortInputRadioButton" type="radio" name="mapQueryTypeSelect" value="${mapQueryType}"/></td>
                         <td id="${mapQueryType}"><c:out value="${mapQueryType.displayName}"/></td>
                        </tr>
                    </c:if>
                </c:forEach>
                </table>
        </div>
    </div>
    <div class="formButton"><input type="submit" id="projectMapSubmit" value="Add a New Layer"/></div>
    </form>
</div>
<div class="clearboth">&nbsp;</div>
</div>



<%@ include file="footer.jsp" %>