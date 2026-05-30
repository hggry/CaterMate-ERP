--
-- PostgreSQL database dump
--

\restrict MOJtMcD2dMXYreJPgh6TqhTDjPAitjZ2COeouMc14RpOchJGavfK0627Ko8KwVa

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: konversationen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.konversationen (
    konversation_id text NOT NULL,
    state jsonb NOT NULL,
    status text,
    aktualisiert_am timestamp with time zone DEFAULT now(),
    CONSTRAINT konversationen_status_check CHECK ((status = ANY (ARRAY['chatting'::text, 'offer_sent'::text, 'offer_in_making'::text, 'offer_accepted'::text, 'offer_declined'::text])))
);


--
-- Data for Name: konversationen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.konversationen (konversation_id, state, status, aktualisiert_am) FROM stdin;
\.


--
-- Name: konversationen konversationen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.konversationen
    ADD CONSTRAINT konversationen_pkey PRIMARY KEY (konversation_id);


--
-- PostgreSQL database dump complete
--

\unrestrict MOJtMcD2dMXYreJPgh6TqhTDjPAitjZ2COeouMc14RpOchJGavfK0627Ko8KwVa

