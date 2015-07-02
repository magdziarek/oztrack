<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ tag import="org.oztrack.app.OzTrackApplication" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<%@ attribute name="project" type="org.oztrack.data.model.Project" required="true" %>

<li id="navProject" class="dropdown">
    <a href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">Project <b class="caret"></b></a>
    <ul class="dropdown-menu" role="menu" aria-labelledby="drop3">
        <tags:project-menu project="${project}" itemsOnly="${true}"/>
        <c:set var="projectActions"><tags:project-actions project="${project}" itemsOnly="${true}"/></c:set>
        <c:if test="${not empty projectActions}"><hr />${projectActions}</c:if>
    </ul>
</li>