ALTER Table project ADD COLUMN firstdetectiondate timestamp without time zone;
ALTER Table project ADD COLUMN lastdetectiondate timestamp without time zone;
comment on column project.firstdetectiondate is 'start date of detections';
comment on column project.lastdetectiondate is 'end date of detections';

UPDATE project SET firstdetectiondate = a.startdate, lastdetectiondate=a.enddate from (SELECT min(detectionTime) as startdate, max(detectionTime) as enddate, project_id from positionfix group by project_id) a WHERE id = a.project_id;

