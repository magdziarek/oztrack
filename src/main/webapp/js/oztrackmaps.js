
function initializeHomeMap() {

    var map = new OpenLayers.Map('homeMap');
    var layerSwitcher = new OpenLayers.Control.LayerSwitcher();
    layerSwitcher.div = OpenLayers.Util.getElement('homeMapOptions');
    layerSwitcher.roundedCorner = false;
    map.addControl(layerSwitcher);

    var gphy = new OpenLayers.Layer.Google(
                "Google Physical",
                {type: G_PHYSICAL_MAP}
    );

    var gsat = new OpenLayers.Layer.Google(
                "Google Satellite",
                {type: G_SATELLITE_MAP}
    );

    map.addLayers([gsat,gphy]);
    map.setCenter(new OpenLayers.LonLat(133,-28),4);

}

function initializeProjectMap() {

    var projectId = $('#projectId').val();
    var googleProjection = new OpenLayers.Projection('EPSG:900913');
    var kmlProjection =  new OpenLayers.Projection("EPSG:4326");


    var mapOptions = {
       maxExtent: new OpenLayers.Bounds(
            -128 * 156543.0339,
            -128 * 156543.0339,
             128 * 156543.0339,
             128 * 156543.0339),
       maxResolution: 156543.0339,
       units: 'm',
       projection: googleProjection,
       displayProjection: kmlProjection
    };


    var map = new OpenLayers.Map('projectMap',mapOptions);
    var layerSwitcher = new OpenLayers.Control.LayerSwitcher();
    map.addControl(layerSwitcher);
    map.addControl(new OpenLayers.Control.MousePosition());
    map.addControl(new OpenLayers.Control.ZoomBox());

    var gphy = new OpenLayers.Layer.Google(
                "Google Physical",
                {type: google.maps.MapTypeId.TERRAIN}
    );
    var gsat = new OpenLayers.Layer.Google(
                "Google Satellite",
                {type: google.maps.MapTypeId.SATELLITE}
    );
    var points = new OpenLayers.Layer.Vector(
                "Points",
                {strategies: [new OpenLayers.Strategy.Fixed()],
                 protocol: new OpenLayers.Protocol.HTTP(
                    {url: "mapQuery",
                     params: {projectId:projectId, queryType:"ALL_POINTS"},
                     format: new OpenLayers.Format.KML(
                        {extractStyles: true,
                         extractAttributes: true,
                         maxDepth: 2,
                         internalProjection: googleProjection,
                         externalProjection: kmlProjection
                     })
                  })
                });

   /*
    var wkt = new OpenLayers.Format.WKT();
    wkt.internalProjection = googleProjection;
    wkt.externalProjection = kmlProjection;
    var boundingBox = wkt.read($('#projectBoundingBox').val());
    //var feature = new OpenLayers.Feature.Vector(boundingBox);
    //var bounds = boundingBox.geometry.getBounds();
    */

    map.addLayers([gsat,gphy,points]);
    //map.setCenter(new OpenLayers.LonLat(133,-28),4);
    map.setCenter(new OpenLayers.LonLat(133,-28).transform(kmlProjection,googleProjection), 4);
    var test=1;
}
    /*
    var points = new OpenLayers.Layer.WMS( "Points",
                  "http://localhost:9090/geoserver/oztrack/wms?",
                  { transparent:"true",
                    layers:'oztrack:positionfix',
                    format:'image/png'
                  },
                  {singleTile:"true"}
                  );
    */
    //alert("points: " + points.getURL());

    //map.zoomToExtent(bounds);

/*
    var request = OpenLayers.Request.POST({
    url: "mapQuery",
    data: OpenLayers.Util.getParameterString({projectId: "2"}),
    headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
    callback: requestHandler
    });
 */


function updateProjectMap() {

    alert("updateProjectMap() called.");
    map = new OpenLayers.Map("projectMap");
    alert("got map");

    var dateFrom = $('input[id=fromDatepicker]');
    var dateTo=$('input[id=toDatepicker]');
    var queryType =$('select[id=mapQueryTypeSelect]');

    var data= 'projectId=' + $('#projectId').val() +'&dateFrom=' + dateFrom.val() + '&dateTo=' + dateTo.val() + '&queryType=' + queryType.val();
    alert("data : " + data);

/*
    var points = new OpenLayers.Layer.Vector(
            "Points",
            {strategies: [new OpenLayers.Strategy.Fixed()],
             protocol: new OpenLayers.Protocol.HTTP(
                {url: "mapQuery",
                 params: {projectId:projectId, queryType:"ALL_POINTS"},
                 format: new OpenLayers.Format.KML(
                    {extractStyles: true,
                     extractAttributes: true,
                     maxDepth: 2
                 })
              })
            });
*/
}

