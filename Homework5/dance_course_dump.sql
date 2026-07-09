--
-- PostgreSQL database dump
--

-- Dumped from database version 14.13
-- Dumped by pg_dump version 16.4

-- Started on 2026-07-09 22:05:25

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
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 280087)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 280098)
-- Name: dance_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dance_styles (
    style_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    style_name character varying(100) NOT NULL,
    description text,
    difficulty_level integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dance_styles_difficulty_level_check CHECK (((difficulty_level >= 1) AND (difficulty_level <= 5)))
);


ALTER TABLE public.dance_styles OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 280132)
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    group_id integer NOT NULL,
    group_name character varying(50) NOT NULL,
    style_id uuid NOT NULL,
    teacher_id integer NOT NULL,
    max_students integer DEFAULT 15,
    room_number character varying(10),
    schedule_day integer,
    schedule_time time without time zone NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT groups_schedule_day_check CHECK (((schedule_day >= 1) AND (schedule_day <= 7)))
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 280131)
-- Name: groups_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_group_id_seq OWNER TO postgres;

--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 214
-- Name: groups_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_group_id_seq OWNED BY public.groups.group_id;


--
-- TOC entry 218 (class 1259 OID 280172)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id integer NOT NULL,
    student_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_method character varying(50),
    is_paid boolean DEFAULT true,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payments_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['Cash'::character varying, 'Card'::character varying, 'Online'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 280171)
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_payment_id_seq OWNER TO postgres;

--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 217
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- TOC entry 216 (class 1259 OID 280152)
-- Name: student_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_groups (
    student_id uuid NOT NULL,
    group_id integer NOT NULL,
    enrollment_date date DEFAULT CURRENT_DATE,
    monthly_fee numeric(10,2),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT student_groups_monthly_fee_check CHECK ((monthly_fee >= (0)::numeric))
);


ALTER TABLE public.student_groups OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 280120)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    student_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100),
    phone character varying(20),
    birth_date date,
    registration_date date DEFAULT CURRENT_DATE,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 280110)
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    teacher_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100),
    phone character varying(20),
    hire_date date NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 280109)
-- Name: teachers_teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teachers_teacher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teachers_teacher_id_seq OWNER TO postgres;

--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 211
-- Name: teachers_teacher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teachers_teacher_id_seq OWNED BY public.teachers.teacher_id;


--
-- TOC entry 3207 (class 2604 OID 280135)
-- Name: groups group_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN group_id SET DEFAULT nextval('public.groups_group_id_seq'::regclass);


--
-- TOC entry 3214 (class 2604 OID 280175)
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 280113)
-- Name: teachers teacher_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers ALTER COLUMN teacher_id SET DEFAULT nextval('public.teachers_teacher_id_seq'::regclass);


--
-- TOC entry 3384 (class 0 OID 280098)
-- Dependencies: 210
-- Data for Name: dance_styles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dance_styles (style_id, style_name, description, difficulty_level, is_active, created_at) FROM stdin;
ed012d32-f44b-448e-a16e-a9f602dae808	Бальные танцы	Классические европейские танцы: вальс, танго, фокстрот	3	t	2026-07-09 21:44:14.192616
26fba347-1041-4370-94cd-f164b2f2b42a	Хип-хоп	Уличный стиль танца с элементами импровизации	2	t	2026-07-09 21:44:14.192616
689e162d-08be-46fb-ae7f-e38ae76dab73	Брейк-данс	Силовой акробатический стиль	5	t	2026-07-09 21:44:14.192616
62b49a07-b383-40a4-b82d-1a165db580ea	Джаз-модерн	Современное направление с элементами классики	3	t	2026-07-09 21:44:14.192616
f302bbeb-f751-4999-bf8d-bb255103a650	Сальса	Латиноамериканский парный танец	2	t	2026-07-09 21:44:14.192616
dff91d55-2b6e-434b-887d-aaf34b494f2b	Бачата	Романтичный парный танец из Доминиканы	2	t	2026-07-09 21:44:14.192616
b1555422-0470-4866-a98a-911d83ee30ec	Кизомба	Ангольский парный танец с плавными движениями	3	t	2026-07-09 21:44:14.192616
f7593b7d-de96-472d-96ec-329a5c1d2a55	Танцы на пилоне	Акробатика на вертикальном пилоне	5	t	2026-07-09 21:44:14.192616
0d4f5427-5367-4b06-a7cb-aeb7ca32ccd7	Контемпорари	Современный танец с элементами импровизации	4	t	2026-07-09 21:44:14.192616
689d4ca6-7b29-4dc3-b580-739d4fd91a40	Фламенко	Испанский страстный танец	4	t	2026-07-09 21:44:14.192616
\.


