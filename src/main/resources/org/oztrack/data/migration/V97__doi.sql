CREATE TABLE doi (
    id bigint NOT NULL,
    doi text,
    xml text,
    url text,
    uuid uuid unique not null,
    filename text,
    citation text,
    published boolean,
    title text,
    creators text,
    status character varying(255),
    draftdate timestamp without time zone,
    submitdate timestamp without time zone,
    canceldate timestamp without time zone,
    rejectdate timestamp without time zone,
    mintdate timestamp without time zone,
    mintupdatedate timestamp without time zone,
    rejectmessage text,
    mintresponse text,
    createdate timestamp without time zone,
    updatedate timestamp without time zone,
    createuser_id bigint,
    updateuser_id bigint,
    project_id bigint
);

ALTER TABLE public.doi OWNER TO oztrack;

CREATE SEQUENCE doiid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.doiid_seq OWNER TO oztrack;
