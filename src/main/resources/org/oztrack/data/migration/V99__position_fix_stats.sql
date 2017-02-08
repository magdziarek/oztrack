-- add a new field to trajectorylayer: row_number (better for joins than timestamp)
drop index trajectorylayer_index_1;
drop table trajectorylayer;

create table trajectorylayer as
select positionfix1.id as id
   ,positionfix1.project_id as project_id
   ,positionfix1.animal_id as animal_id
   ,positionfix1.detectiontime as startdetectiontime
   ,positionfix2.detectiontime as enddetectiontime
   ,positionfix1.colour as colour
   ,positionfix1.row_number as row_number
   ,case when project.crosses180
    then ST_Shift_Longitude(ST_MakeLine(positionfix1.locationgeometry, positionfix2.locationgeometry))
    else ST_MakeLine(positionfix1.locationgeometry, positionfix2.locationgeometry)
    end as trajectorygeometry
from positionfixnumbered positionfix1
inner join positionfixnumbered positionfix2
   on positionfix1.project_id = positionfix2.project_id
   and positionfix1.animal_id = positionfix2.animal_id
   and positionfix1.row_number + 1 = positionfix2.row_number
inner join project
   on positionfix1.project_id = project.id;

create index trajectorylayer_index_1 on trajectorylayer (project_id, animal_id);

ALTER TABLE public.trajectorylayer OWNER TO oztrack;
ANALYZE trajectorylayer;

create table positionfixstats
(
   id bigint PRIMARY KEY NOT NULL
 , project_id bigint NOT NULL
 , animal_id bigint NOT NULL
 , locationgeometry geometry NOT NULL
 , detectiontime timestamp NOT NULL
 , detection_index bigint NOT NULL
 , displacement numeric
 , cumulative_distance numeric
);

ALTER TABLE public.positionfixstats OWNER TO oztrack;

insert into positionfixstats (
  id
 , project_id
 , animal_id
 , locationgeometry
 , detectiontime
 , detection_index
 , displacement
 , cumulative_distance
)
select all_fixes.id
 , all_fixes.project_id
 , all_fixes.animal_id
 , all_fixes.locationgeometry
 , all_fixes.detectiontime
 , all_fixes.row_number-1  as detection_index -- start at 0
 , case when (select crosses180 from project where id = all_fixes.project_id)
   then ST_Distance_Spheroid(ST_Shift_Longitude(first_fix.locationgeometry),ST_Shift_Longitude(all_fixes.locationgeometry),'SPHEROID["WGS 84", 6378137, 298.257223563]')
   else ST_Distance_Spheroid(first_fix.locationgeometry,all_fixes.locationgeometry,'SPHEROID["WGS 84", 6378137, 298.257223563]')
   end as displacement
 , case when trajectory.enddetectiontime is null
   then 0
   else sum(ST_Length_Spheroid(trajectorygeometry, 'SPHEROID["WGS 84", 6378137, 298.257223563]')) over (partition by trajectory.project_id, trajectory.animal_id order by trajectory.enddetectiontime)
   end as cumulative_distance
from positionfixnumbered all_fixes
 inner join positionfixnumbered first_fix
  on first_fix.row_number = 1
     and all_fixes.project_id = first_fix.project_id
     and all_fixes.animal_id = first_fix.animal_id
 left outer join trajectorylayer trajectory
  on all_fixes.project_id=trajectory.project_id
     and all_fixes.animal_id=trajectory.animal_id
	and all_fixes.row_number=trajectory.row_number+1
;

CREATE INDEX positionfixstats_index_1 ON positionfixstats (project_id, animal_id, detection_index);
ANALYZE positionfixstats;
