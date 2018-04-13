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
        <style type="text/css">

            #main{
                padding-top:10px;
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

            .news-table th {
                text-align:left;
                font-size: 1.5em;
                background-color:#FBFEEE;
                color:#f5ce7c;
            }
            .heading {
                font-size:1.5em;
                font-weight:normal;
            }

            .blogdate {
                font-size:0.9em;
                color:#aaaaaa;
            }

            #blog-table td a {
                text-decoration: none;
            }

            #blog-table td {
                padding-top:15px;
                padding-bottom:10px;
                border-top:none;
                border-bottom: 1px solid #aaaaaa;
                color: #746E4D;
            }

            #tutorials-table td a {
                text-decoration: none;
            }


        </style>
    </jsp:attribute>

  <jsp:attribute name="tail">
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
                                  $('#blog-table > tbody:last').append('<tr><td><a href="' + url + '" class="heading" target="_blank">' + title + '</a>' +
                                  '<p class="blogdate">' + pubDate.split(' ', 4).join(' ') + '</p>' +
                                  '<p>' + $(this).find('description').text().replace('>Continue reading',' target="_blank">Continue reading') + '</p>' +
                                  '</td></tr>');

                            }
                        });//end each
                    }
                });
            }

            function getYouTubeFeed(div) {
                var channelId = 'UCboSpLAfIMLdORmGl37Qftw';
                $.ajax({
                    type: "GET",
                    url: '${pageContext.request.contextPath}/proxy/youtubesearch',
                    data: {
                        part: 'snippet',
                        channelId: channelId,
                        type: 'video',
                        maxResults: 10,
                        orderby: 'published'
                    },
                    dataType: "json",
                    success: function (data) {
                        $.each(data.items, function(i) {
                            var videoUrl = '"http://www.youtube.com/watch?v=' + this.id.videoId + '"';
                            $('<tr><td><img src="' + this.snippet.thumbnails.default.url
                                    + '" width = "60" height = "45"/></td>'
                                    + '<td><a href=' + videoUrl + ' target="_blank">'
                                    + '' + this.snippet.title + '</a></td></tr>').prependTo('#tutorials-table > tbody');
                        });

                        $('#tutorials-table > tbody:last').append('<tr><td></td>' +
                          '<td><a target="_blank" style="float:right" href="https://www.youtube.com/channel/' + channelId + '">More ...</a></td></tr>');
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                    }
                });
            }

            $(document).ready(function() {
                $('#navHome').addClass('active');
                getBlogFeed($('#blog-list'));
                getYouTubeFeed($('#tutorials-div'));
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

        <span id="by-line">Calculate movement metrics and space use for individually marked animals anywhere in the world.<br/>
        Acquire citations for your hard-won animal tracking data.</span>
        <hr/>
        <div class="row">

            <div id="blog-div" class="span8">
                <table class="table, news-table" id="blog-table">
                    <thead>
                    <tr><th>Blog</th></tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>

            <div id="right-panel" class="span3 offset1">
                <div id="stats-div">
                    <h2>ZoaTrack Stats</h2>
                    <ul>
                    <c:forEach items="${summaryStats}" var="stat">
                        <li>${stat.value} &nbsp;${stat.key}</li>
                    </c:forEach>
                    </ul>
                </div>
                <div id="tutorials-div" style="padding-top:10px">
                    <h2>Links to Video Tutorials</h2>
                    <table class="table"    id="tutorials-table">
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </jsp:body>
</tags:page>