--
-- TOC entry 3389 (class 0 OID 280132)
-- Dependencies: 215
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (group_id, group_name, style_id, teacher_id, max_students, room_number, schedule_day, schedule_time, is_active, created_at) FROM stdin;
1	Бальный вальс	ed012d32-f44b-448e-a16e-a9f602dae808	1	12	101	1	10:00:00	t	2026-07-09 21:44:42.525399
2	Хип-хоп для начинающих	26fba347-1041-4370-94cd-f164b2f2b42a	3	15	102	2	11:00:00	t	2026-07-09 21:44:42.525399
3	Сальса-дэнс	f302bbeb-f751-4999-bf8d-bb255103a650	2	10	103	3	12:00:00	t	2026-07-09 21:44:42.525399
4	Бачата	dff91d55-2b6e-434b-887d-aaf34b494f2b	2	10	103	3	13:00:00	t	2026-07-09 21:44:42.525399
5	Джаз-модерн	62b49a07-b383-40a4-b82d-1a165db580ea	4	12	104	4	14:00:00	t	2026-07-09 21:44:42.525399
6	Брейк-данс	689e162d-08be-46fb-ae7f-e38ae76dab73	5	8	105	5	15:00:00	t	2026-07-09 21:44:42.525399
7	Контемпорари	0d4f5427-5367-4b06-a7cb-aeb7ca32ccd7	4	10	104	6	16:00:00	t	2026-07-09 21:44:42.525399
8	Кизомба	b1555422-0470-4866-a98a-911d83ee30ec	6	10	103	1	17:00:00	t	2026-07-09 21:44:42.525399
9	Пилон (начинающие)	f7593b7d-de96-472d-96ec-329a5c1d2a55	7	8	106	2	18:00:00	t	2026-07-09 21:44:42.525399
10	Фламенко	689d4ca6-7b29-4dc3-b580-739d4fd91a40	8	10	107	3	19:00:00	t	2026-07-09 21:44:42.525399
11	Танго	ed012d32-f44b-448e-a16e-a9f602dae808	1	10	101	4	10:00:00	t	2026-07-09 21:44:42.525399
12	Хип-хоп (продвинутые)	26fba347-1041-4370-94cd-f164b2f2b42a	3	10	102	5	11:00:00	t	2026-07-09 21:44:42.525399
13	Сальса-люкс	f302bbeb-f751-4999-bf8d-bb255103a650	2	8	103	6	12:00:00	t	2026-07-09 21:44:42.525399
14	Бачата-эротика	dff91d55-2b6e-434b-887d-aaf34b494f2b	2	8	103	1	13:00:00	t	2026-07-09 21:44:42.525399
15	Контемпорари+	0d4f5427-5367-4b06-a7cb-aeb7ca32ccd7	9	8	104	2	14:00:00	t	2026-07-09 21:44:42.525399
\.


