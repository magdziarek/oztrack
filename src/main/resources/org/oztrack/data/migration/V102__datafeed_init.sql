-- tables to manage datafeeds
-- drop sequence datafeed_animal_id_seq;
-- drop sequence datafeed_activityid_seq;
-- drop sequence datafeedid_seq;
-- drop table datafeed_animal;
-- drop table datafeed_xml;
-- drop table datafeed_activity;
-- drop table datafeed;


create table datafeed(
   id bigint PRIMARY KEY NOT NULL
 , project_id bigint NOT NULL references project (id) on delete cascade
 , source_system varchar(50) NOT NULL
 , source_system_identifier varchar(200)
 , source_system_user varchar(100)
 , source_system_user_uuid varchar(50)
 , active_flag boolean not null
 , active_date timestamp without time zone
 , deactive_date timestamp without time zone
 , createdate timestamp without time zone
 , updatedate timestamp without time zone
 , createuser_id bigint references appuser (id) on delete cascade
 , updateuser_id bigint references appuser (id) on delete cascade
);

create sequence datafeedid_seq
   START WITH 1
   INCREMENT BY 1
   NO MINVALUE
   NO MAXVALUE
   CACHE 1;

ALTER sequence public.datafeedid_seq OWNER TO oztrack;
ALTER TABLE public.datafeed OWNER TO oztrack;

create table datafeed_activity(
   id bigint primary key not null
 , datafeed_id bigint not null references datafeed (id) on delete cascade
 , activity_date timestamp without time zone not null
 , activity_descr varchar(200)
 , response_code varchar(50)
 , createdate timestamp without time zone
 , updatedate timestamp without time zone
 , createuser_id bigint references appuser (id) on delete cascade
 , updateuser_id bigint references appuser (id) on delete cascade
) ;

create sequence datafeed_activityid_seq
   START WITH 1
   INCREMENT BY 1
   NO MINVALUE
   NO MAXVALUE
   CACHE 1;

ALTER sequence public.datafeed_activityid_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_activity OWNER TO oztrack;

create table datafeed_xml(
    datafeed_activity_id bigint primary key not null
   ,xml text
);

ALTER TABLE public.datafeed_xml OWNER TO oztrack;

create table datafeed_animal(
   id bigint primary key not null
 , project_id bigint references project (id) on delete cascade
 , datafeed_id bigint references datafeed (id) on delete cascade
 , animal_id bigint references animal (id) on delete cascade
 , createdate timestamp without time zone
 , updatedate timestamp without time zone
 , createuser_id bigint references appuser (id) on delete cascade
 , updateuser_id bigint references appuser (id) on delete cascade
);

create sequence datafeed_animal_id_seq
   START WITH 1
   INCREMENT BY 1
   NO MINVALUE
   NO MAXVALUE
   CACHE 1;

ALTER sequence public.datafeed_animal_id_seq OWNER TO oztrack;
ALTER TABLE public.datafeed_animal OWNER TO oztrack;

/* insert into datafeed(
  project_id
 ,source_system
 ,source_system_identifier
 ,source_system_user
 ,source_system_user_uuid
 ,active_flag
 ,active_date
 ,createdate
 ,updatedate
 ,createuser_id
 ,updateuser_id
) select
 ,'ARGOS'
 ,'

*/