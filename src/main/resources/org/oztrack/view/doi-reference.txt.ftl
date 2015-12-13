reference.txt

***** Project Detail
Title: ${doi.project.title}
Description: ${doi.project.description}
Species Scientific Name: ${doi.project.speciesScientificName}
Species Common Name: ${doi.project.speciesCommonName}
<#if doi.project.licencingAndEthics?has_content>Licencing and Ethics Clearance: ${doi.project.licencingAndEthics}</#if>
Spatial Coverage Description: ${doi.project.spatialCoverageDescr}
SRS Identifier: ${doi.project.srsIdentifier}
Crosses 180: ${doi.project.crosses180?string}
ZoaTrack Data Access Type: ${doi.project.access}
<#if doi.project.rightsStatement?has_content>Data Rights Statement: ${doi.project.rightsStatement}</#if>
Data Licence Identifier: ${doi.project.dataLicence.identifier}
Data Licence Title: ${doi.project.dataLicence.title}
Data Licence URL: ${doi.project.dataLicence.infoUrl}
<#compress>Project Contributors: <#list doi.project.projectContributions as projectContribution>
    ${projectContribution.contributor.title} ${projectContribution.contributor.firstName} ${projectContribution.contributor.lastName}
</#list></#compress>

***** Animal Detail

<#list doi.project.animals as animal>
Animal Id: ${animal.id}
Project Animal Id: ${animal.projectAnimalId}
Animal Name: ${animal.animalName}
ZoaTrack Colour: ${animal.colour}
<#compress>
<#if animal.sex?has_content>Sex: ${animal.sex}</#if>
<#if animal.weight?has_content>Weight: ${animal.weight}</#if>
<#if animal.dimensions?has_content>Dimensions: ${animal.dimensions}</#if>
<#if animal.lifePhase?has_content>Life Phase: ${animal.lifePhase}</#if>
<#if animal.experimentalContext?has_content>Experimental Context: ${animal.experimentalContext}</#if>
<#if animal.tagIdentifier?has_content>Tag Identifier: ${animal.tagIdentifier}</#if>
<#if animal.tagDeployStartDate?has_content>Tag Deploy Start Date: ${animal.tagDeployStartDate}</#if>
<#if animal.tagDeployEndDate?has_content>Tag Deploy End Date: ${animal.tagDeployEndDate}</#if>
<#if animal.tagManufacturerModel?has_content>Tag Manufacturer / Model: ${animal.tagManufacturerModel}</#if>
<#if animal.tagDimensions?has_content>Tag Dimensions: ${animal.tagDimensions}</#if>
<#if animal.tagAttachmentTechnique?has_content>Tag Attachment Technique: ${animal.tagAttachmentTechnique}</#if>
<#if animal.tagDeploymentComments?has_content>Tag Deployment Comments: ${animal.tagDeploymentComments}</#if>
<#if animal.tagDutyCycleComments?has_content>Tag Duty Cycle: ${animal.tagDutyCycleComments}</#if>
<#if animal.dataRetrievalMethod?has_content>Tag Data Retrieval Method: ${animal.dataRetrievalMethod}</#if>
</#compress>

</#list>