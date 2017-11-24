
create table datafeed_raw_spot (
  id 						          bigint primary key not null
 ,datafeed_detection_id 	bigint not null references datafeed_detection (id) on delete cascade
 ,messenger_id				    varchar(20)
 ,messenger_name				  varchar(20)
 ,message_date_time 		  timestamp without time zone
 ,message_json 		        text
);

create sequence datafeed_raw_spot_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

ALTER sequence public.datafeed_raw_spot_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_raw_spot OWNER TO oztrack;

comment on table datafeed_raw_spot is 'Raw json data for a message from the Spot data feed';
comment on column datafeed_raw_spot.messenger_id is 'Identifier for the sensor';
comment on column datafeed_raw_spot.messenger_name is 'Identifier for the sensor';
