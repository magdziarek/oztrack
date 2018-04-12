/*global OpenLayers*/

(function(OzTrack) {
    OzTrack.SimpleMap = function(div, options) {
        if (!(this instanceof OzTrack.SimpleMap)) {
            throw new Error('Constructor called as a function');
        }
        var that = this;

        that.projectMap = new OzTrack.ProjectMap(div, {
            project: options.project,
            animals: options.animals,
            onUpdateAnimalInfoFromLayer: options.onUpdateAnimalInfoFromLayer
        });

        that.addProjectMapLayer = function(layerTypeValue, layerTypeLabel) {
            var layerName = layerTypeLabel;
            var params = {
                projectId: $('#projectId').val(),
                fromDate: $('#fromDate').val(),
                toDate: $('#toDate').val(),
                animalIds:
                    $('input[name=animal]:not(:disabled):checked')
                        .map(function() {return $(this).val();})
                        .toArray()
                        .join(',')
            };
            $('.paramField-' + layerTypeValue).each(function() {
                if ($(this).attr('type') == 'checkbox') {
                    params[$(this).attr('name')] = $(this).is(':checked') ? 'true' : 'false';
                }
                else if ($(this).val()) {
                    params[$(this).attr('name')] = $(this).val();
                }
            });
            if (layerTypeValue == 'LINES') {
                var trajectoryLayer = that.projectMap.createTrajectoryLayer(params, 'analysis');
                that.projectMap.addLayer(trajectoryLayer.getWMSLayer());
            }
            else if (layerTypeValue == 'POINTS') {
                var detectionLayer = that.projectMap.createDetectionLayer(params, 'analysis');
                that.projectMap.addLayer(detectionLayer.getWMSLayer());
            }
            else if (layerTypeValue == 'START_END') {
                var startEndLayer = that.projectMap.createStartEndLayer(params, 'analysis');
                that.projectMap.addLayer(startEndLayer);
            }
            else {
                params.analysisType = layerTypeValue;
                that.projectMap.createAnalysisLayer(params, layerName, 'analysis');
            }
        };
        // Delegate to properties/functions of OzTrack.ProjectMap
        that.updateSize = that.projectMap.updateSize;
        that.zoomToAnimal = that.projectMap.zoomToAnimal;
        that.setAnimalVisible = that.projectMap.setAnimalVisible;

        // remove map feature calls
        var featureInfoControl = that.projectMap.map.getControlsBy("displayClass","OzTrackOpenLayersControlWMSGetFeatureInfo")[0];
        featureInfoControl.deactivate();
        that.projectMap.map.removeControl(featureInfoControl);

    };
}(window.OzTrack = window.OzTrack || {}));
