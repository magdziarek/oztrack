<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<tags:page title="Toolkit">
    <jsp:attribute name="description">
        ZoaTrack is a free-to-use web-based platform
        for analysing and visualising individual-based animal location data.
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/home.js"></script>
        <script type="text/javascript">


            $(document).ready(function() {
                $('#navToolkit').addClass('active');
                $('#toolkit-tabs a[href="#${section}"]').tab('show');
            });


        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <span class="active">Toolkit</span>
    </jsp:attribute>
    <jsp:body>

        <c:if test="${!empty section}">
            <input type="hidden" id="nav-section" value="${section}"/>
        </c:if>

        <div class="tabbable" >

            <ul class="nav nav-tabs" id="toolkit-tabs">
                <li class="active"><a href="#getstarted" data-toggle="tab">Getting Started</a></li>
                <li><a href="#analysis" data-toggle="tab">The Analysis Toolkit</a></li>
                <li><a href="#datamgt" data-toggle="tab">Data Management</a></li>
                <li><a href="#doi" data-toggle="tab">Digital Object Identifiers</a></li>
            </ul>

            <div class="tab-content">

                <div class="tab-pane active" id="getstarted">

                    <ul style="list-style-type:none">
                        <li><a href="#user-reg">Registering an account with ZoaTrack</a></li>
                        <li><a href="#proj-create">Creating a project</a></li>
                        <li><a href="#data-upload">Uploading data</a></li>
                        <li><a href="#data-vis">Viewing tracks</a></li>
                        <li><a href="#mov-metrics">Extracting movement metrics</a></li>
                    </ul>
                    <hr/>


                    <div class="media" id="user-reg">
                        <h4 class="media-heading">Registering an account with ZoaTrack</h4>
                        <div class="media-body">
                            <p> To create a new profile in ZoaTrack, click on the Register button in the website header, and fill out the relevant form.
                                To complete the process, type in the password in the Verification box and click ‘Register’. </p>
                            <p>If you had an OzTrack login, this will also work for ZoaTrack.</p>
                        </div>
                    </div>
                    <hr/>


                    <div class="media" id="proj-create">
                        <h4 class="media-heading">Creating a Project</h4>
                           <div class="media-body">
                             <p>Prior to this step you should have first registered an account with ZoaTrack.net or OzTrack.org.
                               If you haven’t done so already, log in to ZoaTrack using your username and password.</p>

                             <ul>
                                 <li>Click the Toolkit Icon in the website header and select Create a Project.</li>
                               <li>Fill in the relevant Project Metadata associated with your New Project to add details about you and your data set. </li>
                               <li> The species field should automatically find a correctly spelled species name. If not this can be manually entered by clicking the tick box.</li>
                               <li>The Spatial Coordinates section ensures that your geographical locations are plotted correctly and that area measurements will be accurate.  If your study was conducted in Australia or New Zealand, we have made selecting the correct Spatial Reference System more straight forward – EPSG: 3577 if your animal ranged throughout the country, or by selecting the more local Australian or New Zealand SRS systems appropriate for your study area.  If you’re animal was tracked in a different region, you can find the relevant one by searching for international SRS codes.
                               If you expect your animal to fly, swim or crawl across the Pacific Ocean, you might want to click the ‘Crosses 180’ box to compensate for any Antimeridian issues with projecting the data. </li>
                               <li>Project Contributors -  Add the names of the people in your tracking group. This will be straightforward if each group member has created a separate OzTrack or ZoaTrack account.
                               </li><li>Availability – While ZoaTrack promotes data access and availability, we empower users to apply their own copyright and protection level for this dataset. This varies from fully open projects with no licencing or highly restrictive copyright laws. Click the relevant box highlighting what protection you have for your data set.
                             </li>
                           </ul>
                               <p>Click ‘Create Project’ to save your project. This page now displays the description data associated with you and your project.</p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="data-upload">
                        <div class="media-body">
                            <h4 class="media-heading">Uploading Data</h4>
                            <p>
                                Under ‘Manage Project’ box on the Project page, click ‘Upload data file’ to upload your location data.
                                Under File Description, enter the a description of the file that you’re uploading – e.g. “toad locations”. If your data was recorded in GMT, you can convert to your local time by checking the convert to local time box and adding the required hours (e.g. Brisbane Australia would be GMT +10) .
                                Locate the file containing your tracks and click ‘Upload data file’ to finalise the upload.
                                When the file has uploaded successfully, it should read ‘File Status = COMPLETE’.
                            </p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="data-vis">
                        <div class="media-body">
                            <h4 class="media-heading">Viewing tracks</h4>
                                <p>
                                    Once a tracking dataset has been uploaded, the tracks can be accessed from the Project page by clicking ‘Tracks and analysis’ (located on the top panel under the Project menu) , or by clicking the View Tracks icon in the right of the screen.
                                    Alternatively, existing tracks can be accessed from Open projects (or projects that you have access rights to) directly from the ZoaTrack Repository. These can be accessed by clicking Browse the Repository in the website header, then searching for your relevant project – e.g. “Bush rat Translocation”
                                    This opens an interactive map showing the relocations contained in the tracking file plotted on a Google maps layer. Also shown are the trajectory the animals took (lines) and the start and end locations (green and red points).
                                    The page always faces due north, and a scale is displayed in the bottom left of the map. In the top left of the map are tools to pan (hand) and zoom (+/-) around the map and measure distances (ruler).
                                </p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="mov-metrics">
                        <div class="media-body">
                            <h4 class="media-heading">Extracting movement metrics</h4>
                            <p>
                                On visualising the animal tracks, movement metrics for each tagged animal are provided in the left hand window. These include:</p>
                                <ol>
                                    <li>the date range</li>
                                    <li>the total number of locations for that animal</li>
                                    <li>the mean number of detections per day</li>
                                    <li>the maximum number of detections per day</li>
                                    <li>the distance moved along the track (km) – Estimated using Great circle distances on longitude latitude coordinates (Decimal Degrees)</li>
                                    <li>the mean step length (km)</li>
                                    <li>the mean step speed (km/h)</li>
                                </ol>
                            <p>These field are automatically updated when a new date range is provided, or if tracks are edited using the Edit tracks tool.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="tab-pane" id="analysis">

                    <p>
                        ZoaTrack provides a series of tools with which to analyse your animal tracking datasets.
                        These include tools to visualise and extract movement metrics from tagged animals based on a date range (project layers: Trajectory and Detections) and tools to run more complex spatial analyses and extract home range estimates.
                        These tools are available on the Tracks and analysis page by clicking the ‘Analysis’ tab and selecting a one of the tools.
                    </p>

                    <ul style="list-style-type:none">
                        <li><a href="#home-range">Calculate home range area</a></li>
                        <c:forEach items="${analysisTypeList}" var="analysisType">
                            <li><a href="#${analysisType.toString()}"><c:out value="${analysisType.displayName}"/></a></li>
                        </c:forEach>
                    </ul>
                    <hr/>

                    <div class="media" id="home-range">
                        <h4>Calculate home range area</h4>
                        <div class="media-body">
                            <p>
                            The following tools estimate each animal’s home range as a measure of individual space usage. An animal’s home range is the area in which it lives and travels. This area is closely related to (but not identical with) the concept of "territory", which is the area that is actively defended by an individual. There are many variations of home range analysis, each has its own advantages and disadvantages depending on the data. More information and links to the respective publications are obtained by clicking the (?) located next to each home range tool. The choice of home range estimator and the parameter values can have a huge bearing on the final home range estimates.
                            It is also possible to limit the date range (Dates) and/or the Animals from which home ranges and movement metrics are generated. Simply edit the date range and select the animals you are interested in, and then run the analyses. The results are displayed under the Animals tab in the left panel of the screen.
                            </p>
                        </div>
                    </div>
                    <hr/>

                    <c:forEach items="${analysisTypeList}" var="analysisType">

                        <div class="media" id="${analysisType.toString()}">
                            <h4><c:out value="${analysisType.displayName}"/></h4>
                            <div class="media-body">
                              ${analysisType.explanation}
                            </div>
                        </div>
                        <hr/>

                    </c:forEach>

                </div>

                <div class="tab-pane" id="datamgt">

                    <ul style="list-style-type:none">
                        <li><a href="#g-earth">Exploring the data in Google Earth</a></li>
                        <li><a href="#access">Sharing access to your project with collaborators</a></li>
                        <li><a href="#format">Formatting tracks</a></li>
                        <li><a href="#erron">Filtering erroneous data points</a></li>
                        <li><a href="#speed">Speed Filter</a></li>
                        <li><a href="#argos">Argos Location Class and Dilution of Precision Filter</a></li>
                        <li><a href="#kalman"> Kalman filter and Kalman filter SST</a></li>
                    </ul>


                <div class="media" id="g-earth">
                    <h4>Exploring the data in Google Earth</h4>
                    <div class="media-body">
                        <p>
                            To gain a fuller understanding of the movements of the animals, it is useful to visualise the animal’s trajectory through time.
                        </p>
                        <ol>
                            <li>If not already installed, download Google earth from  http://www.google.com/earth/index.html</li>
                            <li>In ZoaTrack, make sure you are still on the ‘Animals’ tab in the Tracks and analysis page.</li>
                            <li>Below an animal ID, click ‘KML’ in the Trajectory box. This will convert the ZoaTrack -generated trajectory into a Google earth file.</li>
                            <li>Click the downloaded .kml file to open and view in Google earth.</li>
                            <li>The tracks in your ZoaTrack project are now visible with the last location represented as an arrow. You can visualise the animal’s trajectory through time by moving the time slider in the top left corner of Google Earth.</li>
                            <li>To visualise the home ranges, click ‘KML’ in the MCP results box or that of any other home ranges you may have generated. This will convert the ZoaTrack -generated home range polygon into a Google Earth file.</li>
                            <li>Click the downloaded .kml file to open and view in Google earth.
                        </ol>
                    </div>
                </div>
                <hr/>

                <div class="media" id="access">
                    <h4>Sharing access to your project with collaborators</h4>
                    <div class="media-body">
                        <p>
                            To provide other ZoaTrack/OzTrack users with access to your project, you must have either Writer or Manager access to an existing tracking project. Click the Project Icon on the Tracks and Analysis screen to return to the Project page. Under Data Access you can assign new users to the open project. Managers have the highest level of access (ability to delete a project), Writers can add new data to a project and Readers can only view the projects and apply a subset of analysis tools.
                        </p>
                    </div>
                </div>
                <hr/>

                <div class="media" id="format">
                    <h4>Formatting tracks</h4>
                    <div class="media-body">
                        <p>
                            If you would like to change the colour, name or add a description field to this animal, you need to have either Writer or Manager access to a tracking project.
                            Click the down arrow next to ‘Project’ in the website header and select ‘Animal details’
                            Click the edit box   next to one of your animals
                            To edit how this animal is referred to in ZoaTrack, edit the Name field under Animal details. You can also add a description and change the animal colour. This will change the colour of all tracks and any home ranges generated using these data.
                            Click ‘Update’ to complete your changes and Click ‘Tracks and analysis’ to visualise the animal trajectories.
                        </p>
                    </div>
                </div>
                <hr/>


                <div class="media" id="erron">
                    <h4>Filtering erroneous data points</h4>
                    <div class="media-body">
                        <p>
                            For this tool you must have either Writer or Manager access to an existing tracking project.
                            In all telemetry methodologies, you may need to edit the tracks to remove erroneous fixes. This may be due to an error in data entry (common in in VHF radio-tracking studies), early activation of tags before deployment (common in GPS/PTT tracking studies), or through location error (all the above!).
                            ZoaTrack provides a number of tools that you can call on to adjust filter your dataset. These include speed and location class filters, kalman filters and simple polygon selecting functionality to draw around locations to be deleted.
                            To access these tools, click the down arrow next to ‘Project’ in the site header and select ‘Edit tracks’. 	In the right window you will have your animal locations displayed on the map. In your left window you will have tools to edit and filter your animal tracks
                            Polygon selection
                            Click ‘Polygon selection’ and try clicking a polygon around a point, then double click to complete the polygon.
                            Click ‘Delete selected’ to remove point(s) from further analysis
                            Click ‘Restore selected’ to restore points within a created polygon or ‘Restore all’ to restore ALL deleted points.
                        </p>
                    </div>
                </div>
                <hr/>


                <div class="media" id="speed">
                    <h4>Speed filter</h4>
                    <div class="media-body">
                        <p>
                            You can select a speed filter to remove unlikely locations (i.e. those where the animal would have to attain a certain sustained velocity to achieve: e.g.> 50 km/h). To use this tool, click Speed filter and type in a Maximum speed that you animal could hypothetically obtain. Click Apply filter and those relocations exceeding this maximum will have been removed.
                            When you are happy with your tracks, click the arrow next to ‘Back to Project’ at the top of the left panel and select ‘Tracks and analysis’.
                        </p>
                    </div>
                </div>
                <hr/>

                <div class="media" id="argos">
                    <h4>Argos Location Class and Dilution of Precision Filter</h4>
                    <div class="media-body">
                        <p>
                            If your location dataset had a column containing the Argos Location Class (Argos tracking data only) or a DOP Class (GPS data only), this filter can be applied to remove locations with a low estimated accuracy. To use this tool, click the relevant filter (Argos or DOP) and apply the minimum accuracy with which you wish to visualise and run subsequent analyses on. Click Apply filter and those relocations exceeding this minimum will have been removed.
                            When you are happy with your tracks, click the arrow next to ‘Back to Project’ at the top of the left panel and select ‘Tracks and analysis’
                        </p>
                    </div>
                </div>
                <hr/>

                <div class="media" id="kalman">
                    <h4>Kalman filter and Kalman filter SST</h4>
                    <div class="media-body">
                        <p>
                            Often telemetry technologies with low precision and accuracy can result in highly improbable animal trajectories. For example, studies on the accuracy of light-based geolocation have recognized that raw geolocations are often imprecise and biased, particularly for estimates of latitude during equinox periods.
                            The state-space Kalman filter approach can estimate the “most probable” track from imprecise and biased location estimates (and sea surface information if it is available from the tag sensor). These models are adapted from the kftrack and ukfsst functions developed by Nielsen and Sibert, 2004 and Lam, Nielsen & Sibert, 2008.
                            Click Kalman filter and use your known information on the start and end date and location to match the actual days when the tag was deployed and retrieved. By providing a known start and end location, this can often provide a more realistic track for a given set of noisy data. Note, please enter the numbers only, without units (e.g. without ° E)
                            Click Run filter to run the kalman filter (kftrack) on the raw geolocation data.
                            The spinning wheel will show that ZoaTrack is processing your request. Once the Kalman filter is complete, the ‘most probable’ track (white triangles) will be overlaid on the original track. On completion the model parameters and model results will be displayed on the left of the map
                            Models can also be re-run with a new set of parameters by editing the Advanced parameters fields.  The systematic error (or bias) in the estimation of position of Longitude and Latitude can be changed to 0 degrees by deselecting bx.active and by.active buttons. The systematic error can be adjusted on the Longitude and Latitude by entering the predicted error.
                            Click Run filter to re-run the kalman filter
                            To replace the original track and calculate the movement metrics for this filtered track (i.e. track length, step length, speed), click Replace track. The original data points now appear as red crosses.
                            When you are happy with your tracks, click the arrow next to ‘Back to Project’ at the top of the left panel and select ‘Tracks and analysis’. The movement metrics for the Kalman filtered track are now displayed in the left hand window
                        </p>
                    </div>
                </div>
                <hr/>
            </div>

                <div class="tab-pane" id="doi">
                    <ul style="list-style-type:none">
                        <li><a href="#doi-1">Overview</a></li>
                        <li><a href="#doi-2">What's a DOI?</a></li>
                        <li><a href="#doi-3">What data does ZoaTrack publish?</a></li>
                        <li><a href="#doi-4">What metadata does ZoaTrack publish?</a></li>

                    </ul>
                    <div class="media" id="doi-1">
                        <h4>Overview</h4>
                        <div class="media-body">
                            <p>ZoaTrack provides a DOI minting service via ANDS and DataCite. A user with 'manage' access to a ZoaTrack project, the manager, can create a package eligible for a DOI
                            from the DOI Request page within the 'Manage Project' menu. If the project satisfies the minimum criteria, the manager will be able to click a button to create
                            a zip file containing plain text files of project metadata and data.</p>
                            <p>The manager can edit the package by editing the project and rebuilding it as many times as they like.</p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="doi-2">
                        <h4>What's a DOI?</h4>
                        <div class="media-body">
                            <p>A DOI is a Digital Object Identifier.
                            </p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="doi-3">
                        <h4>What data does ZoaTrack publish?</h4>
                        <div class="media-body">
                            <p>When a project manager requests a DOI, the package will contain a snapshot of all data in that project as at that date.
                               As yet ZoaTrack can't update a DOI, or refresh it to contain new data. The publication is based on the
                                data in the zip file only.  If new data is uploaded to the project after the DOI is minted, it won't be included.</p>
                            <p>The DOI includes detections that have been deleted from the project, flagged as deleted.</p>
                        </div>
                    </div>
                    <hr/>

                    <div class="media" id="doi-4">
                        <h4>What metadata does ZoaTrack publish?</h4>
                        <div class="media-body">
                            <p>ZoaTrack will include all of the project metadata and animal/tag deployment metadata that is included in the project. The project
                            metadata is the set of fields that are filled out when the project is created, although you can edit this by following an 'Edit Project'
                                link. </p>
                            <p>Animal/tag metadata can be populated by following the links in a project to 'View Animals' and finding an 'Edit' link.</p>
                        </div>
                    </div>
                    <hr/>

                </div>
            </div>
        </div>


    </jsp:body>
</tags:page>
