<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<tags:page title="People involved in ZoaTrack">
    <jsp:attribute name="description">
        ZoaTrack is a free-to-use web-based platform for analysing and visualising
        individual-based animal location data.
    </jsp:attribute>
    <jsp:attribute name="head">
        <style type="text/css">
            #about-buttons .btn {
                margin: 9px 0;
                height: 60px;
                line-height: 40px;
            }
        </style>
    </jsp:attribute>
    <jsp:attribute name="tail">
        <script type="text/javascript">
            $(document).ready(function() {
                $('#navAbout').addClass('active');
            });
        </script>
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/about">About</a>
        &rsaquo; <span class="active">People involved in ZoaTrack</span>
    </jsp:attribute>
    <jsp:body>
        <h1>People involved in ZoaTrack</h1>
        ${settings.peopleText}
        </jsp:body>
</tags:page>
