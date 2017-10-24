
-- fk wrong way around
alter table datafeed_detection drop column positionfix_id;
alter table positionfix add column datafeed_detection_id bigint;
alter table positionfixlayer add column argosclass integer;

update positionfixlayer p1
set argosclass = (select p0.argosclass from positionfix p0 where p0.id=p1.id and p0.argosclass is not null)
where exists (select 1 from positionfix p0 where p0.id=p1.id and p0.argosclass is not null);