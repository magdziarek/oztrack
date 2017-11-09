
-- fk wrong way around
alter table datafeed_detection drop column positionfix_id;
alter table positionfix add column datafeed_detection_id bigint;
alter table positionfixlayer add column argosclass integer;

update positionfixlayer p1
set argosclass = (select p0.argosclass from positionfix p0 where p0.id=p1.id and p0.argosclass is not null)
where exists (select 1 from positionfix p0 where p0.id=p1.id and p0.argosclass is not null);

update datafeed_device set last_detection_date = null ;
alter table datafeed_device drop column last_detection_date;

-- not able to save timestamp in field - remove capability in database to save confusion
alter table datafeed_detection alter column detection_date type timestamp;
alter table datafeed_detection alter column location_date type timestamp;
alter table datafeed_detection add column timezone_id varchar(50);
comment on column datafeed_detection.timezone_id is 'Timezone id that applies to the detection date and location date';


