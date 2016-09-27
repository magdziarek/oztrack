alter table institution add column ala_institution_id varchar(20);
alter table project add column ala_data_resource_id varchar(20);
alter table project add column institution_id bigint;

-- rollback
--alter table institution drop column ala_institution_id;
--alter table project drop column ala_data_resource_id;
--alter table project drop column primary_institution_id;
--delete from schema_version where version = '98';
--update schema_version set current_version=true where version='97';
