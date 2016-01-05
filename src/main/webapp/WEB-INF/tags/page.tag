<!DOCTYPE html>
<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ tag import="org.oztrack.app.OzTrackApplication" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ attribute name="title" required="false" %>
<%@ attribute name="description" required="false" %>
<%@ attribute name="head" required="false" fragment="true" %>
<%@ attribute name="tail" required="false" fragment="true" %>
<%@ attribute name="breadcrumbs" required="false" fragment="true" %>
<%@ attribute name="navExtra" required="false" fragment="true" %>
<%@ attribute name="sidebar" required="false" fragment="true" %>
<%@ attribute name="fluid" required="false" type="java.lang.Boolean" %>
<c:set var="baseUrl"><%= OzTrackApplication.getApplicationContext().getBaseUrl() %></c:set>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <c:if test="${not empty description}">
        <meta name="description" content="${description}" />
    </c:if>
    <title>ZoaTrack${(not empty title) ? ': ' : ' - '}${(not empty title) ? title : 'Free Animal Tracking Software'}</title>
    <link rel="shortcut icon" href="${pageContext.request.contextPath}/favicon.ico" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/optimised/core.css"/>
    <style type="text/css">


        .navbar {
            opacity:0.95;
        }

        .navbar-inner {
        .border-radius(0);
            min-height: 0;
            line-height: 0;
            text-align: center;
        }

        .navbar .nav {
            float: none;
            display: inline-block;
            *display: inline; /* ie7 fix */
            *zoom: 1; /* hasLayout ie7 trigger */
            margin: 0 auto;
            vertical-align:middle;
        }

        .navbar-brand {
            padding-right:120px;
        }

        .navbar-brand img {
           padding: 3px 20px;
        }

        #login {
            float: right;
            padding-top:8px;
        }

        .icon-user {
            margin-top:3px;
        }

        .navbar-inverse .nav .active > a {
            background-color:transparent;
            color:#D78B00;
        }

        .dropdown-menu > .active > a,
        .dropdown-menu > .active > a:hover,
        .dropdown-menu > .active > a:focus  {
            color:#D78B00;
            background-color:#000000;
            background-image:none;
        }

        .dropdown-menu .divider {
            height: auto;
        }

    </style>
    <jsp:invoke fragment="head"/>
</head>
<body>

<div class="container${fluid ? '-fluid' : ''}">
    <div class="navbar navbar-inverse navbar-fixed-top">
        <div class="navbar-inner">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home"><img src="${pageContext.request.contextPath}/img/zoatrack_logo.png"/></a>

            <ul class="nav">
                <c:if test="${!empty navExtra}">
                    <jsp:invoke fragment="navExtra"/>
                </c:if>
                <li id="navBrowse"><a href="${pageContext.request.contextPath}/projects">Browse the repository</a></li>
                <li id="navPub"><a href="${pageContext.request.contextPath}/publication">Publications</a></li>
                <li id="navToolkit" class="dropdown">
                    <a href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">Toolkit <b class="caret"></b></a>
                    <ul class="dropdown-menu" role="menu" aria-labelledby="drop1">
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/projects/new">Create a Project</a></li>
                        <li role="presentation" class="divider"></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/toolkit/getstarted">Getting Started</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/toolkit/analysis">Home Range Estimation</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/toolkit/datamgt">Data Management</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/about/layers">Environment Layers</a></li>
                        <li role="presentation" class="divider"></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/about">About ZoaTrack</a></li>
                    </ul>
                </li>
                <li id="navContact"><a href="${pageContext.request.contextPath}/contact">Contact Us</a></li>
           </ul>
            <ul id="login" class="nav"  >

                <c:choose>
                    <c:when test="${currentUser != null}">
                        <li id="navLogin" class="dropdown">
                            <a href="#" role="button" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-user icon-white"></i>&nbsp;&nbsp;<c:out value="${currentUser.fullName}"/> <b class="caret"></b></a>
                            <ul class="dropdown-menu" role="menu" aria-labelledby="drop2">
                                <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/projects">Projects</a></li>
                                <li role="presentation"><a role="menuitem" tabindex="-1" href="${pageContext.request.contextPath}/projects/new">Create a Project</a></li>
                                <li role="presentation" class="divider"></li>
                                <li><a href="${pageContext.request.contextPath}/users/${currentUser.id}/edit">Edit profile</a></li>
                                <c:if test="${currentUser.admin}">
                                    <li><a href="${pageContext.request.contextPath}/settings">Settings</a></li>
                                </c:if>
                                <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li><a href="${fn:replace(baseUrl, 'http://', 'https://')}/login">Login</a></li>
                        <li><a href="${fn:replace(baseUrl, 'http://', 'https://')}/users/new">Register</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</div>


<div id="main">
    <div class="container${fluid ? '-fluid' : ''}">
        <c:if test="${!empty breadcrumbs}">
            <div id="crumbs">
                <jsp:invoke fragment="breadcrumbs"/>
            </div>
        </c:if>
        <jsp:invoke var="sidebarContent" fragment="sidebar"/>
        <div class="row${fluid ? '-fluid' : ''}">
            <c:if test="${!empty sidebarContent}">
                <div id="left-menu" class="span3">
                        ${sidebarContent}
                </div>
            </c:if>
            <div id="content" class="${empty sidebarContent ? 'span12' : 'span9'}">
                <jsp:doBody/>
                <div style="clear:both;"></div>
            </div> <!-- content -->
        </div>
    </div>
</div>
<c:if test="${not fluid}">
    <div id="footer">
        <div id="logos">

            <a target="_blank" href="http://ala.org.au/"><img src="${pageContext.request.contextPath}/img/logo_ala.png" width="77px" height="60px"/></a>
            <a target="_blank" href="http://une.edu.au/"><img src="${pageContext.request.contextPath}/img/logo_UNE.gif" width="93px" height="78px"/></a>
            <a target="_blank" href="http://tern.edu.au/"><img src="${pageContext.request.contextPath}/img/logo_tern.gif" width="111px" height="97px"/></a>
            <a target="_blank" href="http://sims.edu.au/"><img src="${pageContext.request.contextPath}/img/logo_SIMS.png" width="131px" height="59px"/></a>
            <a target="_blank" href="http://csiro.au/"><img src="${pageContext.request.contextPath}/img/logo_CSIRO.png" width="100px" height="100px"/></a>
            <a target="_blank" href="http://mq.edu.au//"><img src="${pageContext.request.contextPath}/img/logo_MQlogo1.png" width="125px" height="38px"/></a>
            <br/>
            <a target="_blank" href="http://mq.edu.au//"><img src="${pageContext.request.contextPath}/img/logo_uni_auckland.png" width="76px" height="89px"/></a>
            <a target="_blank" href="http://nectar.org.au/"><img src="${pageContext.request.contextPath}/img/nectar-logo.png" width="140px" height="32px"/></a>
            <a target="_blank" href="http://itee.uq.edu.au/~eresearch/"><img src="${pageContext.request.contextPath}/img/uq_logo.png" width="140px" height="40px"/></a>
        </div>
        <div id="site-licence">
            All site content, except where otherwise noted, is licensed under a
            <a rel="license" target="_blank" href="http://creativecommons.org/licenses/by/3.0/au/">Creative Commons Attribution license</a>.
        </div>
    </div>
</c:if>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/optimised/core.js"></script>
<jsp:invoke fragment="tail"/>
<c:out value="${customJs}" escapeXml="false"/>
</body>
</html>
