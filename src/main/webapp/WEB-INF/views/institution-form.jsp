<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>
<tags:page title="Settings">
    <jsp:attribute name="description">
        Update institution records in ZoaTrack.
    </jsp:attribute>
    <jsp:attribute name="breadcrumbs">
        <a href="${pageContext.request.contextPath}/">Home</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/settings">Settings</a>
        &rsaquo; <a href="${pageContext.request.contextPath}/settings/institutions">Institutions</a>
        &rsaquo; <span class="active">${institution.title}</span>
    </jsp:attribute>
	<jsp:attribute name="tail">
		<script type="text/javascript">
			$(document).ready(function() {
				$('#alaInstitutionCheck').click(function(e) {
					e.preventDefault();
					var id =  $(e.target).siblings('.input-xlarge').val();
					if (id != "") {
						window.open('http://collections.ala.org.au/public/show/' + id, '_blank');
					}
				});
			});
		</script>
	</jsp:attribute>
    <jsp:body>
        <h1>${institution.title}</h1>
        <form:form class="form-horizontal form-bordered" commandName="institution"
        	method="PUT" action="${pageContext.request.contextPath}/institutions/${institution.id}">
        	<fieldset>
	        	<div class="legend">Edit institution details</div>
        		<div class="control-group required">
		            <label for="institution-${institution.id}-title" class="control-label required">Title</label>
		            <div class="controls">
			            <form:input class="input-xlarge" id="institution-${institution.id}-title"
			            	path="title" placeholder="e.g. The University of Queensland" />
	                </div>
                </div>
                <div class="control-group">
                	<label for="institution-${institution.id}-domainName" class="control-label">Domain</label>
		            <div class="controls">
			            <form:input type="text" class="input-xlarge"
			                id="institution-${institution.id}-domainName"
			                path="domainName" placeholder="e.g. uq.edu.au" />
	                </div>
                </div>
                <div class="control-group">
				<label for="institution-${institution.id}-domainName" class="control-label">Country</label>
				<div class="controls">
					<select name="country" id="institution-${institution.id}-country" style="width: 284px;">
						<option value="">Select country</option>
						<c:forEach var="country" items="${countries}">
							<option value="${country.id}"<c:if test="${country == institution.country}"> selected="selected"</c:if>>${country.title}</option>
						</c:forEach>
					</select>
				</div>
				</div>
				<div class="control-group">
					<label for="institution-${institution.id}-alaInstitutionId" class="control-label">ALA Institution Id</label>
					<div class="controls">
						<form:input type="text" class="input-xlarge"
									id="institution-${institution.id}-alaInstitutionId"
									path="alaInstitutionId" placeholder="e.g. in9999 (see collections.ala.org.au)" />
						<button id="alaInstitutionCheck">Check</button>
					</div>

				</div>
            </fieldset>
            <div class="form-actions">
            	<button type="submit" class="btn btn-primary">Save</button>
        	</div>
        </form:form>
        <form class="form-horizontal form-bordered"
        	method="POST" action="${pageContext.request.contextPath}/institutions/${institution.id}/replace">
        	<div class="legend">Replace with other institution</div>
        	<fieldset>
        		<div class="control-group">
		            <label for="institution-${institution.id}-replace-other" class="control-label">Replace with</label>
		            <div class="controls">
			            <select name="other" id="institution-${institution.id}-replace-other" style="width: 284px;">
			                <option value="">Select institution</option>
			                <c:forEach var="otherInstitution" items="${institutions}">
			                <option value="${otherInstitution.id}">${otherInstitution.title} (ID ${otherInstitution.id})</option>
			                </c:forEach>
			            </select>
		            </div>
	            </div>
            </fieldset>
            <div class="form-actions">
            	<button type="submit" class="btn btn-primary">Replace</button>
        	</div>
        </form>
        <form class="form-vertical form-bordered" commandName="institution"
        	method="DELETE" action="${pageContext.request.contextPath}/institutions/${institution.id}">
        	<input type="hidden" name="_method" value="DELETE" />
        	<fieldset>
	        	<div class="legend">Delete institution</div>
            </fieldset>
        	<div class="form-actions">
	            <button class="btn btn-danger" onclick="
	                void(OzTrack.deleteEntity(
	                    '${pageContext.request.contextPath}/institutions/${institution.id}',
	                    '${pageContext.request.contextPath}/settings/institutions',
	                    'Are you sure you want to delete this institution?'
	                )); return false;">Delete</button>
            </div>
        </form>
		<div class="form-horizontal form-bordered">
			<div class="legend">Affiliations</div>
			<c:if test="${institution.people.size() == 0}">- None.</c:if>
			<ul>
				<c:forEach items="${institution.people}" var="person">
					<li>${person.fullName}<c:if test="${not empty person.email}"> (${person.email})</c:if></li>
				</c:forEach>
			</ul>
			<br/>
		</div>
    </jsp:body>
</tags:page>