--
-- TOC entry 3392 (class 0 OID 280172)
-- Dependencies: 218
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, student_id, amount, payment_date, payment_method, is_paid, description, created_at) FROM stdin;
1	bdef9a06-cffc-45fc-888f-50e025f7c22a	5000.00	2023-01-10 10:00:00	Card	t	Оплата за январь - Бальный вальс	2026-07-09 21:45:03.229713
2	bdef9a06-cffc-45fc-888f-50e025f7c22a	5500.00	2023-02-15 11:00:00	Online	t	Оплата за февраль - Сальса	2026-07-09 21:45:03.229713
3	bdef9a06-cffc-45fc-888f-50e025f7c22a	5000.00	2023-03-10 10:00:00	Card	t	Оплата за март - Бальный вальс	2026-07-09 21:45:03.229713
4	99d637a5-2692-4b8b-b9b5-a553f7f2afae	5000.00	2023-01-15 12:00:00	Cash	t	Оплата за январь - Бальный вальс	2026-07-09 21:45:03.229713
5	99d637a5-2692-4b8b-b9b5-a553f7f2afae	5000.00	2023-02-15 12:00:00	Cash	t	Оплата за февраль - Бальный вальс	2026-07-09 21:45:03.229713
6	99d637a5-2692-4b8b-b9b5-a553f7f2afae	5000.00	2023-03-01 13:00:00	Online	t	Оплата за март - Бачата	2026-07-09 21:45:03.229713
7	2a9f4a50-8c34-4c68-ba60-399c6ca25eec	5000.00	2023-02-01 10:00:00	Card	t	Оплата за февраль - Бальный вальс	2026-07-09 21:45:03.229713
8	2a9f4a50-8c34-4c68-ba60-399c6ca25eec	4500.00	2023-05-01 11:00:00	Online	t	Оплата за май - Хип-хоп	2026-07-09 21:45:03.229713
9	065ddc65-b2b5-4f5e-8d71-cd7569c2e787	4500.00	2023-02-15 14:00:00	Card	t	Оплата за февраль - Хип-хоп	2026-07-09 21:45:03.229713
10	065ddc65-b2b5-4f5e-8d71-cd7569c2e787	4500.00	2023-03-15 14:00:00	Online	t	Оплата за март - Хип-хоп	2026-07-09 21:45:03.229713
11	8548b6e5-23de-49fd-bb44-21f069164559	4500.00	2023-03-01 15:00:00	Cash	t	Оплата за март - Хип-хоп	2026-07-09 21:45:03.229713
12	8548b6e5-23de-49fd-bb44-21f069164559	4500.00	2023-04-01 15:00:00	Card	t	Оплата за апрель - Хип-хоп	2026-07-09 21:45:03.229713
13	019b9387-9a77-4ed4-9d68-e916a5d80da3	4500.00	2023-03-15 16:00:00	Online	t	Оплата за март - Хип-хоп	2026-07-09 21:45:03.229713
14	019b9387-9a77-4ed4-9d68-e916a5d80da3	5500.00	2023-04-01 16:00:00	Card	t	Оплата за апрель - Сальса	2026-07-09 21:45:03.229713
15	76378c2a-32d6-4835-994c-72ecbcfe5b1b	5500.00	2023-04-01 17:00:00	Online	t	Оплата за апрель - Сальса	2026-07-09 21:45:03.229713
16	76378c2a-32d6-4835-994c-72ecbcfe5b1b	5500.00	2023-05-01 17:00:00	Card	t	Оплата за май - Сальса	2026-07-09 21:45:03.229713
17	d8dee414-5a10-4af9-a207-64368a0b219c	5500.00	2023-04-15 10:00:00	Cash	t	Оплата за апрель - Сальса	2026-07-09 21:45:03.229713
18	8f66c4f1-74d8-48fa-8356-ce07ef4d8238	5500.00	2023-05-01 11:00:00	Online	t	Оплата за май - Сальса	2026-07-09 21:45:03.229713
19	06303b43-01ca-41ac-bbdb-ad99878003c1	5000.00	2023-05-15 12:00:00	Card	t	Оплата за май - Бачата	2026-07-09 21:45:03.229713
20	87c524db-065b-4bdf-ae9d-29da6a39f00f	5000.00	2023-06-01 13:00:00	Online	t	Оплата за июнь - Бачата	2026-07-09 21:45:03.229713
21	1cd61a50-ac32-4d0e-aec7-8e8ea33da051	5000.00	2023-06-15 14:00:00	Cash	t	Оплата за июнь - Бачата	2026-07-09 21:45:03.229713
22	ed4fc941-c991-42d5-96b4-24eb3e2fefab	6000.00	2023-07-01 15:00:00	Card	t	Оплата за июль - Джаз-модерн	2026-07-09 21:45:03.229713
23	5deb707e-a590-4194-aba4-e4c8f855c3c3	6500.00	2023-07-15 16:00:00	Online	t	Оплата за июль - Брейк-данс	2026-07-09 21:45:03.229713
24	a6aeb83c-e6ee-4363-aa5d-b6f35e6869a6	6000.00	2023-08-01 17:00:00	Card	t	Оплата за август - Контемпорари	2026-07-09 21:45:03.229713
\.


