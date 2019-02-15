ALTER Table project ADD COLUMN bbox geometry(Geometry, 4326);
comment on column project.bbox is 'Bounding box for project detections';

UPDATE project SET bbox = a.bbox from (SELECT st_setsrid(st_extent(locationgeometry),4326) as bbox, project_id from positionfix group by project_id) a WHERE id = a.project_id;