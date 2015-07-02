<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>

<tags:page>
    <jsp:attribute name="description">
        ZoaTrack is a free-to-use web-based platform for analysing and visualising
        individual-based animal location data. Upload your tracking data now.
    </jsp:attribute>
    <jsp:attribute name="head">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/optimised/openlayers.css" type="text/css">
        <style type="text/css">

            #welcome-table h1 {
                margin: 4px 0px;
            }

            #blog-table td a {
                text-decoration: none;
            }

            #blog-table td {
                padding-top:15px;
                padding-bottom:15px;
                background-color:#ffffff;
            }

            #blog-table th {
                background-color: #e6e6c0;
                text-align:left;
                font-size: 1.1em;
            }

            #caro {
                width:900px;
                margin-left:20px;
            }

            .carousel-control {
                top:220px;
                margin-top: 0px;
                width: 35px;
                height: 45px;
            }


            .carousel-caption {
                left: auto;
                bottom: 0;
                top: 0;
                right: 0;
                width: 150px;
                font-size: 1.2em;
            }

            .carousel-caption a {
                color: #ffffff;
                text-decoration:none;
            }

            .carousel-caption a:hover {
                color:#D78B00;
            }

            .carousel-indicators {
                top: 240px;
                bottom: 15px;
                right: 80px;
            }

            .thumbnail {
                padding: 8px;
                background-color: #FFF;
                width:180px;
                margin-left:10px;
            }

            .thumbnails > li > a {
                text-decoration:none;
            }

            #by-line {
                font-size: 1.5em;
            }

        </style>
    </jsp:attribute>

  <jsp:attribute name="tail">
        <script src="${pageContext.request.scheme}://maps.google.com/maps/api/js?v=3.9&sensor=false"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/openlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/home.js"></script>
        <script type="text/javascript">

            function getBlogFeed(div) {
                $.ajax({
                    type: "GET",
                    url: '${pageContext.request.contextPath}/proxy/blog',
                    dataType: "xml",
                    success: function (xml) {

                        var contain = div;
                        var limit = 3;

                        $(xml).find('item').each(function (index) {
                            if (index < limit) {
                                var title = $(this).children('title').text();
                                var url = $(this).find('link').text();
                                var pubDate = $(this).find('pubDate').text();
                                $('#blog-table > tbody:last').append('<tr><td><a href="' + url + '" target="_blank">' + title + '</a></td></tr>');
                            }
                        });//end each
                    }
                });
            }

            $(document).ready(function() {
                $('#navHome').addClass('active');
                getBlogFeed($('#blog-list'));
                $('.carousel').carousel({interval: 20000});
            });

        </script>
    </jsp:attribute>


    <jsp:body>
        <div class="row">
            <div class="span12">
                <div id="caro" class="carousel slide">
                    <div class="carousel-inner">
                        <div class="item active"><img src="img/caro_proj_map.jpg">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/projects">
                                    Browse the animal tracking repository</a></div></div>
                        <div class="item"><img src="img/caro_cass_dooley.jpg">
                            <div class="carousel-caption">
                              <a href="${pageContext.request.contextPath}/projects/2/analysis">
                                  Choose from a range of analysis tools for your tracking dataset</a></div></div>
                        <div class="item"><img src="img/caro_cass_tag.jpg">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/projects/2/analysis">
                                    See our featured tracks for southern cassowaries in Australia</a></div></div>
                        <div class="item"><img src="img/caro_cass_edit.jpg">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/toolkit/datamgt">
                                    Easy to use cleansing and filtering tools for your animal tracking dataset</a></div></div>
                        <div class="item"><img src="img/caro_shearw.jpg">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/projects/93/analysis">
                                    Visualise tracks on a suite of remote sensing layers</a></div></div>
                        <div class="item"><img src="img/caro_croc_tag.png">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/projects/3/analysis">
                                    See our featured tracks for GPS-tagged saltwater crocodiles!</a></div></div>
                    </div>
                    <a class="carousel-control left" href="#caro" data-slide="prev">&lsaquo;</a>
                    <a class="carousel-control right" href="#caro" data-slide="next">&rsaquo;</a>
                    <div id="caro-ind">
                        <ol class="carousel-indicators">
                            <li data-target="#caro" data-slide-to="0" class="active"></li>
                            <li data-target="#caro" data-slide-to="1"></li>
                            <li data-target="#caro" data-slide-to="2"></li>
                            <li data-target="#caro" data-slide-to="3"></li>
                            <li data-target="#caro" data-slide-to="4"></li>
                            <li data-target="#caro" data-slide-to="5"></li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">

            <div id="welcome-div" class="span9">
                <span id="by-line">Calculate movement metrics and space use for individually marked animals anywhere in the world.</span>
                <hr/>
                <ul class="thumbnails">
                    <li> <a href="${pageContext.request.contextPath}/toolkit/getstarted">
                    <div class="thumbnail">
                            <img src="img/thb_upload.jpg" alt="">
                            <h3>Get Started</h3>
                            1. Register/Login<br/>
                            2. Create project metadata<br/>
                            3. Upload data<br/>
                            4. Analyse tracks<br/>
                            more...
                        </div></a>

                    </li>
                    <li><a href="${pageContext.request.contextPath}/toolkit/analysis">
                        <div class="thumbnail">
                            <img src="img/thb_analysis.jpg" alt="">
                            <h3>Analysis Toolkit</h3>
                            Kalman filter <br/>
                            Kernel Utilisation Distribution <br/>
                            Alpha Hull / Local Convex Hull<br/>
                            Heat maps<br/>
                             more...
                        </div></a>
                    </li>
                    <li><a href="${pageContext.request.contextPath}/about/layers">
                        <div class="thumbnail">
                            <img src="img/thb_env_layers.jpg" alt="">
                            <h3>Environmental Layers</h3>
                            Bathymetry<br/>
                            Sea surface temperature<br/>
                            NVIS <br/>
                            Land Cover<br/>
                             more...
                        </div> </a>
                    </li>
                </ul>
            </div>
            <div id="blog-div" class="span3">
                <table class="table table-bordered table-hover" id="blog-table">
                    <thead>
                    <tr>
                        <th>Blog and Updates</th>
                    </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </jsp:body>
</tags:page>