--
-- TOC entry 3390 (class 0 OID 280152)
-- Dependencies: 216
-- Data for Name: student_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_groups (student_id, group_id, enrollment_date, monthly_fee, is_active, created_at) FROM stdin;
bdef9a06-cffc-45fc-888f-50e025f7c22a	1	2023-01-10	5000.00	t	2026-07-09 21:44:51.549296
99d637a5-2692-4b8b-b9b5-a553f7f2afae	1	2023-01-15	5000.00	t	2026-07-09 21:44:51.549296
2a9f4a50-8c34-4c68-ba60-399c6ca25eec	1	2023-02-01	5000.00	t	2026-07-09 21:44:51.549296
065ddc65-b2b5-4f5e-8d71-cd7569c2e787	2	2023-02-15	4500.00	t	2026-07-09 21:44:51.549296
8548b6e5-23de-49fd-bb44-21f069164559	2	2023-03-01	4500.00	t	2026-07-09 21:44:51.549296
019b9387-9a77-4ed4-9d68-e916a5d80da3	2	2023-03-15	4500.00	t	2026-07-09 21:44:51.549296
76378c2a-32d6-4835-994c-72ecbcfe5b1b	3	2023-04-01	5500.00	t	2026-07-09 21:44:51.549296
d8dee414-5a10-4af9-a207-64368a0b219c	3	2023-04-15	5500.00	t	2026-07-09 21:44:51.549296
8f66c4f1-74d8-48fa-8356-ce07ef4d8238	3	2023-05-01	5500.00	t	2026-07-09 21:44:51.549296
06303b43-01ca-41ac-bbdb-ad99878003c1	4	2023-05-15	5000.00	t	2026-07-09 21:44:51.549296
87c524db-065b-4bdf-ae9d-29da6a39f00f	4	2023-06-01	5000.00	t	2026-07-09 21:44:51.549296
1cd61a50-ac32-4d0e-aec7-8e8ea33da051	4	2023-06-15	5000.00	t	2026-07-09 21:44:51.549296
ed4fc941-c991-42d5-96b4-24eb3e2fefab	5	2023-07-01	6000.00	t	2026-07-09 21:44:51.549296
5deb707e-a590-4194-aba4-e4c8f855c3c3	6	2023-07-15	6500.00	t	2026-07-09 21:44:51.549296
a6aeb83c-e6ee-4363-aa5d-b6f35e6869a6	7	2023-08-01	6000.00	t	2026-07-09 21:44:51.549296
bdef9a06-cffc-45fc-888f-50e025f7c22a	3	2023-02-15	5500.00	t	2026-07-09 21:44:51.549296
99d637a5-2692-4b8b-b9b5-a553f7f2afae	4	2023-03-01	5000.00	t	2026-07-09 21:44:51.549296
019b9387-9a77-4ed4-9d68-e916a5d80da3	3	2023-04-01	5500.00	t	2026-07-09 21:44:51.549296
2a9f4a50-8c34-4c68-ba60-399c6ca25eec	2	2023-05-01	4500.00	t	2026-07-09 21:44:51.549296
\.