function requestHandler(request) {
    // if the response was XML, try the parsed doc
    alert(request.responseXML);
    // otherwise, you've got the response text
    alert(request.responseText);
    // and don't forget you've got status codes
    alert(request.status);
    // and of course you can get headers
    alert(request.getAllResponseHeaders());
    // etc.

    // the server could report an error
    if(request.status == 500) {
        // do something to calm the user
    }
    // the server could say you sent too much stuff
    if(request.status == 413) {
        // tell the user to trim their request a bit
    }
    // the browser's parser may have failed
    if(!request.responseXML) {
        // get ready for parsing by hand
    }
    // etc.
}



function initialize() {

        var latlng = new google.maps.LatLng(-28.274398,133.775136);
        var myOptions = {
          zoom: 3,
          center: latlng,
          mapTypeId: google.maps.MapTypeId.SATELLITE
        };

        var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
        map.enableKeyDragZoom();

        var infowindow = new google.maps.InfoWindow({
                content: "loading...",
                maxWidth:1
            });

        // image icon
        var imageUrl="http://google-maps-icons.googlecode.com/files/amphitheater-tourism.png";
        var image = new google.maps.MarkerImage(imageUrl,
                                                new google.maps.Size(32,37),
                                                new google.maps.Point(0,0),
                                                new google.maps.Point(0,0),
                                                new google.maps.Size(16,18));


        var projects = [
        ['Test Project 1',-15.3351,144.1757, 1, '<div class="infowindow"><a href="#">Test Project 1</a><br>Kennedy River</div>' ],
        ['Test Project 2',-14.3351,145.1757, 2, '<div class="infowindow"><a href="#">Test Project 2</a><br>Wenlock River</div>']
        ];

        for (var i = 0; i < projects.length; i++) {
            var site = projects[i];
            var siteLatLng =  new google.maps.LatLng(site[1], site[2]);
            var marker = new google.maps.Marker({
               position: siteLatLng,
               map:map,
               title:site[0],
               zIndex:site[3],
               html:site[4],
               icon:image
            });

            google.maps.event.addListener(marker, "click", function () {
                infowindow.setContent(this.html);
                infowindow.open(map, this);
            })

        }
 }

 function initializeSightingMap() {

    var australia = new google.maps.LatLng(-32,134);
    var centralAustralia = new google.maps.LatLng(-24.01, 135.01);
    var myOptions = {
                    zoom: 3,
                    center: australia,
                    mapTypeId: google.maps.MapTypeId.SATELLITE,
                    streetViewControl: false,
                    mapTypeControl: true,
                    mapTypeControlOptions: {
                            style: google.maps.MapTypeControlStyle.DEFAULT
                            },
                    zoomControl:true,
                    zoomControlOptions: {
                            style: google.maps.ZoomControlStyle.SMALL
                            },
                    animation: google.maps.Animation.BOUNCE

                    };

    var sightingMap = new google.maps.Map(document.getElementById("sightingMap"), myOptions);
    sightingMap.enableKeyDragZoom();

    var marker = new google.maps.Marker({
               position: centralAustralia,
               map:sightingMap,
               draggable: true
               //title:site[0],
               //zIndex:site[3],
               //html:site[4],
               //icon:image
    });

    $('#sightingLatitude').val(centralAustralia.lat());
    $('#sightingLongitude').val(centralAustralia.lng());

    google.maps.event.addListener(marker, 'drag', function() {
        var point = marker.getPosition();
 		sightingMap.setCenter(point);
 		$('#sightingLatitude').val(point.lat());
        $('#sightingLongitude').val(point.lng());
    });

    google.maps.event.addListener(sightingMap, 'dragend', function() {
        var point = sightingMap.getCenter();
        marker.setPosition(point);
 		$('#sightingLatitude').val(point.lat());
        $('#sightingLongitude').val(point.lng());
    });

    google.maps.event.addListener(sightingMap, 'zoom_changed', function() {
        var point = sightingMap.getCenter();
        marker.setPosition(point);
 		$('#sightingLatitude').val(point.lat());
        $('#sightingLongitude').val(point.lng());
    });



 }

