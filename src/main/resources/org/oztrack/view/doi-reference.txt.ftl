${doi.citation}
${fileNamePrefix}-reference.txt

***** Project Detail
Title: ${doi.project.title}
Description: ${doi.project.description}
Species Scientific Name: ${doi.project.speciesScientificName}
Species Common Name: ${doi.project.speciesCommonName}
Licencing and Ethics Clearance: ${doi.project.licencingAndEthics}
Spatial Coverage Description: ${doi.project.spatialCoverageDescr}
SRS Identifier: ${doi.project.srsIdentifier}
Crosses 180: ${doi.project.crosses180?string}
ZoaTrack Data Access Type: ${doi.project.access}
Data Rights Statement: ${doi.project.rightsStatement}
Data Licence Identifier: ${doi.project.dataLicence.identifier}
Data Licence Title: ${doi.project.dataLicence.title}
Data Licence URL: ${doi.project.dataLicence.infoUrl}
Project Contributors: <#list doi.project.projectContributions as projectContribution>
    ${projectContribution.contributor.title} ${projectContribution.contributor.firstName} ${projectContribution.contributor.lastName}
</#list>
<#list doi.project.animals as animal>

Animal Id: ${animal.id}
Project Animal Id: ${animal.projectAnimalId}
Animal Name: ${animal.animalName}
ZoaTrack Colour: ${animal.colour}

Sex: ${animal.sex}
Weight: ${animal.weight}
Dimensions: ${animal.dimensions}
Life Phase: ${animal.lifePhase}
Experimental Context: ${animal.experimentalContext}
Tag Deploy Start Date: ${animal.tagDeployStartDate}
Tag Deploy End Date: ${animal.tagDeployEndDate}
Tag Manufacturer / Model: ${animal.tagManufacturerModel}
Tag Identifier: ${animal.tagIdentifier}
Tag Dimensions: ${animal.tagDimensions}
Tag Attachment Technique: ${animal.tagAttachmentTechnique}
Tag Deployment Comments: ${animal.tagDeploymentComments}
Tag Duty Cycle: ${animal.tagDutyCycleComments}
Tag Data Retrieval Method: ${animal.dataRetrievalMethod}

</#list>