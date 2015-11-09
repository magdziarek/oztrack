alter table project add column licencingandethics text;

alter table animal add column sex                   text;
alter table animal add column weight                text;
alter table animal add column dimensions            text;
alter table animal add column lifephase             text;
alter table animal add column tagidentifier         text;
alter table animal add column tagmanufacturermodel  text;
alter table animal add column capturedate           date;
alter table animal add column releasedate           date;
alter table animal add column capturelatitude       varchar(255);
alter table animal add column capturelongitude      varchar(255);
alter table animal add column capturegeometry       geometry;
alter table animal add column releaselatitude       varchar(255);
alter table animal add column releaselongitude      varchar(255);
alter table animal add column releasegeometry       geometry;
alter table animal add column tagdeploystartdate    date;
alter table animal add column tagdeployenddate      date;
alter table animal add column stateondetachment     varchar(10);
alter table animal add column experimentalcontext   text;
alter table animal add column tagattachmenttechnique text;
alter table animal add column tagdimensions         text;
alter table animal add column tagdutycyclecomments  text;
alter table animal add column dataretrievalmethod   text;
alter table animal add column datamanipulation      text;
alter table animal add column tagdeploymentcomments text;



