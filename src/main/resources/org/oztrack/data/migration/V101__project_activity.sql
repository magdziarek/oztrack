-- table to monitor updates to embargos and other things
--drop table project_activity;

create table project_activity
(  id bigint PRIMARY KEY NOT NULL
 , project_id bigint NOT NULL
 , appuser_id bigint NULL
 , activitydate TIMESTAMP NOT NULL
 , activitytype varchar(50) NOT NULL
 , activitycode varchar(20) NOT NULL
 , activitydescr text NULL
 , user_ip varchar(100) NULL
);

CREATE SEQUENCE projectactivityid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projectactivityid_seq OWNER TO oztrack;
ALTER TABLE public.project_activity OWNER TO oztrack;

/*
-- embargo expiry
type: embargo
code: expired
descr: email text

-- embargo notification sent
type: embargo
code: notify
descr: email text

-- user
type: user
code: add
descr: <update user> added <new user>

-- project delete?

-- ala update
type: ala
code: dr_create | dr_update | file upload
descr: json record?

-- metadata update
type: metadata
code: project | animal
descr: json from/to values

-- points update
type: detections
code: delete | restore
descr: {json ids array}

-- doi
type: doi
code: request sent
descr: ?

*/


