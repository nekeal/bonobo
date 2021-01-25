--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3 (Ubuntu 12.3-1.pgdg18.04+1)
-- Dumped by pg_dump version 12.3 (Ubuntu 12.3-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: close_shop(integer); Type: FUNCTION; Schema: public; Owner: bonobo_stage
--

CREATE FUNCTION public.close_shop(shopid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    values text := '';
                    t_row  int;
                BEGIN
                    FOR t_row in SELECT shops_employment.user_id, shops_employment.id
                                 FROM shops_employment
                                 where shops_employment.shop_id = shopid
                                   and upper(timespan) is null
                        LOOP
                            values := values || '(now()::date, ' || t_row ||
                                      ', (select coalesce(avg(value), 2000) from shops_salary where employee_id = ' ||
                                       t_row || ')), ';
                        END LOOP;
                    values := rtrim(values, ', ');
                    if not values = '' then
                        EXECUTE 'insert into shops_salary ("when", "employee_id", "value") values' || values || ';';
                        EXECUTE 'update shops_employment SET timespan = daterange(lower(timespan), now()::date)
                                 where shop_id = ' || shopid ||
                                  ' and upper(timespan) is null';
                    end if;
                END;
                $$;


ALTER FUNCTION public.close_shop(shopid integer) OWNER TO bonobo_stage;

--
-- Name: shop_id_sequence_for_year(); Type: FUNCTION; Schema: public; Owner: bonobo_stage
--

CREATE FUNCTION public.shop_id_sequence_for_year() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
                               seqname text := 'shop_reference_' || extract('year' from now());
                            BEGIN
                                EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || seqname || ' START 10001';
                                NEW.reference := (Concat('bonobo-', EXTRACT('year' from now()), '-', (select nextval(seqname))));
                                RETURN NEW;
                            END;$$;


ALTER FUNCTION public.shop_id_sequence_for_year() OWNER TO bonobo_stage;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts_customuser; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.accounts_customuser (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    base_salary smallint,
    CONSTRAINT accounts_customuser_base_salary_check CHECK ((base_salary >= 0))
);


ALTER TABLE public.accounts_customuser OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_groups; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.accounts_customuser_groups (
    id integer NOT NULL,
    customuser_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.accounts_customuser_groups OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.accounts_customuser_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_customuser_groups_id_seq OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.accounts_customuser_groups_id_seq OWNED BY public.accounts_customuser_groups.id;


--
-- Name: accounts_customuser_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.accounts_customuser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_customuser_id_seq OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.accounts_customuser_id_seq OWNED BY public.accounts_customuser.id;


--
-- Name: accounts_customuser_user_permissions; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.accounts_customuser_user_permissions (
    id integer NOT NULL,
    customuser_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.accounts_customuser_user_permissions OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.accounts_customuser_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_customuser_user_permissions_id_seq OWNER TO bonobo_stage;

--
-- Name: accounts_customuser_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.accounts_customuser_user_permissions_id_seq OWNED BY public.accounts_customuser_user_permissions.id;


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO bonobo_stage;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO bonobo_stage;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO bonobo_stage;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO bonobo_stage;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO bonobo_stage;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO bonobo_stage;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO bonobo_stage;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO bonobo_stage;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO bonobo_stage;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO bonobo_stage;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO bonobo_stage;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO bonobo_stage;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO bonobo_stage;

--
-- Name: shop_reference_2021; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.shop_reference_2021
    START WITH 10001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shop_reference_2021 OWNER TO bonobo_stage;

--
-- Name: shops_employment; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.shops_employment (
    id integer NOT NULL,
    timespan daterange,
    shop_id integer NOT NULL,
    user_id integer NOT NULL,
    role character varying(20) NOT NULL
);


ALTER TABLE public.shops_employment OWNER TO bonobo_stage;

--
-- Name: shops_employment_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.shops_employment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_employment_id_seq OWNER TO bonobo_stage;

--
-- Name: shops_employment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.shops_employment_id_seq OWNED BY public.shops_employment.id;


--
-- Name: shops_income; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.shops_income (
    id integer NOT NULL,
    "when" date NOT NULL,
    value integer NOT NULL,
    shop_id integer NOT NULL,
    CONSTRAINT shops_income_value_check CHECK ((value >= 0))
);


ALTER TABLE public.shops_income OWNER TO bonobo_stage;

--
-- Name: shops_income_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.shops_income_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_income_id_seq OWNER TO bonobo_stage;

--
-- Name: shops_income_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.shops_income_id_seq OWNED BY public.shops_income.id;


--
-- Name: shops_salary; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.shops_salary (
    id integer NOT NULL,
    "when" date NOT NULL,
    employee_id integer NOT NULL,
    value numeric(7,2) NOT NULL
);


ALTER TABLE public.shops_salary OWNER TO bonobo_stage;

--
-- Name: shops_salary_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.shops_salary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_salary_id_seq OWNER TO bonobo_stage;

--
-- Name: shops_salary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.shops_salary_id_seq OWNED BY public.shops_salary.id;


--
-- Name: shops_shop; Type: TABLE; Schema: public; Owner: bonobo_stage
--

CREATE TABLE public.shops_shop (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    modified_at timestamp with time zone NOT NULL,
    slug character varying(50) NOT NULL,
    location public.geography(Point,4326),
    created_by_id integer,
    modified_by_id integer,
    maps_url character varying(200) NOT NULL,
    place_name character varying(200) NOT NULL,
    reference character varying(200) NOT NULL
);


ALTER TABLE public.shops_shop OWNER TO bonobo_stage;

--
-- Name: shops_shop_id_seq; Type: SEQUENCE; Schema: public; Owner: bonobo_stage
--

CREATE SEQUENCE public.shops_shop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_shop_id_seq OWNER TO bonobo_stage;

--
-- Name: shops_shop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bonobo_stage
--

ALTER SEQUENCE public.shops_shop_id_seq OWNED BY public.shops_shop.id;


--
-- Name: accounts_customuser id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser ALTER COLUMN id SET DEFAULT nextval('public.accounts_customuser_id_seq'::regclass);


--
-- Name: accounts_customuser_groups id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_groups ALTER COLUMN id SET DEFAULT nextval('public.accounts_customuser_groups_id_seq'::regclass);


--
-- Name: accounts_customuser_user_permissions id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.accounts_customuser_user_permissions_id_seq'::regclass);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: shops_employment id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_employment ALTER COLUMN id SET DEFAULT nextval('public.shops_employment_id_seq'::regclass);


--
-- Name: shops_income id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_income ALTER COLUMN id SET DEFAULT nextval('public.shops_income_id_seq'::regclass);


--
-- Name: shops_salary id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_salary ALTER COLUMN id SET DEFAULT nextval('public.shops_salary_id_seq'::regclass);


--
-- Name: shops_shop id; Type: DEFAULT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_shop ALTER COLUMN id SET DEFAULT nextval('public.shops_shop_id_seq'::regclass);


--
-- Data for Name: accounts_customuser; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.accounts_customuser (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, base_salary) FROM stdin;
2	pbkdf2_sha256$216000$MjJVRLDAiwBQ$QC42TV9TTuPMl59TmkFIUIB2f1SCeC/AiKyk2IjzbfY=	\N	f	johny123	John	Smith	john-smith@example.com	f	t	2020-12-11 23:27:01+01	\N
3	pbkdf2_sha256$216000$7Y9xFL0metpU$teF+XKqKhNxAHngBKIsQquir1yv9Cz9PAExa8n1aYU8=	\N	f	jack	Jack	Sparrow		f	f	2021-01-05 13:38:21+01	\N
1	pbkdf2_sha256$216000$1ZvjGAbTRQfK$edWRfUCVFK5gN18CV4VXIatx8zmMbPa3RJ2EupQCEQ4=	2021-01-25 16:32:21.019617+01	t	admin	admin	admin		t	t	2020-12-11 23:13:10.772882+01	\N
\.


--
-- Data for Name: accounts_customuser_groups; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.accounts_customuser_groups (id, customuser_id, group_id) FROM stdin;
\.


--
-- Data for Name: accounts_customuser_user_permissions; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.accounts_customuser_user_permissions (id, customuser_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add content type	4	add_contenttype
14	Can change content type	4	change_contenttype
15	Can delete content type	4	delete_contenttype
16	Can view content type	4	view_contenttype
17	Can add session	5	add_session
18	Can change session	5	change_session
19	Can delete session	5	delete_session
20	Can view session	5	view_session
21	Can add user	6	add_customuser
22	Can change user	6	change_customuser
23	Can delete user	6	delete_customuser
24	Can view user	6	view_customuser
25	Can add shop	7	add_shop
26	Can change shop	7	change_shop
27	Can delete shop	7	delete_shop
28	Can view shop	7	view_shop
29	Can add salary	8	add_salary
30	Can change salary	8	change_salary
31	Can delete salary	8	delete_salary
32	Can view salary	8	view_salary
33	Can add income	9	add_income
34	Can change income	9	change_income
35	Can delete income	9	delete_income
36	Can view income	9	view_income
37	Can add employment	10	add_employment
38	Can change employment	10	change_employment
39	Can delete employment	10	delete_employment
40	Can view employment	10	view_employment
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
1	2021-01-04 12:48:45.046969+01	1	John Smith - 2020-11-15	2	[{"changed": {"fields": ["Value"]}}]	8	1
2	2021-01-04 12:51:41.371302+01	1	John Smith - 2020-11-15	2	[{"changed": {"fields": ["Value"]}}]	8	1
3	2021-01-05 10:13:23.807385+01	3	bonobo-wesola	1	[{"added": {}}]	7	1
4	2021-01-05 10:13:58.564099+01	3	bonobo-wesola	2	[{"changed": {"fields": ["Place name"]}}]	7	1
5	2021-01-05 10:14:13.147997+01	3	bonobo-wesola	2	[]	7	1
6	2021-01-05 10:15:53.743684+01	4	bonobo-dworcowa	1	[{"added": {}}]	7	1
7	2021-01-05 10:30:55.054495+01	4	bonobo-dworcowa	2	[]	7	1
8	2021-01-05 10:31:17.18998+01	5	bonobo-podwale	1	[{"added": {}}]	7	1
9	2021-01-05 10:31:26.545288+01	5	bonobo-podwale	2	[]	7	1
10	2021-01-05 10:31:49.405937+01	6	bonobo-kosciuszki	1	[{"added": {}}]	7	1
11	2021-01-05 10:32:20.181323+01	7	bonobo-sienkiewicza	1	[{"added": {}}]	7	1
12	2021-01-05 10:32:37.899379+01	8	bonobo-pildsudzkiego	1	[{"added": {}}]	7	1
13	2021-01-05 10:33:21.053006+01	9	bonobo-mlodych	1	[{"added": {}}]	7	1
14	2021-01-05 10:33:44.93844+01	10	bonobo-komorowskich	1	[{"added": {}}]	7	1
15	2021-01-05 10:37:48.323341+01	4	bonobo-dworcowa	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
16	2021-01-05 10:38:02.601642+01	3	bonobo-wesola	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
17	2021-01-05 10:38:20.381609+01	5	bonobo-podwale	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
18	2021-01-05 10:38:32.479067+01	6	bonobo-kosciuszki	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
19	2021-01-05 10:38:43.186715+01	7	bonobo-sienkiewicza	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
20	2021-01-05 10:38:55.363299+01	8	bonobo-pildsudzkiego	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
21	2021-01-05 10:39:30.392042+01	9	bonobo-mlodych	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
22	2021-01-05 10:40:21.240902+01	10	bonobo-komorowskich	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
23	2021-01-05 12:46:09.466649+01	3	bonobo-wesola	2	[{"changed": {"fields": ["Maps url"]}}]	7	1
24	2021-01-05 13:16:19.798947+01	3	admin admin bonobo-warszawa	1	[{"added": {}}]	10	1
25	2021-01-05 13:19:26.65939+01	4	admin admin - 2020-10-01	2	[{"changed": {"fields": ["When"]}}]	8	1
26	2021-01-05 13:19:40.191455+01	5	admin admin - 2020-11-11	1	[{"added": {}}]	8	1
27	2021-01-05 13:19:49.942443+01	6	admin admin - 2020-12-01	1	[{"added": {}}]	8	1
28	2021-01-05 13:21:03.094683+01	8	admin admin - 2021-01-05	3		8	1
29	2021-01-05 13:21:11.407958+01	3	admin admin bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
30	2021-01-05 13:35:20.741648+01	7	John Smith - 2021-01-05	3		8	1
31	2021-01-05 13:36:18.656696+01	9	admin admin - 2021-01-05	3		8	1
32	2021-01-05 13:36:24.759507+01	3	admin admin bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
33	2021-01-05 13:36:24.819985+01	3	admin admin bonobo-warszawa	2	[]	10	1
34	2021-01-05 13:38:45.016342+01	3	jack	2	[{"changed": {"fields": ["First name", "Last name", "Active", "Staff status", "Superuser status"]}}]	6	1
35	2021-01-05 13:39:19.976726+01	4	Jack Sparrow bonobo-warszawa	1	[{"added": {}}]	10	1
36	2021-01-05 13:40:27.995498+01	4	Jack Sparrow bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
37	2021-01-05 13:40:32.199944+01	3	admin admin bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
38	2021-01-05 13:40:43.636083+01	11	Jack Sparrow - 2021-01-05	3		8	1
39	2021-01-05 13:40:43.6411+01	10	admin admin - 2021-01-05	3		8	1
40	2021-01-05 16:11:34.798354+01	13	Jack Sparrow - 2021-01-05	3		8	1
41	2021-01-05 16:11:34.809999+01	12	admin admin - 2021-01-05	3		8	1
42	2021-01-05 16:11:39.837194+01	4	Jack Sparrow bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
43	2021-01-05 16:11:44.715784+01	3	admin admin bonobo-warszawa	2	[{"changed": {"fields": ["Timespan"]}}]	10	1
44	2021-01-05 16:12:07.392664+01	11	bonobo-test	1	[{"added": {}}]	7	1
45	2021-01-05 16:53:23.996373+01	11	bonobo-test	3		7	1
46	2021-01-05 17:07:18.313356+01	12	bonobo-test	1	[{"added": {}}]	7	1
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	contenttypes	contenttype
5	sessions	session
6	accounts	customuser
7	shops	shop
8	shops	salary
9	shops	income
10	shops	employment
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2020-12-16 21:09:09.874459+01
2	contenttypes	0002_remove_content_type_name	2020-12-16 21:09:09.984953+01
3	auth	0001_initial	2020-12-16 21:09:10.09736+01
4	auth	0002_alter_permission_name_max_length	2020-12-16 21:09:10.254143+01
5	auth	0003_alter_user_email_max_length	2020-12-16 21:09:10.275816+01
6	auth	0004_alter_user_username_opts	2020-12-16 21:09:10.287512+01
7	auth	0005_alter_user_last_login_null	2020-12-16 21:09:10.300946+01
8	auth	0006_require_contenttypes_0002	2020-12-16 21:09:10.30823+01
9	auth	0007_alter_validators_add_error_messages	2020-12-16 21:09:10.330323+01
10	auth	0008_alter_user_username_max_length	2020-12-16 21:09:10.378869+01
11	auth	0009_alter_user_last_name_max_length	2020-12-16 21:09:10.412133+01
12	auth	0010_alter_group_name_max_length	2020-12-16 21:09:10.442484+01
13	auth	0011_update_proxy_permissions	2020-12-16 21:09:10.475335+01
14	auth	0012_alter_user_first_name_max_length	2020-12-16 21:09:10.491463+01
15	accounts	0001_initial	2020-12-16 21:09:10.542196+01
16	shops	0001_initial	2020-12-16 21:09:10.753706+01
17	accounts	0002_auto_20201214_1827	2020-12-16 21:09:10.868037+01
18	admin	0001_initial	2020-12-16 21:09:10.953524+01
19	admin	0002_logentry_remove_auto_add	2020-12-16 21:09:11.007011+01
20	admin	0003_logentry_add_action_flag_choices	2020-12-16 21:09:11.029446+01
21	sessions	0001_initial	2020-12-16 21:09:11.048932+01
22	shops	0002_auto_20201221_2023	2020-12-22 17:42:30.246559+01
23	shops	0003_shop_reference	2021-01-03 21:03:51.891674+01
24	shops	0004_salary_value	2021-01-04 12:38:44.577475+01
25	shops	0005_auto_20210105_1026	2021-01-05 10:30:43.291702+01
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
lj0e5pggrl8d6tq207454bujdghzp3lu	.eJxVjDsOwjAQBe_iGlkx6y8lfc5grddrHECOFCcV4u4QKQW0b2beS0Tc1hq3zkucsrgIJU6_W0J6cNtBvmO7zZLmti5TkrsiD9rlOGd-Xg_376Bir9_anLUDosw4FCocyGhnIXnWGr1WYEOwDlQaUtbGGpcTuuABCAtwQBTvD-e2OBE:1kpd77:eEyOV4CG5wxBa_oa2BLA5RgtEDaO8N7bQauVYPWu6X0	2020-12-30 21:09:33.67231+01
e4qnef7n5h8n5r2q5utf5pmsn0k8k3iz	.eJxVjDsOwjAQBe_iGlkx6y8lfc5grddrHECOFCcV4u4QKQW0b2beS0Tc1hq3zkucsrgIJU6_W0J6cNtBvmO7zZLmti5TkrsiD9rlOGd-Xg_376Bir9_anLUDosw4FCocyGhnIXnWGr1WYEOwDlQaUtbGGpcTuuABCAtwQBTvD-e2OBE:1ktymA:ANuFeTcyQR3ittNqKXL9xmt4ut0ycYh74IAyRCwObmI	2021-01-11 21:05:54.510148+01
heuzq47jgmu7zh03uo1nxnh9sqrdsx7f	.eJxVjDsOwjAQBe_iGlkx6y8lfc5grddrHECOFCcV4u4QKQW0b2beS0Tc1hq3zkucsrgIJU6_W0J6cNtBvmO7zZLmti5TkrsiD9rlOGd-Xg_376Bir9_anLUDosw4FCocyGhnIXnWGr1WYEOwDlQaUtbGGpcTuuABCAtwQBTvD-e2OBE:1kw9dR:bYXZSmR0Ox7B6pQGbP15hNuTbPL-Ex59bHoc9XFF3og	2021-01-17 21:05:53.071628+01
8wp4vdk3hry2pia6u3fd7frgyw1lraer	.eJxVjDsOwjAQBe_iGlkx6y8lfc5grddrHECOFCcV4u4QKQW0b2beS0Tc1hq3zkucsrgIJU6_W0J6cNtBvmO7zZLmti5TkrsiD9rlOGd-Xg_376Bir9_anLUDosw4FCocyGhnIXnWGr1WYEOwDlQaUtbGGpcTuuABCAtwQBTvD-e2OBE:1l43qn:PZj2t8dj7xeq36pD6QGzbTFXkzALVubaiSKSxvJwDS0	2021-02-08 16:32:21.045654+01
\.


--
-- Data for Name: shops_employment; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.shops_employment (id, timespan, shop_id, user_id, role) FROM stdin;
1	[2020-06-01,2020-11-01)	1	1	MANAGER
2	[2020-01-01,2021-01-05)	2	2	CASHIER
3	[2020-11-05,2021-01-05)	2	1	MANAGER
4	[2020-12-03,2021-01-05)	2	3	CASHIER
\.


--
-- Data for Name: shops_income; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.shops_income (id, "when", value, shop_id) FROM stdin;
1	2020-12-01	10000	1
2	2021-01-02	1000	1
3	2020-11-01	99000	2
4	2020-12-31	45000	2
\.


--
-- Data for Name: shops_salary; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.shops_salary (id, "when", employee_id, value) FROM stdin;
2	2020-10-10	2	1000.00
3	2020-09-11	2	2000.00
1	2020-11-15	2	3500.00
4	2020-10-01	1	3000.00
5	2020-11-11	1	3500.00
6	2020-12-01	1	6000.00
14	2021-01-05	1	4166.67
15	2021-01-05	3	2000.00
\.


--
-- Data for Name: shops_shop; Type: TABLE DATA; Schema: public; Owner: bonobo_stage
--

COPY public.shops_shop (id, created_at, modified_at, slug, location, created_by_id, modified_by_id, maps_url, place_name, reference) FROM stdin;
8	2021-01-05 10:32:37.861854+01	2021-01-05 10:38:55.354414+01	bonobo-pildsudzkiego	0101000020E61000007DB3CD8DE93333408C9D955929D84840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6887619,19.2027825,18z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0x8808ca552cfe0f5f!8m2!3d49.6888308!4d19.2061702?hl=PL	Żabka	bonobo-2021-10006
9	2021-01-05 10:33:21.032894+01	2021-01-05 10:39:30.387302+01	bonobo-mlodych	0101000020E6100000565CC1DB28353340D2E3F736FDD74840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.687415,19.2076547,20z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0x6e4e378517e35789!8m2!3d49.6873602!4d19.2081249?hl=PL	Żabka	bonobo-2021-10007
1	2020-11-01 11:10:10.066687+01	2020-12-21 21:37:08.558405+01	bonobo-krakow	0101000020E610000065016E71E8EE3340336B2920ED064940	1	1	https://www.google.com/maps/place/Zamek+Królewski+na+Wawelu/@50.0541115,19.9332343,17z/data=!3m1!4b1!4m5!3m4!1s0x47165b6d053619f5:0xacb9dfc4d67fa598!8m2!3d50.0541115!4d19.935423?hl=PL	Zamek Królewski na Wawelu	bonobo-2020-10001
2	2020-10-01 10:15:00.110255+02	2020-12-21 21:36:33.298548+01	bonobo-warszawa	0101000020E6100000CE041E73F90035402BFC19DEAC1D4A40	1	1	https://www.google.com/maps/place/Pałac+Kultury+i+Nauki+Bonobo/@52.231838,21.0038063,17z/data=!3m1!4b1!4m5!3m4!1s0x471ecc8c92692e49:0xc2e97ae5311f2dc2!8m2!3d52.231838!4d21.005995?hl=PL	PaŁac Kultury i Nauki Bonobo	bonobo-2020-10002
10	2021-01-05 10:33:44.917064+01	2021-01-05 10:40:21.237421+01	bonobo-komorowskich	0101000020E610000004633376783433409161156F64D74840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6827525,19.2049631,17z/data=!4m5!3m4!1s0x0:0x31cec80df9df8e84!8m2!3d49.6829741!4d19.2071539?hl=PL	Żabka	bonobo-2021-10008
3	2021-01-05 10:13:23.64322+01	2021-01-05 12:46:09.458553+01	bonobo-wesola	0101000020E6100000006F8104C52D33406F6589CE32D94840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.696863,19.1787875,18z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0x8462bb22dfd2f4ec!8m2!3d49.6969189!4d19.1793609?hl=PL	Żabka	bonobo-2021-10001
12	2021-01-05 17:07:18.282651+01	2021-01-05 17:07:18.282702+01	bonobo-test	\N	\N	\N			bonobo-2021-10010
4	2021-01-05 10:15:53.721536+01	2021-01-05 10:37:48.318709+01	bonobo-dworcowa	0101000020E61000002FF2576DA330334074ACF7C033D74840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6812669,19.1899937,16z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0x426d1ccdba9bebad!8m2!3d49.6832301!4d19.1900817?hl=PL	Żabka	bonobo-2021-10002
5	2021-01-05 10:31:17.168456+01	2021-01-05 10:38:20.3783+01	bonobo-podwale	0101000020E61000006C59637550303340A28625D4C2D74840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6856332,19.1887277,15z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0xfff9536a5a763459!8m2!3d49.6861507!4d19.1948211?hl=PL	Żabka	bonobo-2021-10003
6	2021-01-05 10:31:49.382063+01	2021-01-05 10:38:32.474169+01	bonobo-kosciuszki	0101000020E610000042F4FF05DD313340BB37D08DFAD74840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6873338,19.1947788,16z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0xac7338982fbe2021!8m2!3d49.6886616!4d19.2009473?hl=PL	Żabka	bonobo-2021-10004
7	2021-01-05 10:32:20.160579+01	2021-01-05 10:38:43.183083+01	bonobo-sienkiewicza	0101000020E610000059315C1D00333340111EC8D523D84840	\N	\N	https://www.google.com/maps/place/%C5%BBabka/@49.6885936,19.1992205,17z/data=!4m8!1m2!2m1!1szabka!3m4!1s0x0:0x9130f6cb2b0d01c9!8m2!3d49.6896646!4d19.2035115?hl=PL	Żabka	bonobo-2021-10005
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Name: accounts_customuser_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.accounts_customuser_groups_id_seq', 1, false);


--
-- Name: accounts_customuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.accounts_customuser_id_seq', 3, true);


--
-- Name: accounts_customuser_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.accounts_customuser_user_permissions_id_seq', 1, false);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 40, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 46, true);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 10, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 25, true);


--
-- Name: shop_reference_2021; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.shop_reference_2021', 10010, true);


--
-- Name: shops_employment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.shops_employment_id_seq', 4, true);


--
-- Name: shops_income_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.shops_income_id_seq', 4, true);


--
-- Name: shops_salary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.shops_salary_id_seq', 15, true);


--
-- Name: shops_shop_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bonobo_stage
--

SELECT pg_catalog.setval('public.shops_shop_id_seq', 12, true);


--
-- Name: accounts_customuser_groups accounts_customuser_groups_customuser_id_group_id_c074bdcb_uniq; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_groups
    ADD CONSTRAINT accounts_customuser_groups_customuser_id_group_id_c074bdcb_uniq UNIQUE (customuser_id, group_id);


--
-- Name: accounts_customuser_groups accounts_customuser_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_groups
    ADD CONSTRAINT accounts_customuser_groups_pkey PRIMARY KEY (id);


--
-- Name: accounts_customuser accounts_customuser_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser
    ADD CONSTRAINT accounts_customuser_pkey PRIMARY KEY (id);


--
-- Name: accounts_customuser_user_permissions accounts_customuser_user_customuser_id_permission_9632a709_uniq; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_user_permissions
    ADD CONSTRAINT accounts_customuser_user_customuser_id_permission_9632a709_uniq UNIQUE (customuser_id, permission_id);


--
-- Name: accounts_customuser_user_permissions accounts_customuser_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_user_permissions
    ADD CONSTRAINT accounts_customuser_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: accounts_customuser accounts_customuser_username_key; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser
    ADD CONSTRAINT accounts_customuser_username_key UNIQUE (username);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: shops_employment shops_employment_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_employment
    ADD CONSTRAINT shops_employment_pkey PRIMARY KEY (id);


--
-- Name: shops_income shops_income_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_income
    ADD CONSTRAINT shops_income_pkey PRIMARY KEY (id);


--
-- Name: shops_salary shops_salary_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_salary
    ADD CONSTRAINT shops_salary_pkey PRIMARY KEY (id);


--
-- Name: shops_shop shops_shop_pkey; Type: CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_shop
    ADD CONSTRAINT shops_shop_pkey PRIMARY KEY (id);


--
-- Name: accounts_customuser_groups_customuser_id_bc55088e; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX accounts_customuser_groups_customuser_id_bc55088e ON public.accounts_customuser_groups USING btree (customuser_id);


--
-- Name: accounts_customuser_groups_group_id_86ba5f9e; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX accounts_customuser_groups_group_id_86ba5f9e ON public.accounts_customuser_groups USING btree (group_id);


--
-- Name: accounts_customuser_user_permissions_customuser_id_0deaefae; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX accounts_customuser_user_permissions_customuser_id_0deaefae ON public.accounts_customuser_user_permissions USING btree (customuser_id);


--
-- Name: accounts_customuser_user_permissions_permission_id_aea3d0e5; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX accounts_customuser_user_permissions_permission_id_aea3d0e5 ON public.accounts_customuser_user_permissions USING btree (permission_id);


--
-- Name: accounts_customuser_username_722f3555_like; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX accounts_customuser_username_722f3555_like ON public.accounts_customuser USING btree (username varchar_pattern_ops);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: shops_employment_shop_id_8e919ea0; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_employment_shop_id_8e919ea0 ON public.shops_employment USING btree (shop_id);


--
-- Name: shops_employment_user_id_cce37922; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_employment_user_id_cce37922 ON public.shops_employment USING btree (user_id);


--
-- Name: shops_income_shop_id_63b312bd; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_income_shop_id_63b312bd ON public.shops_income USING btree (shop_id);


--
-- Name: shops_salary_employee_id_d3eb5fad; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_salary_employee_id_d3eb5fad ON public.shops_salary USING btree (employee_id);


--
-- Name: shops_shop_created_by_id_1fe1e67f; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_shop_created_by_id_1fe1e67f ON public.shops_shop USING btree (created_by_id);


--
-- Name: shops_shop_location_id; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_shop_location_id ON public.shops_shop USING gist (location);


--
-- Name: shops_shop_modified_by_id_d4260823; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_shop_modified_by_id_d4260823 ON public.shops_shop USING btree (modified_by_id);


--
-- Name: shops_shop_slug_126a7d68; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_shop_slug_126a7d68 ON public.shops_shop USING btree (slug);


--
-- Name: shops_shop_slug_126a7d68_like; Type: INDEX; Schema: public; Owner: bonobo_stage
--

CREATE INDEX shops_shop_slug_126a7d68_like ON public.shops_shop USING btree (slug varchar_pattern_ops);


--
-- Name: shops_shop shop_id_sequence_for_year_trigger; Type: TRIGGER; Schema: public; Owner: bonobo_stage
--

CREATE TRIGGER shop_id_sequence_for_year_trigger BEFORE INSERT ON public.shops_shop FOR EACH ROW EXECUTE FUNCTION public.shop_id_sequence_for_year();


--
-- Name: accounts_customuser_user_permissions accounts_customuser__customuser_id_0deaefae_fk_accounts_; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_user_permissions
    ADD CONSTRAINT accounts_customuser__customuser_id_0deaefae_fk_accounts_ FOREIGN KEY (customuser_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: accounts_customuser_groups accounts_customuser__customuser_id_bc55088e_fk_accounts_; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_groups
    ADD CONSTRAINT accounts_customuser__customuser_id_bc55088e_fk_accounts_ FOREIGN KEY (customuser_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: accounts_customuser_user_permissions accounts_customuser__permission_id_aea3d0e5_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_user_permissions
    ADD CONSTRAINT accounts_customuser__permission_id_aea3d0e5_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: accounts_customuser_groups accounts_customuser_groups_group_id_86ba5f9e_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.accounts_customuser_groups
    ADD CONSTRAINT accounts_customuser_groups_group_id_86ba5f9e_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_accounts_customuser_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_accounts_customuser_id FOREIGN KEY (user_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_employment shops_employment_shop_id_8e919ea0_fk_shops_shop_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_employment
    ADD CONSTRAINT shops_employment_shop_id_8e919ea0_fk_shops_shop_id FOREIGN KEY (shop_id) REFERENCES public.shops_shop(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_employment shops_employment_user_id_cce37922_fk_accounts_customuser_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_employment
    ADD CONSTRAINT shops_employment_user_id_cce37922_fk_accounts_customuser_id FOREIGN KEY (user_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_income shops_income_shop_id_63b312bd_fk_shops_shop_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_income
    ADD CONSTRAINT shops_income_shop_id_63b312bd_fk_shops_shop_id FOREIGN KEY (shop_id) REFERENCES public.shops_shop(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_salary shops_salary_employee_id_d3eb5fad_fk_accounts_customuser_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_salary
    ADD CONSTRAINT shops_salary_employee_id_d3eb5fad_fk_accounts_customuser_id FOREIGN KEY (employee_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_shop shops_shop_created_by_id_1fe1e67f_fk_accounts_customuser_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_shop
    ADD CONSTRAINT shops_shop_created_by_id_1fe1e67f_fk_accounts_customuser_id FOREIGN KEY (created_by_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: shops_shop shops_shop_modified_by_id_d4260823_fk_accounts_customuser_id; Type: FK CONSTRAINT; Schema: public; Owner: bonobo_stage
--

ALTER TABLE ONLY public.shops_shop
    ADD CONSTRAINT shops_shop_modified_by_id_d4260823_fk_accounts_customuser_id FOREIGN KEY (modified_by_id) REFERENCES public.accounts_customuser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

