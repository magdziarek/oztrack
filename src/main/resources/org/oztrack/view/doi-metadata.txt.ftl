${doi.citation}

ZOATRACK.ORG DATASET
${fileNamePrefix}-zoatrack.zip

The data files in this package have been published by ZoaTrack within the Atlas of Living Australia on 31/08/2015 13:34 (AEST).
The data is available in the attached files and at the time of publication is available on ZoaTrack (http://zoatrack.org) in the project entitled
'${doi.project.title}' at the url https://zoatrack.org/projects/3.

The files included in this package are:
${fileNamePrefix}-metadata.txt
${fileNamePrefix}-reference.txt
${fileNamePrefix}-zoatrack-data.csv

Terms of Use
The data is licenced under ${doi.project.dataLicence.title} (${doi.project.dataLicence.identifier})
${doi.project.dataLicence.description}
More information: ${doi.project.dataLicence.infoUrl}

ZoaTrack Data Definitions

***** A Project is a logical collection of animal tracking data and metadata in ZoaTrack. Attributes include:
Project ID: A system generated unique identifier for this project in ZoaTrack
Title: A short description of the project
Description: A long description of the project
Created By: The ZoaTrack user who created the project
Updated By: The last ZoaTrack user who updated the project
Created Date: The date the project was created in ZoaTrack
Updated Date: The last date the project metadata was updated in ZoaTrack
Spatial Coverage Description: A plain text description of the location of the project
Images: A set of images associated with the project
Data Manipulation: A description of any data manipulation that has been applied to the data included in this project
Location Accuracy Comments: A commentary on the location accuracy and error handling methodologies in this project
Licencing and Ethics Clearance: A description, including identifiers, of the licence agreements and ethics permits associated with this project
Species Scientific Name: The scientific name of the species in this project either verified by the Atlas of Living Australia or manually provided by the user
Species Common Name: The common name of the species in this project either verified by the Atlas of Living Australia or manually provided by the user
SRS Identifier: The Spatial Reference System to be used in this project (refers to spatialreference.org)
Crosses 180: An indicator of whether trajectories in the project cross the antimeridian (180 east or west longitude)
Reference: The title of a publication associated with the project
URL: The URL of a publication associated with the project
Users: A list of ZoaTrack users (see type: User) involved with this project, and their roles (Manage, Write, Read)
Contributors: An ordered list of people (see type: Person) who have contributed to this project
Rights Statement: A user provided statement about intellectual property rights held on this project
Access: The user's selected preference on whether the data is available (Open, Closed, Embargo)
Embargo Date: The date an embargo on data will end if the project is under Embargo access
Data Licence Title: The title of the Creative Commons licence selected by the owner to be placed on the data in this project
Data Licence Description: A description of the Creative Commons licence selected by the owner to be placed on the data in this project
Data Licence URL: The URL of the Creative Commons licence selected by the owner to be placed on the data in this project
Data Licence Identifier: A short code representing the Creative Commons licence selected by the owner to be placed on the data in this project
Include in OAI-PMH: An indicator of whether this project is to be included in the metadata feed to Research Data Australia
Date updated in OAI-PMH: The last date the project metadata was included in the metadata feed to Research Data Australia
RDA URL: The URL for this project metadata in the Research Data Australia Registry

***** The Animal entity represents an animal that is the subject of a telemetry program. Attributes include:
Animal ID: Id provided by user, otherwise system provided
Animal Name: Name of the animal
Animal Description: Description of the animal
ZoaTrack Colour: Colour used for this animal's tracks in ZoaTrack
Species Scientific Name: The scientific name of this animal either verified by the Atlas of Living Australia or manually provided by the user
Species Common Name: The common name of this animal either verified by the Atlas of Living Australia or manually provided by the user
Sex: The sex of the animal eg. male, female, unknown
Weight: The weight of the animal if known (request user to provideunits)
Dimensions: The height or length of the animal if known (request user to provide units)
Life Phase: A description or quantification of the animal's life stage (eg. juvenile, adult, n years)
Experimental Context: A description of the tagging program eg translocation, manipulation, reintroduction
Tag Deploy Start Date: The date the tag was deployed
Tag Deploy End Date: The date the tag was no longer deployed
Tag Manufacturer / Model: The manufacturer and model of the tag
Tag Identifier: The unique identifier provided with the tag (eg.serial number)
Tag Technology: The technology used to collect/retrieve sensor data (Options? Movebank use acceleration, accessory, argos, bird ring, gps, radio
Tag Dimensions: Any information describing the dimensions of the tag (eg. height, length - add units)
Tag Attachment Technique: A description of the method and location used to attach the tag to the animal
Tag Deployment Comments: Any extra information that is useful in describing the tagging program


***** The Detection entity is a recording that an animal was located at a given time in a given location.. Attributes include:
Detection Time: The date and time the detection was recorded
Latitude: The latitude of the detection
Longitude: The longitude of the detection
Animal ID: The system generated unique identifier for this animal
Deleted Flag: A flag indicating whether this detection is relevant to this study
Argos Class: The Argos class of the detection (see argos.fr)
Degree of Precision: The Argos degree of precision provided with this detection
Local Time Conversion Hours: The number of hours required to be added to UTC to convert to local time for the timestamp