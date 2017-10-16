-- tables to manage datafeeds
/*
drop sequence datafeed_detection_id_seq;
drop sequence datafeed_device_id_seq;
drop sequence datafeed_raw_argos_id_seq;
drop index datafeed_detection_idx;
drop table datafeed_raw_argos;
drop table datafeed_detection;
drop table datafeed_device;

drop sequence datafeed_id_seq;
drop table datafeed;
*/

ALTER TABLE animal ALTER COLUMN stateondetachment TYPE text;

create table datafeed(
   id 							          bigint PRIMARY KEY NOT NULL
 , project_id 					      bigint NOT NULL references project (id) on delete cascade
 , source_system 				      varchar(50) NOT NULL
 , source_system_credentials 	varchar(200)
 , poll_frequency_hours       bigint not null
 , active_flag 					      boolean not null
 , active_date 					      timestamp without time zone
 , deactive_date 				      timestamp without time zone
 , last_poll_date 			      timestamp without time zone
 , createdate 					      timestamp without time zone
 , updatedate 					      timestamp without time zone
 , createuser_id 				      bigint references appuser (id) on delete cascade
 , updateuser_id 				      bigint references appuser (id) on delete cascade
);

comment on table datafeed is 'A connection to a remote source system to collect animal movement data';
comment on column datafeed.project_id is 'Foreign key to the project table';
comment on column datafeed.source_system is 'The source system of this datafeed as defined in DataFeedSourceSystem enum';
comment on column datafeed.source_system_credentials is 'Expected json structure for the source system credentials';
comment on column datafeed.poll_frequency_hours is 'Number of hours between poll cycles';
comment on column datafeed.active_flag is 'Indicates whether feed is to be polled';
comment on column datafeed.active_date is 'Date from which the feed is to start polling';
comment on column datafeed.deactive_date is 'Date from which the feed is to stop polling';
comment on column datafeed.last_poll_date is 'Last date this feed was polled';

create sequence datafeed_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

ALTER sequence public.datafeed_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed OWNER TO oztrack;

create table datafeed_device(
   id 					          bigint primary key not null
 , datafeed_id 			      bigint not null references datafeed (id) on delete cascade
 , project_id 			      bigint not null references project (id) on delete cascade
 , animal_id 			        bigint not null references animal (id) on delete cascade
 , device_identifier      varchar(200)
-- , last_location_date     timestamp without time zone
 , last_detection_date    timestamp without time zone
-- , timezone               varchar(20)
-- , last_poll_date 	      timestamp without time zone
 , create_date 			      timestamp without time zone
) ;

--alter table datafeed_device add last_detection_date timestamp without time zone;
CREATE UNIQUE INDEX datafeed_device_uidx ON datafeed_device (project_id, datafeed_id, device_identifier);

comment on table datafeed_device is 'A device for which data is accessed via a datafeed';
comment on column datafeed_device.datafeed_id is 'Foreign key to the datafeed table';
comment on column datafeed_device.project_id is 'Foreign key to the project table';
comment on column datafeed_device.animal_id is 'Foreign key to the animal table';
comment on column datafeed_device.device_identifier is 'The identifier value used by the source system for this device';
-- comment on column datafeed_device.last_location_date is 'Last detection date that was collected by this device (timezone specified in timezone column)';
 comment on column datafeed_device.last_detection_date is 'Last detection date that was collected by this device (timezone specified in timezone column)';
-- comment on column datafeed_device.timezone is 'Timezone provided for this device (from the first location)'
-- comment on column datafeed_device.last_poll_date is 'Last date this device was polled (host system timezone)';
comment on column datafeed_device.create_date is 'Date this device was created (host system timezone)';

create sequence datafeed_device_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

ALTER sequence public.datafeed_device_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_device OWNER TO oztrack;

create table datafeed_detection (
   id 					        bigint primary key not null
 , datafeed_device_id 	bigint not null references datafeed_device (id) on delete cascade
 , project_id 			    bigint not null references project (id) on delete cascade
 , animal_id 			      bigint not null references animal (id) on delete cascade
 , detection_date 		  timestamp with time zone not null
 , location_date        timestamp with time zone null
 , positionfix_id 		  bigint references positionfix (id)
 , poll_date 			      timestamp without time zone not null
);

CREATE UNIQUE INDEX datafeed_detection_idx ON datafeed_detection (project_id, datafeed_device_id, detection_date);

comment on table datafeed_detection is 'An event during which data is accessed for a device via a datafeed. This could be a detection without a location.';
comment on column datafeed_detection.datafeed_device_id is 'Foreign key to the datafeed_device table';
comment on column datafeed_detection.project_id is 'Foreign key to the project table';
comment on column datafeed_detection.animal_id is 'Foreign key to the animal table';
comment on column datafeed_detection.detection_date is 'Date of the detection (may be a detection record with no established location';
comment on column datafeed_detection.location_date is 'Date of the location';
comment on column datafeed_detection.positionfix_id is 'Foreign key to the ZoaTrack position fix record created from this detection';
comment on column datafeed_detection.poll_date is 'Date the datafeed was polled for this detection.';

create sequence datafeed_detection_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

ALTER sequence public.datafeed_detection_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_detection OWNER TO oztrack;

create table datafeed_raw_argos (
  id 						          bigint primary key not null
 ,datafeed_detection_id 	bigint not null references datafeed_detection (id) on delete cascade
 ,program_number				  bigint
 ,platform_id 				    bigint
 ,best_message_date 		  timestamp without time zone
 ,satellite_pass_xml 		  text
);

create sequence datafeed_raw_argos_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

ALTER sequence public.datafeed_raw_argos_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_raw_argos OWNER TO oztrack;

comment on table datafeed_raw_argos is 'Raw xml data for a detection (called a satellite pass) from the Argos data feed';
comment on column datafeed_raw_argos.program_number is 'Program identifier';
comment on column datafeed_raw_argos.platform_id is 'Platform identifier';