--
-- TOC entry 3387 (class 0 OID 280120)
-- Dependencies: 213
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (student_id, first_name, last_name, email, phone, birth_date, registration_date, is_active, created_at) FROM stdin;
bdef9a06-cffc-45fc-888f-50e025f7c22a	Иван	Смирнов	ivan.smirnov@mail.ru	+7(900)111-11-11	2000-05-15	2023-01-10	t	2026-07-09 21:44:31.59811
99d637a5-2692-4b8b-b9b5-a553f7f2afae	Мария	Кузнецова	maria.kuz@mail.ru	+7(900)222-22-22	2001-08-20	2023-01-15	t	2026-07-09 21:44:31.59811
2a9f4a50-8c34-4c68-ba60-399c6ca25eec	Петр	Соколов	petr.sokol@yandex.ru	+7(900)333-33-33	1999-11-01	2023-02-01	t	2026-07-09 21:44:31.59811
065ddc65-b2b5-4f5e-8d71-cd7569c2e787	Анна	Попова	anna.popova@gmail.com	+7(900)444-44-44	2002-03-10	2023-02-15	t	2026-07-09 21:44:31.59811
8548b6e5-23de-49fd-bb44-21f069164559	Дмитрий	Лебедев	dmitry.lebedev@mail.ru	+7(900)555-55-55	2001-07-25	2023-03-01	t	2026-07-09 21:44:31.59811
019b9387-9a77-4ed4-9d68-e916a5d80da3	Елена	Новикова	elena.novikova@gmail.com	+7(900)666-66-66	2000-12-05	2023-03-15	t	2026-07-09 21:44:31.59811
76378c2a-32d6-4835-994c-72ecbcfe5b1b	Алексей	Морозов	alexey.morozov@yandex.ru	+7(900)777-77-77	1998-09-30	2023-04-01	t	2026-07-09 21:44:31.59811
d8dee414-5a10-4af9-a207-64368a0b219c	Ольга	Павлова	olga.pavlova@mail.ru	+7(900)888-88-88	2002-01-12	2023-04-15	t	2026-07-09 21:44:31.59811
8f66c4f1-74d8-48fa-8356-ce07ef4d8238	Сергей	Федоров	sergey.fedorov@gmail.com	+7(900)999-99-99	2001-06-08	2023-05-01	t	2026-07-09 21:44:31.59811
06303b43-01ca-41ac-bbdb-ad99878003c1	Татьяна	Михайлова	tatiana.mihailova@yandex.ru	+7(900)000-00-00	2000-10-18	2023-05-15	t	2026-07-09 21:44:31.59811
87c524db-065b-4bdf-ae9d-29da6a39f00f	Андрей	Соловьев	andrey.solovyev@mail.ru	+7(901)111-11-11	2003-03-22	2023-06-01	t	2026-07-09 21:44:31.59811
1cd61a50-ac32-4d0e-aec7-8e8ea33da051	Юлия	Васильева	yulia.vasilyeva@gmail.com	+7(901)222-22-22	2001-11-01	2023-06-15	t	2026-07-09 21:44:31.59811
ed4fc941-c991-42d5-96b4-24eb3e2fefab	Кирилл	Зайцев	kirill.zaytsev@yandex.ru	+7(901)333-33-33	1997-08-14	2023-07-01	t	2026-07-09 21:44:31.59811
5deb707e-a590-4194-aba4-e4c8f855c3c3	Ирина	Борисова	irina.borisova@mail.ru	+7(901)444-44-44	2002-04-09	2023-07-15	t	2026-07-09 21:44:31.59811
a6aeb83c-e6ee-4363-aa5d-b6f35e6869a6	Владимир	Григорьев	vladimir.grigoriev@gmail.com	+7(901)555-55-55	1999-12-25	2023-08-01	t	2026-07-09 21:44:31.59811
\.


--
-- TOC entry 3386 (class 0 OID 280110)
-- Dependencies: 212
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (teacher_id, first_name, last_name, email, phone, hire_date, is_active, created_at) FROM stdin;
1	Анна	Иванова	anna.i@dance.ru	+7(999)111-22-33	2020-01-15	t	2026-07-09 21:44:22.789675
2	Максим	Петров	maxim.p@dance.ru	+7(999)222-33-44	2020-03-10	t	2026-07-09 21:44:22.789675
3	Екатерина	Сидорова	ekaterina.s@dance.ru	+7(999)333-44-55	2021-06-01	t	2026-07-09 21:44:22.789675
4	Дмитрий	Козлов	dmitry.k@dance.ru	+7(999)444-55-66	2021-09-15	t	2026-07-09 21:44:22.789675
5	Ольга	Морозова	olga.m@dance.ru	+7(999)555-66-77	2022-01-20	t	2026-07-09 21:44:22.789675
6	Алексей	Волков	alexey.v@dance.ru	+7(999)666-77-88	2022-05-10	t	2026-07-09 21:44:22.789675
7	Марина	Павлова	marina.p@dance.ru	+7(999)777-88-99	2022-08-01	t	2026-07-09 21:44:22.789675
8	Сергей	Новиков	sergey.n@dance.ru	+7(999)888-99-00	2023-01-15	t	2026-07-09 21:44:22.789675
9	Наталья	Федорова	natalia.f@dance.ru	+7(999)999-00-11	2023-03-20	t	2026-07-09 21:44:22.789675
10	Андрей	Михайлов	andrey.m@dance.ru	+7(999)000-11-22	2023-06-01	t	2026-07-09 21:44:22.789675
\.


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 214
-- Name: groups_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_group_id_seq', 15, true);


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 217
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 24, true);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 211
-- Name: teachers_teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teachers_teacher_id_seq', 10, true);


--
-- TOC entry 3224 (class 2606 OID 280108)
-- Name: dance_styles dance_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dance_styles
    ADD CONSTRAINT dance_styles_pkey PRIMARY KEY (style_id);


--
-- TOC entry 3235 (class 2606 OID 280141)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- TOC entry 3239 (class 2606 OID 280184)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 3237 (class 2606 OID 280160)
-- Name: student_groups pk_student_groups; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_groups
    ADD CONSTRAINT pk_student_groups PRIMARY KEY (student_id, group_id);


--
-- TOC entry 3231 (class 2606 OID 280130)
-- Name: students students_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_email_key UNIQUE (email);


--
-- TOC entry 3233 (class 2606 OID 280128)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- TOC entry 3226 (class 2606 OID 280119)
-- Name: teachers teachers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_email_key UNIQUE (email);


--
-- TOC entry 3228 (class 2606 OID 280117)
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);


--
-- TOC entry 3229 (class 1259 OID 280190)
-- Name: idx_students_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_students_email ON public.students USING btree (email) WHERE (email IS NOT NULL);


--
-- TOC entry 3240 (class 2606 OID 280142)
-- Name: groups fk_groups_style; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_style FOREIGN KEY (style_id) REFERENCES public.dance_styles(style_id);


--
-- TOC entry 3241 (class 2606 OID 280147)
-- Name: groups fk_groups_teacher; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_teacher FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id);


--
-- TOC entry 3244 (class 2606 OID 280185)
-- Name: payments fk_payments_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- TOC entry 3242 (class 2606 OID 280166)
-- Name: student_groups fk_sg_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_groups
    ADD CONSTRAINT fk_sg_group FOREIGN KEY (group_id) REFERENCES public.groups(group_id);


--
-- TOC entry 3243 (class 2606 OID 280161)
-- Name: student_groups fk_sg_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_groups
    ADD CONSTRAINT fk_sg_student FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-07-09 22:05:25

--
-- PostgreSQL database dump complete
--

