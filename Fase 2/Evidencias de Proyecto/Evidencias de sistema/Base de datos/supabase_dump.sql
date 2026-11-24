-- TryAIGap Supabase public schema dump
-- Generated: 2026-11-24T18:35:50
-- Restore: psql <DATABASE_URL> -f supabase_dump.sql

SET client_min_messages = warning;

DROP TABLE IF EXISTS public."alembic_version" CASCADE;
CREATE TABLE public."alembic_version" (
  "version_num" character varying(32) NOT NULL,
  PRIMARY KEY ("version_num")
);

DROP TABLE IF EXISTS public."answers" CASCADE;
CREATE TABLE public."answers" (
  "assessment_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "value" smallint,
  "state" character varying(12) NOT NULL,
  "updated_by" uuid,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."area_states" CASCADE;
CREATE TABLE public."area_states" (
  "assessment_id" uuid NOT NULL,
  "area_key" character varying(20) NOT NULL,
  "active" boolean NOT NULL,
  "progress" smallint NOT NULL,
  "leader_member_id" uuid,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."assessments" CASCADE;
CREATE TABLE public."assessments" (
  "organization_id" uuid NOT NULL,
  "status" character varying(20) NOT NULL,
  "plan" character varying(10) NOT NULL,
  "started_at" timestamp with time zone,
  "completed_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."audit_logs" CASCADE;
CREATE TABLE public."audit_logs" (
  "actor_id" uuid,
  "action" character varying(80) NOT NULL,
  "resource_type" character varying(80),
  "resource_id" character varying(80),
  "details" json NOT NULL,
  "ip_address" character varying(45),
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."consultant_assignments" CASCADE;
CREATE TABLE public."consultant_assignments" (
  "organization_id" uuid NOT NULL,
  "consultant_id" uuid NOT NULL,
  "assigned_by" uuid,
  "status" character varying(12) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."consultant_notes" CASCADE;
CREATE TABLE public."consultant_notes" (
  "organization_id" uuid NOT NULL,
  "consultant_id" uuid,
  "body" text NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."consultant_ratings" CASCADE;
CREATE TABLE public."consultant_ratings" (
  "review_id" uuid NOT NULL,
  "chapter_key" character varying(40) NOT NULL,
  "knowledge" smallint NOT NULL,
  "friendliness" smallint NOT NULL,
  "methodology" smallint NOT NULL,
  "comments" text,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."delegations" CASCADE;
CREATE TABLE public."delegations" (
  "assessment_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "delegate_name" character varying(160) NOT NULL,
  "delegate_email" character varying(320) NOT NULL,
  "token_hash" character varying(128) NOT NULL,
  "status" character varying(12) NOT NULL,
  "expires_at" timestamp with time zone NOT NULL,
  "answered_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."distributor_codes" CASCADE;
CREATE TABLE public."distributor_codes" (
  "code" character varying(40) NOT NULL,
  "discount_pct" smallint NOT NULL,
  "active" boolean NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."documents" CASCADE;
CREATE TABLE public."documents" (
  "organization_id" uuid NOT NULL,
  "assessment_id" uuid,
  "question_id" uuid,
  "area_key" character varying(20),
  "filename" character varying(255) NOT NULL,
  "mime_type" character varying(120) NOT NULL,
  "size_bytes" integer NOT NULL,
  "storage_key" text NOT NULL,
  "uploaded_by" uuid,
  "deleted_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."invitations" CASCADE;
CREATE TABLE public."invitations" (
  "organization_id" uuid NOT NULL,
  "full_name" character varying(160) NOT NULL,
  "email" character varying(320) NOT NULL,
  "whatsapp" character varying(32),
  "phone" character varying(32),
  "area_key" character varying(20),
  "token_hash" character varying(128) NOT NULL,
  "status" character varying(12) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  "expires_at" timestamp with time zone,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."leads" CASCADE;
CREATE TABLE public."leads" (
  "full_name" character varying(160) NOT NULL,
  "job_title" character varying(120),
  "company_email" character varying(320) NOT NULL,
  "company_name" character varying(200) NOT NULL,
  "company_size" character varying(40),
  "industry" character varying(80),
  "country" character varying(80),
  "terms_accepted" boolean NOT NULL,
  "locale" character varying(2) NOT NULL,
  "user_id" uuid,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."magic_link_tokens" CASCADE;
CREATE TABLE public."magic_link_tokens" (
  "user_id" uuid NOT NULL,
  "token_hash" character varying(128) NOT NULL,
  "expires_at" timestamp with time zone NOT NULL,
  "used_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."org_members" CASCADE;
CREATE TABLE public."org_members" (
  "organization_id" uuid NOT NULL,
  "user_id" uuid,
  "role" character varying(20) NOT NULL,
  "area_key" character varying(20),
  "status" character varying(20) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."organizations" CASCADE;
CREATE TABLE public."organizations" (
  "name" character varying(200) NOT NULL,
  "sector" character varying(80),
  "size" character varying(40),
  "country" character varying(80),
  "currency" character varying(3) NOT NULL,
  "legal_name" character varying(200),
  "address" text,
  "tax_id" character varying(40),
  "logo_url" text,
  "doc_locale" character varying(2) NOT NULL,
  "theme" character varying(10) NOT NULL,
  "plan" character varying(10) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  "status" character varying(12) NOT NULL DEFAULT 'active'::character varying,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."payments" CASCADE;
CREATE TABLE public."payments" (
  "organization_id" uuid NOT NULL,
  "quote_id" uuid,
  "provider" character varying(20) NOT NULL,
  "provider_ref" character varying(160),
  "amount" numeric(12,2) NOT NULL,
  "currency" character varying(3) NOT NULL,
  "status" character varying(12) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  "proof_storage_key" text,
  "proof_filename" character varying(255),
  "reconciliation_status" character varying(12) NOT NULL DEFAULT 'pending'::character varying,
  "reconciled_at" timestamp with time zone,
  "reconciled_by" uuid,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."question_translations" CASCADE;
CREATE TABLE public."question_translations" (
  "question_id" uuid NOT NULL,
  "locale" character varying(2) NOT NULL,
  "text" text NOT NULL,
  "block_title" character varying(200),
  "id" uuid NOT NULL,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."questions" CASCADE;
CREATE TABLE public."questions" (
  "module" character varying(10) NOT NULL,
  "area_key" character varying(20),
  "block_id" character varying(4) NOT NULL,
  "code" character varying(8) NOT NULL,
  "position" smallint NOT NULL,
  "dimension" character varying(20),
  "id" uuid NOT NULL,
  "vector_type" character varying(30),
  "weight" smallint,
  "readiness" smallint,
  "status" character varying(12) NOT NULL DEFAULT 'published'::character varying,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."quotes" CASCADE;
CREATE TABLE public."quotes" (
  "organization_id" uuid NOT NULL,
  "base_price" numeric(12,2) NOT NULL,
  "areas" jsonb NOT NULL,
  "final_report" boolean NOT NULL,
  "distributor_code" character varying(40),
  "subtotal" numeric(12,2) NOT NULL,
  "discount" numeric(12,2) NOT NULL,
  "total" numeric(12,2) NOT NULL,
  "currency" character varying(3) NOT NULL,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."refresh_tokens" CASCADE;
CREATE TABLE public."refresh_tokens" (
  "user_id" uuid NOT NULL,
  "token_hash" character varying(128) NOT NULL,
  "expires_at" timestamp with time zone NOT NULL,
  "revoked_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."report_jobs" CASCADE;
CREATE TABLE public."report_jobs" (
  "assessment_id" uuid NOT NULL,
  "locale" character varying(2) NOT NULL,
  "status" character varying(12) NOT NULL,
  "storage_key" text,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."review_chapters" CASCADE;
CREATE TABLE public."review_chapters" (
  "review_id" uuid NOT NULL,
  "chapter_key" character varying(40) NOT NULL,
  "validated" boolean NOT NULL,
  "validator_id" uuid,
  "note" text,
  "validated_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."reviews" CASCADE;
CREATE TABLE public."reviews" (
  "assessment_id" uuid NOT NULL,
  "mode" character varying(10) NOT NULL,
  "stage" smallint NOT NULL,
  "consultant_id" uuid,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."users" CASCADE;
CREATE TABLE public."users" (
  "email" character varying(320) NOT NULL,
  "full_name" character varying(160),
  "role" character varying(20) NOT NULL,
  "locale" character varying(2) NOT NULL,
  "status" character varying(20) NOT NULL,
  "organization_id" uuid,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  "supabase_user_id" uuid,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS public."webhook_events" CASCADE;
CREATE TABLE public."webhook_events" (
  "provider" character varying(20) NOT NULL,
  "event_id" character varying(120) NOT NULL,
  "type" character varying(80),
  "processed_at" timestamp with time zone,
  "id" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

-- alembic_version: 1 rows
INSERT INTO public."alembic_version" ("version_num") VALUES ('8d5c6f2a1b40');

-- answers: 74 rows
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '97453540-1bf6-4216-b5f3-0a86f52c3054', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'c354df8c-d3a6-46ef-8445-d32024124f4c', '2026-11-22T22:41:12.675015+00:00', '2026-11-22T22:41:12.675015+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'bb6ad488-e837-4825-b3f7-23f0f5d9c076', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '4110e908-7c74-40ef-b677-fcf41b179ed1', '2026-11-22T22:41:13.643921+00:00', '2026-11-22T22:41:13.643921+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'f74f492a-f8b8-4d9a-a7b5-efce0d8dbc23', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'cd8415cf-802a-4862-96cb-00417677806b', '2026-11-22T22:41:14.577575+00:00', '2026-11-22T22:41:14.577575+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'b9651a0f-aa52-4c6e-8ad6-e60cdd2ad58e', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '65be1369-8783-4af3-aae9-4fdfabe81e7f', '2026-11-22T22:41:15.038051+00:00', '2026-11-22T22:41:15.038051+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'e85064f7-94ac-4c1b-bef1-c682102349a7', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '8f52c43d-aa4d-490c-a7c9-9a682ae0b483', '2026-11-22T22:41:19.232710+00:00', '2026-11-22T22:41:19.232710+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'e030c7d9-bb61-42e3-8ccc-04a3cbf18ed4', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'dcc46df6-e095-4731-8508-907b68b3ff8e', '2026-11-22T22:44:36.013244+00:00', '2026-11-22T22:44:36.013244+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '15ce479c-bb6a-4c3e-887e-92587f112c9f', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'cfa90c8d-7028-4223-b14e-8ac700174050', '2026-11-22T22:44:37.449550+00:00', '2026-11-22T22:44:37.449550+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'ee991588-9879-4dc7-9c21-f975882a1cc8', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'c8826dfa-aa8d-4c95-9822-a71149c0750a', '2026-11-22T22:44:38.382766+00:00', '2026-11-22T22:44:38.382766+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '1ceb2d31-b054-43b1-9a49-083960ab27de', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '5a4cbaa5-8692-4bc9-a8ee-8ef72cd77d59', '2026-11-22T22:44:39.142655+00:00', '2026-11-22T22:44:39.142655+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '7bd3992d-ae89-4d5b-829e-b4a360dcc438', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '9f220032-bbec-42e7-998c-ab8a81310419', '2026-11-22T22:44:43.899851+00:00', '2026-11-22T22:44:43.899851+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'cee9dc55-f425-40dd-b56e-79341378ff46', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '6f375826-d8a5-4472-aac5-6e81df6ff5fd', '2026-11-22T22:44:43.899851+00:00', '2026-11-22T22:44:43.899851+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '1483486c-023b-4041-992b-7df5fcb4cdf2', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '35eae36a-511d-483c-9379-cdb09c27fcef', '2026-11-22T22:44:43.899851+00:00', '2026-11-22T22:44:43.899851+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '3b78bef1-d0a2-48b0-8312-f4987e40fa7f', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'ead48bf3-7ef2-458e-84c3-9cc35ed190d0', '2026-11-22T22:44:43.899851+00:00', '2026-11-22T22:44:43.899851+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'c5ccb66b-af15-4861-a161-e023a8265912', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '98b5f2b2-2821-488c-a058-0c1e0804efec', '2026-11-22T22:44:48.146472+00:00', '2026-11-22T22:44:48.146472+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '72e9eb9a-b13a-4a50-9e04-2e126fc540d2', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '0aa3a496-0fd4-4722-9612-99524e7c36f5', '2026-11-22T22:44:48.146472+00:00', '2026-11-22T22:44:48.146472+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'd3e96ace-986f-4833-af13-33212bb776c5', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'f6a45a1b-0e93-4f76-a215-9ad22ea2abae', '2026-11-22T22:44:48.146472+00:00', '2026-11-22T22:44:48.146472+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '3c6b44f2-c848-40ac-a936-797c78157ddd', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '781a5a1e-2bd3-4b3a-bdd7-8d1ef77d7745', '2026-11-22T22:44:48.146472+00:00', '2026-11-22T22:44:48.146472+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '6fb31fa6-6164-47f2-b234-ba8824c2b2e9', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'f5390814-b607-4329-a101-77634f9e38a8', '2026-11-22T22:44:51.694949+00:00', '2026-11-22T22:44:51.694949+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '0c45751c-da9f-4f15-9cf5-9ceef2170441', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '0e131266-9b34-47c6-b1ea-760e860a976c', '2026-11-22T22:44:51.694949+00:00', '2026-11-22T22:44:51.694949+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '55d67477-55e8-410e-bbad-e43ff9aaa222', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '395d7e0b-5b58-48d5-870a-8f8f36f30218', '2026-11-22T22:44:51.694949+00:00', '2026-11-22T22:44:51.694949+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '0f4e09d3-8e0f-4eb3-8620-f7f07f1202a9', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '56635ace-3d9f-4fcb-b812-d8540efc7485', '2026-11-22T22:44:52.401658+00:00', '2026-11-22T22:44:52.401658+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'd2b562de-b5ce-405e-9ad1-c17865910f3e', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'ac4a5b48-56e8-4543-bd60-81505cc4a157', '2026-11-22T22:46:12.719261+00:00', '2026-11-22T22:46:12.719261+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'cbcee84a-6d89-48cb-9265-ddfe4eb1bc04', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '482ea15b-e8df-4e6e-a1d4-570f567f242b', '2026-11-22T22:46:12.719261+00:00', '2026-11-22T22:46:12.719261+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '685881d6-2dde-466b-a402-d028e736045f', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '4b9b9ecf-ca53-4733-86d7-aef3e45c4110', '2026-11-22T22:46:12.719261+00:00', '2026-11-22T22:46:12.719261+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '45b55f81-94fa-4c63-91c0-d88df0a1c8f0', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'e61e0ec6-5a6e-4f1b-bc27-69fa52bcaa84', '2026-11-22T22:46:16.429173+00:00', '2026-11-22T22:46:16.429173+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '076fe32e-1dbd-44e0-bcc4-ee064d656935', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '104673aa-c9e5-478c-a33f-f77a77b45ed9', '2026-11-22T22:46:16.429173+00:00', '2026-11-22T22:46:16.429173+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'ea444f24-9b9c-4212-b4d3-f658bcff232d', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'dcf5b719-d0b2-4b26-8e4e-77751b06f476', '2026-11-22T22:46:16.429173+00:00', '2026-11-22T22:46:16.429173+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'da26e8bb-d3f1-4b5e-8770-7a28d644ddf5', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '1b7c385d-bf2d-4d00-8e37-cfa88d9c9b49', '2026-11-22T22:46:16.429173+00:00', '2026-11-22T22:46:16.429173+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'a127c661-4f45-4bf3-86b4-8e5bd4edb378', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '6bc48545-407b-4d1c-8da5-81a908528040', '2026-11-22T22:46:20.122409+00:00', '2026-11-22T22:46:20.122409+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '513e6901-3496-4b10-b8da-22ae0ce63e00', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '831cd2ef-bdb7-4492-939c-2248cf911fce', '2026-11-22T22:46:20.122409+00:00', '2026-11-22T22:46:20.122409+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '57892957-0f73-447e-9af4-e43962e0cc9b', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'd1291622-5778-4f3c-8c7a-3365508f4fe2', '2026-11-22T22:46:20.122409+00:00', '2026-11-22T22:46:20.122409+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'f70908b7-b984-4462-9e71-e51877a0dcfa', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'f485393a-6e88-4626-9938-3ce2e6aea885', '2026-11-22T22:46:20.122409+00:00', '2026-11-22T22:46:20.122409+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '6de1e602-06dd-494a-8c57-facfa803763a', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '2167a383-dc4a-468e-8faf-d87b6cfbf53f', '2026-11-22T22:46:23.089056+00:00', '2026-11-22T22:46:23.089056+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'da2cf8ad-6f68-4769-af52-ab9392865423', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '3e566fd7-41ac-4b2e-9616-1eb07bc5ab92', '2026-11-22T22:46:23.089056+00:00', '2026-11-22T22:46:23.089056+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'd94910ac-67ea-4368-8ec1-ec0331cc3f75', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'c466a63b-a024-4bdd-b3f1-dac66a66ccfe', '2026-11-22T22:46:24.656348+00:00', '2026-11-22T22:46:24.656348+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'a9b34724-6ba6-4d8f-b521-f55eda11bf5e', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'de00fc4c-8d04-465c-9232-2b82b3025fb3', '2026-11-22T22:46:24.656348+00:00', '2026-11-22T22:46:24.656348+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'edcd5538-57f7-4311-a96a-a9cf47469ca6', 5, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '1f33b567-e840-486f-81c4-7e4c7e910bb0', '2026-11-22T22:47:30.235182+00:00', '2026-11-22T22:47:30.235182+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '89d75cc7-ff29-4dd7-990c-7e8c528daf24', 3, 'answered', '3405a689-5424-4b43-b2ea-6febdd7e83b0', 'ec5d7679-1ee0-49ba-841d-9ae9b274addc', '2026-11-22T22:47:37.123764+00:00', '2026-11-22T22:47:37.123764+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'e030c7d9-bb61-42e3-8ccc-04a3cbf18ed4', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '60fd412d-fca8-4a8f-b88c-1e25c55f5e5b', '2026-11-23T18:15:57.149034+00:00', '2026-11-23T18:15:57.149034+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '15ce479c-bb6a-4c3e-887e-92587f112c9f', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '12c063ab-5555-4daf-9199-9978990cdfda', '2026-11-23T18:15:58.177898+00:00', '2026-11-23T18:15:58.177898+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'ee991588-9879-4dc7-9c21-f975882a1cc8', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '486309a8-e761-443d-b8f0-d54a25fd4332', '2026-11-23T18:15:59.250283+00:00', '2026-11-23T18:15:59.250283+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '1ceb2d31-b054-43b1-9a49-083960ab27de', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'e663626d-cb3f-4457-b7a7-7f8364e29d4e', '2026-11-23T18:16:00.291678+00:00', '2026-11-23T18:16:00.291678+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '7bd3992d-ae89-4d5b-829e-b4a360dcc438', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '81b313a3-93f7-4390-9376-57739d10a6c2', '2026-11-23T18:16:07.794230+00:00', '2026-11-23T18:16:07.794230+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'cee9dc55-f425-40dd-b56e-79341378ff46', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'b793f92f-8ad8-4e75-be96-a84b9a160da9', '2026-11-23T18:16:08.700325+00:00', '2026-11-23T18:16:08.700325+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '1483486c-023b-4041-992b-7df5fcb4cdf2', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '0d9553d8-45fb-41cc-aca3-97ffa3621e41', '2026-11-23T18:16:09.581308+00:00', '2026-11-23T18:16:09.581308+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '3b78bef1-d0a2-48b0-8312-f4987e40fa7f', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '94b2abe2-4a08-4af5-869f-7441a2429797', '2026-11-23T18:16:09.992126+00:00', '2026-11-23T18:16:09.992126+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'c5ccb66b-af15-4861-a161-e023a8265912', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '2fa3c37f-ff20-4eb9-acf8-2f9d52c3cd68', '2026-11-23T18:16:16.335912+00:00', '2026-11-23T18:16:16.335912+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '72e9eb9a-b13a-4a50-9e04-2e126fc540d2', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '94cbf663-8cec-4da2-a66b-a171e85d1bae', '2026-11-23T18:16:17.403407+00:00', '2026-11-23T18:16:17.403407+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'd3e96ace-986f-4833-af13-33212bb776c5', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'b3ce5593-7d7f-4c90-b622-7892c5bb390d', '2026-11-23T18:16:18.358520+00:00', '2026-11-23T18:16:18.358520+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '3c6b44f2-c848-40ac-a936-797c78157ddd', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'e8b3863f-f380-4aab-aca2-c68089466ea9', '2026-11-23T18:16:20.128362+00:00', '2026-11-23T18:16:20.128362+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '6fb31fa6-6164-47f2-b234-ba8824c2b2e9', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '958e20d6-6f95-4579-8ee0-4b91ad1b4e59', '2026-11-23T18:16:23.111667+00:00', '2026-11-23T18:16:23.111667+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '0c45751c-da9f-4f15-9cf5-9ceef2170441', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '1916e89e-1ef5-4804-a38e-af4ff3f6e732', '2026-11-23T18:16:24.298395+00:00', '2026-11-23T18:16:24.298395+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '55d67477-55e8-410e-bbad-e43ff9aaa222', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '0debeefc-fc93-4ed8-a4f9-ee854ccb7aac', '2026-11-23T18:16:25.578099+00:00', '2026-11-23T18:16:25.578099+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '0f4e09d3-8e0f-4eb3-8620-f7f07f1202a9', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '21506e9f-0212-43dd-8bcd-65214cbbcada', '2026-11-23T18:16:26.308488+00:00', '2026-11-23T18:16:26.308488+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '97453540-1bf6-4216-b5f3-0a86f52c3054', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'f10d2323-a126-4c8f-88e8-b44e1ce5b929', '2026-11-23T18:16:41.551154+00:00', '2026-11-23T18:16:41.551154+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'bb6ad488-e837-4825-b3f7-23f0f5d9c076', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'dc11a943-8c85-49d6-bcf2-1f7347fd1977', '2026-11-23T18:16:43.061218+00:00', '2026-11-23T18:16:43.061218+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'f74f492a-f8b8-4d9a-a7b5-efce0d8dbc23', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '3cf51028-7003-4c00-9832-5ef138d6dca7', '2026-11-23T18:16:44.471166+00:00', '2026-11-23T18:16:44.471166+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'b9651a0f-aa52-4c6e-8ad6-e60cdd2ad58e', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '75462e80-8beb-403f-877b-163120069cdb', '2026-11-23T18:16:45.679823+00:00', '2026-11-23T18:16:45.679823+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'e85064f7-94ac-4c1b-bef1-c682102349a7', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'c6143ee4-e8ff-4bb8-adfe-12a96c8e5cd8', '2026-11-23T18:16:48.133511+00:00', '2026-11-23T18:16:48.133511+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'd2b562de-b5ce-405e-9ad1-c17865910f3e', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '68a56cf2-a512-4920-8f43-71fe5bd5056e', '2026-11-23T18:16:49.086050+00:00', '2026-11-23T18:16:49.086050+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'cbcee84a-6d89-48cb-9265-ddfe4eb1bc04', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'b12194ac-6c2d-487c-8c63-cac19e1c7c39', '2026-11-23T18:16:52.579642+00:00', '2026-11-23T18:16:52.579642+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '685881d6-2dde-466b-a402-d028e736045f', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '33199a59-5f0b-4d6a-89a1-e6c6ec4d3da3', '2026-11-23T18:16:53.477944+00:00', '2026-11-23T18:16:53.477944+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '45b55f81-94fa-4c63-91c0-d88df0a1c8f0', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'ac8dfee1-89c6-4881-8382-4b594b82c6d5', '2026-11-23T18:17:07.403640+00:00', '2026-11-23T18:17:07.403640+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '076fe32e-1dbd-44e0-bcc4-ee064d656935', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '5aa308e9-8949-488e-8a08-209b6b390ca0', '2026-11-23T18:17:08.637043+00:00', '2026-11-23T18:17:08.637043+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'ea444f24-9b9c-4212-b4d3-f658bcff232d', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'e0f11a77-f1e7-4994-b3f8-c3c38ed4a016', '2026-11-23T18:17:09.491022+00:00', '2026-11-23T18:17:09.491022+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'da26e8bb-d3f1-4b5e-8770-7a28d644ddf5', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'f0d41ea1-87b5-4932-ba06-e76438f77df8', '2026-11-23T18:17:10.042997+00:00', '2026-11-23T18:17:10.042997+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '513e6901-3496-4b10-b8da-22ae0ce63e00', 5, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '7e35a63c-fc4f-4a10-8311-c1d538844597', '2026-11-23T18:17:13.336681+00:00', '2026-11-23T18:17:13.336681+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'f70908b7-b984-4462-9e71-e51877a0dcfa', 2, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '135da077-f608-45db-83f0-ac1ab411d685', '2026-11-23T18:17:15.062128+00:00', '2026-11-23T18:17:15.062128+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'da2cf8ad-6f68-4769-af52-ab9392865423', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '8a8786fc-bb55-4957-800e-3654981911fc', '2026-11-23T18:17:18.704638+00:00', '2026-11-23T18:17:18.704638+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'a9b34724-6ba6-4d8f-b521-f55eda11bf5e', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '35ef5d45-9546-49a0-ae64-99b6bd90b2a8', '2026-11-23T18:17:20.417338+00:00', '2026-11-23T18:17:20.417338+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'a127c661-4f45-4bf3-86b4-8e5bd4edb378', 4, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '55809206-d7b7-45cd-8400-9bbcf23c5387', '2026-11-23T18:17:12.437262+00:00', '2026-11-23T18:17:12.437262+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '57892957-0f73-447e-9af4-e43962e0cc9b', 2, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '649e0154-70a7-4d24-8e45-b00c021dcf92', '2026-11-23T18:17:14.279890+00:00', '2026-11-23T18:17:14.279890+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '6de1e602-06dd-494a-8c57-facfa803763a', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '43d767a5-faf7-4e39-9637-79be98c8ce1e', '2026-11-23T18:17:17.647755+00:00', '2026-11-23T18:17:17.647755+00:00');
INSERT INTO public."answers" ("assessment_id", "question_id", "value", "state", "updated_by", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'd94910ac-67ea-4368-8ec1-ec0331cc3f75', 3, 'answered', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '343d4a54-d98e-4aba-bfbb-bf76b95a2412', '2026-11-23T18:17:19.818278+00:00', '2026-11-23T18:17:19.818278+00:00');

-- area_states: 14 rows
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'ventas', true, 0, NULL, '5042c672-5a47-4b75-b0a5-246c9d60427c', '2026-11-22T22:43:52.567104+00:00', '2026-11-22T22:43:52.567104+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'marketing', true, 0, NULL, '2fa44c78-c9b7-41e9-bc75-e17292ac0513', '2026-11-22T22:43:55.704502+00:00', '2026-11-22T22:43:55.704502+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'servicio', true, 0, NULL, '6c5a71be-635d-416a-9502-c261ed0556e8', '2026-11-22T22:43:58.501061+00:00', '2026-11-22T22:43:58.501061+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'operaciones', true, 0, NULL, '96d18181-8ee7-4612-9c0f-614e52cc4c72', '2026-11-22T22:44:02.311153+00:00', '2026-11-22T22:44:02.311153+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'rrhh', true, 0, NULL, '6de12414-b6f9-4ff4-813f-76f8881ef2f2', '2026-11-22T22:44:04.474672+00:00', '2026-11-22T22:44:04.474672+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'finanzas', true, 0, NULL, 'abce36dc-a1be-4f78-92fb-80c650841bad', '2026-11-22T22:44:06.667218+00:00', '2026-11-22T22:44:06.667218+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'legal', true, 0, NULL, '1874b084-7d57-4d15-9f9c-63e63d62a56f', '2026-11-22T22:44:08.856034+00:00', '2026-11-22T22:44:08.856034+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'ventas', true, 0, NULL, 'bc735471-baee-4a61-a2d3-d1bbe2e61412', '2026-11-23T18:14:54.980899+00:00', '2026-11-23T18:14:54.980899+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'marketing', true, 0, NULL, 'eca2a67a-dcc4-41f0-98a9-f56e31824c28', '2026-11-23T18:14:58.537967+00:00', '2026-11-23T18:14:58.537967+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'servicio', true, 0, NULL, 'aafe09c5-18b5-4ec6-b0f8-4526555fdbb5', '2026-11-23T18:15:01.269166+00:00', '2026-11-23T18:15:01.269166+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'rrhh', true, 0, NULL, 'ca7e4cf1-20b2-4f97-8952-f16656f83445', '2026-11-23T18:15:19.921009+00:00', '2026-11-23T18:15:19.921009+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'finanzas', true, 0, NULL, 'fc19a2f5-e391-4ae8-9085-9640acbd1b6e', '2026-11-23T18:15:22.710511+00:00', '2026-11-23T18:15:22.710511+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'operaciones', true, 0, NULL, 'fdd64b33-f571-40ca-a6ea-2543cd208526', '2026-11-23T18:15:25.413338+00:00', '2026-11-23T18:15:25.413338+00:00');
INSERT INTO public."area_states" ("assessment_id", "area_key", "active", "progress", "leader_member_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'legal', true, 0, NULL, '9c850fa3-d937-4564-8e17-2f41ff102929', '2026-11-23T18:15:27.836955+00:00', '2026-11-23T18:15:27.836955+00:00');

-- assessments: 4 rows
INSERT INTO public."assessments" ("organization_id", "status", "plan", "started_at", "completed_at", "id", "created_at", "updated_at") VALUES ('9868d530-f514-4c04-951a-5676b0965060', 'in_progress', 'free', '2026-11-20T20:55:52.803604+00:00', NULL, 'a101596f-d6e7-4b11-b7ba-cae90cc54914', '2026-11-20T20:55:52.401966+00:00', '2026-11-20T20:55:52.401966+00:00');
INSERT INTO public."assessments" ("organization_id", "status", "plan", "started_at", "completed_at", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 'in_progress', 'pro', '2026-11-22T22:40:40.713708+00:00', NULL, '322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', '2026-11-22T22:40:40.497537+00:00', '2026-11-22T22:43:40.770855+00:00');
INSERT INTO public."assessments" ("organization_id", "status", "plan", "started_at", "completed_at", "id", "created_at", "updated_at") VALUES ('47e59e0b-9d55-42bd-9b74-3adfabfd312b', 'in_progress', 'pro', '2026-11-23T18:12:39.170720+00:00', NULL, 'd8984ed6-2ee2-46a9-a4d4-6775b8da1d27', '2026-11-23T18:12:38.895565+00:00', '2026-11-23T18:14:45.031472+00:00');
INSERT INTO public."assessments" ("organization_id", "status", "plan", "started_at", "completed_at", "id", "created_at", "updated_at") VALUES ('f9f1bc10-9596-4060-ad20-2721b87ada42', 'in_progress', 'free', '2026-11-24T16:27:21.600352+00:00', NULL, '4aac9ae4-a3fe-4dbd-aeb4-fd6cfceeed58', '2026-11-24T16:27:21.082952+00:00', '2026-11-24T16:27:21.082952+00:00');

-- audit_logs: 11 rows
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'organization.created', 'organization', '77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '{}', NULL, '601091a0-8fc6-4fe9-ae7e-b0affb1a6726', '2026-11-22T22:40:40.956395+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'payment.checkout_created', 'payment', 'c77ea198-5f48-4000-ad4d-840de16d6b75', '{"amount": 500.0, "quote_id": "f0d5e55e-8112-4902-a9c2-7200a75d7b7d"}', NULL, 'd937c95e-9dad-4c67-bed3-a19b50cb9786', '2026-11-22T22:41:30.426377+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'payment.checkout_created', 'payment', '4e20f6ef-e734-4395-8f1c-94e4d6c5d8c1', '{"amount": 500.0, "quote_id": "5894a4b9-0067-47cc-b896-f3f7c2790ccd"}', NULL, '1de3a0f8-5b10-485e-b8ed-b7c20392e625', '2026-11-22T22:43:09.660243+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'payment.checkout_created', 'payment', 'cf2b0641-b7f7-446e-84e6-689804e06f71', '{"amount": 1550.0, "quote_id": "9c8a82cb-9e3c-4822-857b-17e8bc3b89b9"}', NULL, '79c213c4-c3eb-4bd9-be86-dcaf04df27ca', '2026-11-22T22:43:34.415277+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES (NULL, 'payment.webhook_succeeded', 'payment', 'cf2b0641-b7f7-446e-84e6-689804e06f71', '{"event_type": "checkout.session.completed"}', NULL, '1a60b46f-4201-4536-9ed8-19d42e488076', '2026-11-22T22:43:41.597691+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'payment.checkout_created', 'payment', '21ba370e-52c2-4bc3-a6ab-b3be09f07e16', '{"amount": 500.0, "quote_id": "db153131-2834-4cdf-8c12-78a24f1e5e69"}', NULL, 'e7de0252-e70f-4bfe-b196-b3574f4f5941', '2026-11-22T22:46:42.182906+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES (NULL, 'payment.webhook_succeeded', 'payment', '21ba370e-52c2-4bc3-a6ab-b3be09f07e16', '{"event_type": "checkout.session.completed"}', NULL, '4fbc239d-f9ab-4b45-b16a-b9091b748f27', '2026-11-22T22:47:14.343419+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('3405a689-5424-4b43-b2ea-6febdd7e83b0', 'payment.checkout_created', 'payment', 'd4070f89-c058-4903-a508-504a6daeabf1', '{"amount": 650.0, "quote_id": "0ac6997d-f1de-4f29-aa6d-fc4592a774fc"}', NULL, '54542050-1eea-4221-b149-b62ca248a04d', '2026-11-22T23:50:48.199850+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'organization.created', 'organization', '47e59e0b-9d55-42bd-9b74-3adfabfd312b', '{}', NULL, '916a5f17-33ac-447a-a81b-8ada094da9e8', '2026-11-23T18:12:39.418191+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES ('9e3e059b-53b0-4ca8-ba90-7d913013c8da', 'payment.checkout_created', 'payment', 'befd8674-a9af-467f-b478-bd2d22d6fca7', '{"amount": 1550.0, "quote_id": "970247d2-738a-43f4-afaf-70f92c1ca416"}', NULL, '180e5be3-4fec-48a9-bbdc-81a74e2f205c', '2026-11-23T18:14:33.982854+00:00');
INSERT INTO public."audit_logs" ("actor_id", "action", "resource_type", "resource_id", "details", "ip_address", "id", "created_at") VALUES (NULL, 'payment.webhook_succeeded', 'payment', 'befd8674-a9af-467f-b478-bd2d22d6fca7', '{"event_type": "checkout.session.completed"}', NULL, 'd8468612-435e-46f0-8c6a-7a2a2c23f96f', '2026-11-23T18:14:45.846758+00:00');

-- distributor_codes: 1 rows
INSERT INTO public."distributor_codes" ("code", "discount_pct", "active", "id", "created_at", "updated_at") VALUES ('ALLX-PARTNER-2026', 10, true, 'd6524ba4-0a68-4977-bc55-5ba9f10894bd', '2026-11-20T13:26:54.050477+00:00', '2026-11-20T13:26:54.050477+00:00');

-- leads: 2 rows
INSERT INTO public."leads" ("full_name", "job_title", "company_email", "company_name", "company_size", "industry", "country", "terms_accepted", "locale", "user_id", "id", "created_at", "updated_at") VALUES ('Fabrizio Test', NULL, 'fabrizio.render@tryaigap.com', 'TryAIGap Test Corp', NULL, NULL, NULL, true, 'es', '571f5aa9-1621-4c69-887f-598bcd7b6df9', '9ebeb96a-f868-4caf-aa36-e96b25089376', '2026-11-20T20:55:52.401966+00:00', '2026-11-20T20:55:52.401966+00:00');
INSERT INTO public."leads" ("full_name", "job_title", "company_email", "company_name", "company_size", "industry", "country", "terms_accepted", "locale", "user_id", "id", "created_at", "updated_at") VALUES ('Fabrizio Martinez QA Test', NULL, 'qa-eval-1795537638@duocuc.cl', 'QA Duoc UC Enterprise', '51-200', 'Tecnología', 'Chile', true, 'es', '806914d0-54ed-4bcd-9511-e3f6714de27f', '7c103efd-163e-4af3-b5cf-50d8d6c5b1af', '2026-11-24T16:27:21.082952+00:00', '2026-11-24T16:27:21.082952+00:00');

-- magic_link_tokens: 1 rows
INSERT INTO public."magic_link_tokens" ("user_id", "token_hash", "expires_at", "used_at", "id", "created_at", "updated_at") VALUES ('571f5aa9-1621-4c69-887f-598bcd7b6df9', 'df1e0e80254310da08efadc7b039717588c2492769c2fd714e6a9011ed331afa', '2026-11-20T21:11:23.803034+00:00', NULL, '63e7f1d2-6158-4726-a29f-3994ebb08f4b', '2026-11-20T20:56:23.714524+00:00', '2026-11-20T20:56:23.714524+00:00');

-- organizations: 4 rows
INSERT INTO public."organizations" ("name", "sector", "size", "country", "currency", "legal_name", "address", "tax_id", "logo_url", "doc_locale", "theme", "plan", "id", "created_at", "updated_at", "status") VALUES ('TryAIGap Test Corp', NULL, NULL, NULL, 'USD', NULL, NULL, NULL, NULL, 'es', 'light', 'free', '9868d530-f514-4c04-951a-5676b0965060', '2026-11-20T20:55:52.401966+00:00', '2026-11-20T20:55:52.401966+00:00', 'active');
INSERT INTO public."organizations" ("name", "sector", "size", "country", "currency", "legal_name", "address", "tax_id", "logo_url", "doc_locale", "theme", "plan", "id", "created_at", "updated_at", "status") VALUES ('Vault-Tec', 'Tecnología', '1000+', 'Estados Unidos', 'USD', NULL, NULL, NULL, NULL, 'es', 'light', 'pro', '77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '2026-11-22T22:40:40.497537+00:00', '2026-11-22T22:43:40.770855+00:00', 'active');
INSERT INTO public."organizations" ("name", "sector", "size", "country", "currency", "legal_name", "address", "tax_id", "logo_url", "doc_locale", "theme", "plan", "id", "created_at", "updated_at", "status") VALUES ('Matel', 'Comercio minorista', '11-50', 'Reino Unido', 'USD', NULL, NULL, NULL, NULL, 'es', 'light', 'pro', '47e59e0b-9d55-42bd-9b74-3adfabfd312b', '2026-11-23T18:12:38.895565+00:00', '2026-11-23T18:14:45.031472+00:00', 'active');
INSERT INTO public."organizations" ("name", "sector", "size", "country", "currency", "legal_name", "address", "tax_id", "logo_url", "doc_locale", "theme", "plan", "id", "created_at", "updated_at", "status") VALUES ('QA Duoc UC Enterprise', 'Tecnología', '51-200', 'Chile', 'USD', NULL, NULL, NULL, NULL, 'es', 'light', 'free', 'f9f1bc10-9596-4060-ad20-2721b87ada42', '2026-11-24T16:27:21.082952+00:00', '2026-11-24T16:27:21.082952+00:00', 'active');

-- payments: 6 rows
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 'f0d5e55e-8112-4902-a9c2-7200a75d7b7d', 'stripe', 'cs_mock_c77ea198-5f48-4000-ad4d-840de16d6b75', 500.00, 'USD', 'pending', 'c77ea198-5f48-4000-ad4d-840de16d6b75', '2026-11-22T22:41:29.784635+00:00', '2026-11-22T22:41:29.784635+00:00', NULL, NULL, 'pending', NULL, NULL);
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '5894a4b9-0067-47cc-b896-f3f7c2790ccd', 'stripe', 'cs_mock_4e20f6ef-e734-4395-8f1c-94e4d6c5d8c1', 500.00, 'USD', 'pending', '4e20f6ef-e734-4395-8f1c-94e4d6c5d8c1', '2026-11-22T22:43:09.263634+00:00', '2026-11-22T22:43:09.263634+00:00', NULL, NULL, 'pending', NULL, NULL);
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '9c8a82cb-9e3c-4822-857b-17e8bc3b89b9', 'stripe', 'cs_mock_cf2b0641-b7f7-446e-84e6-689804e06f71', 1550.00, 'USD', 'succeeded', 'cf2b0641-b7f7-446e-84e6-689804e06f71', '2026-11-22T22:43:33.756833+00:00', '2026-11-22T22:43:40.770855+00:00', NULL, NULL, 'pending', NULL, NULL);
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 'db153131-2834-4cdf-8c12-78a24f1e5e69', 'stripe', 'cs_mock_21ba370e-52c2-4bc3-a6ab-b3be09f07e16', 500.00, 'USD', 'succeeded', '21ba370e-52c2-4bc3-a6ab-b3be09f07e16', '2026-11-22T22:46:41.559148+00:00', '2026-11-22T22:47:13.662943+00:00', NULL, NULL, 'pending', NULL, NULL);
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '0ac6997d-f1de-4f29-aa6d-fc4592a774fc', 'stripe', 'cs_mock_d4070f89-c058-4903-a508-504a6daeabf1', 650.00, 'USD', 'pending', 'd4070f89-c058-4903-a508-504a6daeabf1', '2026-11-22T23:50:47.558598+00:00', '2026-11-22T23:50:47.558598+00:00', NULL, NULL, 'pending', NULL, NULL);
INSERT INTO public."payments" ("organization_id", "quote_id", "provider", "provider_ref", "amount", "currency", "status", "id", "created_at", "updated_at", "proof_storage_key", "proof_filename", "reconciliation_status", "reconciled_at", "reconciled_by") VALUES ('47e59e0b-9d55-42bd-9b74-3adfabfd312b', '970247d2-738a-43f4-afaf-70f92c1ca416', 'stripe', 'cs_mock_befd8674-a9af-467f-b478-bd2d22d6fca7', 1550.00, 'USD', 'succeeded', 'befd8674-a9af-467f-b478-bd2d22d6fca7', '2026-11-23T18:14:33.290856+00:00', '2026-11-23T18:14:45.031472+00:00', NULL, NULL, 'pending', NULL, NULL);

-- question_translations: 264 rows
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('97453540-1bf6-4216-b5f3-0a86f52c3054', 'es', '¿Mantienen un inventario actualizado de las fuentes de datos críticas, con responsables asignados?', 'Bloque A — Datos', '0d7e163b-73e1-411f-b45e-f42e270c0f30');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('97453540-1bf6-4216-b5f3-0a86f52c3054', 'en', 'Do you keep an up-to-date inventory of business-critical data sources, with named owners?', 'Block A — Data', 'dc834a48-1705-4c2d-909b-09774d443ac1');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bb6ad488-e837-4825-b3f7-23f0f5d9c076', 'es', '¿Miden y monitorean la calidad de los datos de forma continua, no solo en proyectos puntuales?', 'Bloque A — Datos', 'fa6ddabc-8f07-4caa-ad1b-8634632447b3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bb6ad488-e837-4825-b3f7-23f0f5d9c076', 'en', 'Do you measure and monitor data quality continuously, not just on specific projects?', 'Block A — Data', 'd9f45cd2-2188-46ef-b0fa-28a9feed8d21');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f74f492a-f8b8-4d9a-a7b5-efce0d8dbc23', 'es', '¿Existen políticas formales de privacidad, retención y residencia de datos, aplicadas y auditadas?', 'Bloque A — Datos', '45f8215d-85cd-4743-a2c5-de264027c8ba');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f74f492a-f8b8-4d9a-a7b5-efce0d8dbc23', 'en', 'Are there formal data privacy, retention and residency policies that are enforced and audited?', 'Block A — Data', 'd06e784e-966d-41be-8548-973bae3ab23f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b9651a0f-aa52-4c6e-8ad6-e60cdd2ad58e', 'es', '¿Hay un catálogo de datos donde un analista nuevo encuentra lo que necesita en minutos, no en semanas?', 'Bloque A — Datos', '87695cf3-8717-4fa6-bf07-6e77afc801b8');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b9651a0f-aa52-4c6e-8ad6-e60cdd2ad58e', 'en', 'Is there a data catalog where a new analyst finds what they need in minutes, not weeks?', 'Block A — Data', '151474dc-1011-4e80-abfb-eeeef02b03a0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e85064f7-94ac-4c1b-bef1-c682102349a7', 'es', '¿Tienen una plataforma estandarizada de analítica y modelado, o cada equipo arma la suya?', 'Bloque B — Tecnología', '75f21765-ae26-41ff-8c65-d57c7a242ad4');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e85064f7-94ac-4c1b-bef1-c682102349a7', 'en', 'Do you have a standardized analytics and modeling platform, or does each team set up its own?', 'Block B — Technology', '28d31b8f-2d04-4157-9685-fd91fb7faef3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d2b562de-b5ce-405e-9ad1-c17865910f3e', 'es', '¿Cuentan con capacidades de integración (APIs, eventos) para conectar nuevos servicios sin un proyecto especial?', 'Bloque B — Tecnología', '80a3f2e8-6893-4c31-802c-90ef6bbfec45');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d2b562de-b5ce-405e-9ad1-c17865910f3e', 'en', 'Do you have integration capabilities (APIs, events) to connect new services without a special project?', 'Block B — Technology', '51d9d97c-4274-475f-879f-b68afdd8aada');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cbcee84a-6d89-48cb-9265-ddfe4eb1bc04', 'es', '¿Practican MLOps o LLMOps en algún caso en producción (despliegue, monitoreo, reentrenamiento)?', 'Bloque B — Tecnología', '76d17b96-57a1-4c41-b315-f270c5af2ca0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cbcee84a-6d89-48cb-9265-ddfe4eb1bc04', 'en', 'Do you practice MLOps or LLMOps in any production case (deployment, monitoring, retraining)?', 'Block B — Technology', 'e3155fe4-c969-48a3-a7ff-aa3e5efa8390');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('685881d6-2dde-466b-a402-d028e736045f', 'es', '¿Las soluciones de IA actuales permiten reemplazar el modelo o proveedor sin rehacer todo?', 'Bloque B — Tecnología', 'c5990b01-3d61-471b-963b-239ad73f07a2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('685881d6-2dde-466b-a402-d028e736045f', 'en', 'Are current AI solutions designed so the model or vendor can be replaced without redoing everything?', 'Block B — Technology', '88d93eab-1fc2-4954-bf64-55e3dc7ebb45');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('45b55f81-94fa-4c63-91c0-d88df0a1c8f0', 'es', '¿Tienen perfiles internos de data science / ML / ingeniería de IA, o dependen solo de proveedores externos?', 'Bloque C — Talento', '3188d2e5-540b-4682-a61e-a8850c627a22');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('45b55f81-94fa-4c63-91c0-d88df0a1c8f0', 'en', 'Do you have in-house data science/ML/AI engineering profiles, or rely only on external vendors?', 'Block C — Talent', 'b3b43a72-4ae8-40fb-a0d2-5ebe746043e7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('076fe32e-1dbd-44e0-bcc4-ee064d656935', 'es', '¿Existe un plan formal de formación en IA por tipo de rol, y se está ejecutando?', 'Bloque C — Talento', '5190e586-c3a7-4049-8564-1a4a7936ff80');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('076fe32e-1dbd-44e0-bcc4-ee064d656935', 'en', 'Is there a formal AI training plan by role type, and is it being executed?', 'Block C — Talent', '3461f5aa-19d7-421b-999c-1c66028870c6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ea444f24-9b9c-4212-b4d3-f658bcff232d', 'es', '¿Los líderes de negocio entienden lo suficiente de IA para decidir sin delegar todo a TI?', 'Bloque C — Talento', '47091f95-be59-4f6a-a852-94c38c8720b0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ea444f24-9b9c-4212-b4d3-f658bcff232d', 'en', 'Do business leaders understand enough about AI to decide without delegating everything to IT?', 'Block C — Talent', '53ed4705-53cb-42d3-b38d-456193426726');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da26e8bb-d3f1-4b5e-8770-7a28d644ddf5', 'es', '¿Logran retener el talento técnico clave (no se va en el primer año por una mejor oferta)?', 'Bloque C — Talento', 'c25b3d57-c89f-4b85-af6c-2db4f90579cc');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da26e8bb-d3f1-4b5e-8770-7a28d644ddf5', 'en', 'Can you retain key technical talent (they don''t leave within the first year for a better offer)?', 'Block C — Talent', '955af861-36f2-46ad-b3da-d12b074946bf');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a127c661-4f45-4bf3-86b4-8e5bd4edb378', 'es', '¿Las iniciativas de IA pasan por un portafolio formal con priorización y revisión periódica?', 'Bloque D — Procesos', '7f7c5b47-f8e8-4030-96dc-6beb64f57dc8');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a127c661-4f45-4bf3-86b4-8e5bd4edb378', 'en', 'Do AI initiatives go through a formal portfolio with prioritization and periodic review?', 'Block D — Process', '63509e52-9cf0-46a5-b8da-07c33f3c998b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('513e6901-3496-4b10-b8da-22ae0ce63e00', 'es', '¿Hay quality gates documentados entre discovery, piloto, escala y operación?', 'Bloque D — Procesos', '50aab291-5f34-4169-9220-a11e755d2332');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('513e6901-3496-4b10-b8da-22ae0ce63e00', 'en', 'Are there documented quality gates between discovery, pilot, scaling and operation phases?', 'Block D — Process', '4bcf9edf-1412-4cb8-9ba3-17e199f39276');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('57892957-0f73-447e-9af4-e43962e0cc9b', 'es', '¿Existe un comité de IA que revisa periódicamente portafolio, riesgos y modelos en producción?', 'Bloque D — Procesos', '9bab01bc-9897-4bb6-bf07-68073ea445eb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('57892957-0f73-447e-9af4-e43962e0cc9b', 'en', 'Is there an AI committee that periodically reviews portfolio, risks and models in production?', 'Block D — Process', 'ade108aa-bdc8-41c1-8662-a45e8abe163d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f70908b7-b984-4462-9e71-e51877a0dcfa', 'es', '¿Toda solución en producción tiene responsable identificable, runbooks y plan de retiro?', 'Bloque D — Procesos', '1df1b132-a286-4865-9a55-8c34c4b584ac');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f70908b7-b984-4462-9e71-e51877a0dcfa', 'en', 'Does every production solution have an identifiable owner, runbooks and a retirement plan?', 'Block D — Process', '866aeef6-3b31-446e-978e-05a9f33e00eb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6de1e602-06dd-494a-8c57-facfa803763a', 'es', '¿Las decisiones importantes incorporan datos como insumo natural, no como esfuerzo extraordinario?', 'Bloque E — Cultura', 'a3bfd486-1de7-4801-8cb1-c4176cf6972d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6de1e602-06dd-494a-8c57-facfa803763a', 'en', 'Do important decisions incorporate data as a natural input, not as an extraordinary effort?', 'Block E — Culture', '0bdf79ca-e850-4b5a-b033-4ff2cfbabfe7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da2cf8ad-6f68-4769-af52-ab9392865423', 'es', '¿La organización tolera experimentos que pueden fallar sin penalizar a los responsables?', 'Bloque E — Cultura', 'b3860ddd-2c0e-4d9a-b217-89a07825e651');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da2cf8ad-6f68-4769-af52-ab9392865423', 'en', 'Does the organization tolerate experiments that may fail without penalizing those responsible?', 'Block E — Culture', '294bceb4-e954-41c6-a29b-5f9ce0dd1ac1');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d94910ac-67ea-4368-8ec1-ec0331cc3f75', 'es', '¿Hay confianza institucional para conducir con honestidad la conversación sobre el impacto de la IA en el empleo?', 'Bloque E — Cultura', '7c135bc3-3238-4c09-9af4-9622ee8087ee');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d94910ac-67ea-4368-8ec1-ec0331cc3f75', 'en', 'Is there institutional trust to honestly manage the conversation about AI''s impact on jobs?', 'Block E — Culture', '186da824-6634-4c26-9ae9-d909254c4312');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a9b34724-6ba6-4d8f-b521-f55eda11bf5e', 'es', '¿Los líderes ejecutivos modelan personalmente el uso de herramientas de IA, no solo lo predican?', 'Bloque E — Cultura', 'fb713b81-1339-4bcf-b1a4-269fd9356624');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a9b34724-6ba6-4d8f-b521-f55eda11bf5e', 'en', 'Do executive leaders personally model the use of AI tools, not just preach it?', 'Block E — Culture', '951ce5df-9e9e-4d02-bd9d-433e58e1ed71');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e030c7d9-bb61-42e3-8ccc-04a3cbf18ed4', 'es', 'El % de leads desperdiciados (sin contacto, mal calificados, sin seguimiento) es:', 'BLOQUE A — Pain comercial', '930fbb35-4414-426c-bf96-5e8d36ead4ed');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e030c7d9-bb61-42e3-8ccc-04a3cbf18ed4', 'en', 'The percentage of wasted leads (no contact, poorly qualified, no follow-up) is:', 'BLOCK A — Commercial Pain', '06c80263-534b-44ca-bd3d-40191d14c7ba');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('15ce479c-bb6a-4c3e-887e-92587f112c9f', 'es', 'El error de forecast comercial mensual / trimestral que tenemos hoy es:', 'BLOQUE A — Pain comercial', '22e64309-7a14-4a78-adac-35d57c52d15b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('15ce479c-bb6a-4c3e-887e-92587f112c9f', 'en', 'The monthly/quarterly business forecast error we have today is:', 'BLOCK A — Commercial Pain', '41ceeebb-38e5-4695-a4d5-f5cd6de6566c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ee991588-9879-4dc7-9c21-f975882a1cc8', 'es', 'El tiempo administrativo del rep (notas, CRM, propuestas) frente al tiempo con cliente es:', 'BLOQUE A — Pain comercial', '93985fb8-a89d-48e3-8368-0415a1c54d2d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ee991588-9879-4dc7-9c21-f975882a1cc8', 'en', 'The administrative time of the rep (notes, CRM, proposals) versus the time with the client is:', 'BLOCK A — Commercial Pain', 'de677ad4-1b38-4e06-9766-2617d04536ea');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1ceb2d31-b054-43b1-9a49-083960ab27de', 'es', 'La tasa de churn comercial / no-renovación de cuentas es:', 'BLOQUE A — Pain comercial', 'edec29d4-73fe-458b-9efc-2cf3efd9871f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1ceb2d31-b054-43b1-9a49-083960ab27de', 'en', 'The commercial churn/non-renewal rate is:', 'BLOCK A — Commercial Pain', '01c5c774-f19a-415f-a543-56fc1d7a5d8b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('7bd3992d-ae89-4d5b-829e-b4a360dcc438', 'es', 'Tenemos un CRM corporativo único con adopción mayor al 80% de los vendedores:', 'BLOQUE B — Readiness de datos comerciales', '6483787a-30a3-41c3-8584-9fd41c62de17');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('7bd3992d-ae89-4d5b-829e-b4a360dcc438', 'en', 'We have a unique corporate CRM with over 80% adoption by salespeople:', 'BLOCK B — Commercial Data Readiness', '19b10814-2afa-4778-8236-9af0337992d6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cee9dc55-f425-40dd-b56e-79341378ff46', 'es', 'Las actividades comerciales (llamadas, emails, reuniones) se registran sistemáticamente:', 'BLOQUE B — Readiness de datos comerciales', 'ac433d22-c6f9-4342-bf79-ef1b2c92858c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cee9dc55-f425-40dd-b56e-79341378ff46', 'en', 'Business activities (calls, emails, meetings) are systematically recorded:', 'BLOCK B — Commercial Data Readiness', '9cd607bb-0742-413f-a3a3-62b9adaf5131');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1483486c-023b-4041-992b-7df5fcb4cdf2', 'es', 'Tenemos histórico de al menos 12 meses de oportunidades con su outcome (ganada/perdida):', 'BLOQUE B — Readiness de datos comerciales', 'd60c8bfd-f622-4a48-9e7c-e3b37d2d5dda');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1483486c-023b-4041-992b-7df5fcb4cdf2', 'en', 'We have a history of at least 12 months of opportunities with their outcome (won/lost):', 'BLOCK B — Commercial Data Readiness', '2151d9a2-4cbc-45bd-abb3-1e77bd9889cd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3b78bef1-d0a2-48b0-8312-f4987e40fa7f', 'es', 'Las llamadas comerciales se graban / transcriben con consentimiento:', 'BLOQUE B — Readiness de datos comerciales', 'ad6ba4d6-f456-40cf-bbed-fa12da10bf7a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3b78bef1-d0a2-48b0-8312-f4987e40fa7f', 'en', 'Commercial calls are recorded/transcribed with consent:', 'BLOCK B — Commercial Data Readiness', '200ea6f3-9894-48a3-8971-c7117417f8b5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c5ccb66b-af15-4861-a161-e023a8265912', 'es', 'El VP/Director Comercial está abierto a incorporar IA y patrocina la iniciativa:', 'BLOQUE C — Readiness del equipo comercial', '20a52a4e-5937-4393-a413-4bfdc720a6de');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c5ccb66b-af15-4861-a161-e023a8265912', 'en', 'The VP/Commercial Director is open to incorporating AI and sponsors the initiative:', 'BLOCK C — Sales Team Readiness', '0a467271-b5f1-46d9-9f25-40fb940ca217');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('72e9eb9a-b13a-4a50-9e04-2e126fc540d2', 'es', 'Hay champions tecnológicos (RevOps, Sales Ops) en el equipo comercial:', 'BLOQUE C — Readiness del equipo comercial', '1b2d4410-61a8-4aed-b81c-c8407b288beb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('72e9eb9a-b13a-4a50-9e04-2e126fc540d2', 'en', 'There are technology champions (RevOps, Sales Ops) on the sales team:', 'BLOCK C — Sales Team Readiness', 'ba7c1287-39a4-444c-a6b7-645748803478');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d3e96ace-986f-4833-af13-33212bb776c5', 'es', 'Los reps aceptan herramientas digitales y cambian comportamiento si ven valor:', 'BLOQUE C — Readiness del equipo comercial', '2add827b-f216-4f83-8fb3-1f7bb59bc088');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d3e96ace-986f-4833-af13-33212bb776c5', 'en', 'Reps accept digital tools and change their behavior if they see value:', 'BLOCK C — Sales Team Readiness', '6edb2354-0313-4d06-bf64-c73974eedb37');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3c6b44f2-c848-40ac-a936-797c78157ddd', 'es', 'El equipo ha pasado por proyectos de transformación comercial con éxito razonable:', 'BLOQUE C — Readiness del equipo comercial', '9aaa0104-0765-4ad1-8dae-2cc473fc1e88');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3c6b44f2-c848-40ac-a936-797c78157ddd', 'en', 'The team has successfully completed business transformation projects:', 'BLOCK C — Sales Team Readiness', '3bef8be7-bae0-4da3-9a45-a1c82c42f38f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6fb31fa6-6164-47f2-b234-ba8824c2b2e9', 'es', 'Tenemos metas explícitas de win rate, productividad por rep, NRR o reducción de CAC:', 'BLOQUE D — Alineación estratégica', '1aa4178c-c1b8-4104-9675-64cdcb0a2d59');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6fb31fa6-6164-47f2-b234-ba8824c2b2e9', 'en', 'We have explicit goals for win rate, productivity per rep, NRR, or CAC reduction:', 'BLOCK D — Strategic Alignment', '05cd016c-2b2f-4da0-b766-c6c28114d82b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0c45751c-da9f-4f15-9cf5-9ceef2170441', 'es', 'Hay presupuesto razonable para invertir en revtech / IA en los próximos 12 meses:', 'BLOQUE D — Alineación estratégica', '2d428e1f-6074-4b2a-a591-9942623c926d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0c45751c-da9f-4f15-9cf5-9ceef2170441', 'en', 'There is a reasonable budget to invest in revtech/AI in the next 12 months:', 'BLOCK D — Strategic Alignment', '2b356a55-f563-46cc-9927-f55f07f521fc');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('55d67477-55e8-410e-bbad-e43ff9aaa222', 'es', 'La regulación aplicable nos permite usar IA con datos de prospects y clientes:', 'BLOQUE D — Alineación estratégica', '72de4c0d-a159-4289-86a8-bd9ed2fe5ba1');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('55d67477-55e8-410e-bbad-e43ff9aaa222', 'en', 'Applicable regulations allow us to use AI with prospect and customer data:', 'BLOCK D — Strategic Alignment', '63f59212-5293-4357-9dbd-437c5e7569e9');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0f4e09d3-8e0f-4eb3-8620-f7f07f1202a9', 'es', 'Existe un caso de negocio claro de impacto en revenue, margen o eficiencia comercial:', 'BLOQUE D — Alineación estratégica', '896b9013-f16f-4e34-9c6b-1ceacf3af586');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0f4e09d3-8e0f-4eb3-8620-f7f07f1202a9', 'en', 'There is a clear business case for impact on revenue, margin, or commercial efficiency:', 'BLOCK D — Strategic Alignment', 'e299431e-8f23-49d1-9f97-60571b7e78af');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e6c65e84-cf9e-4fa2-8302-4c3bf263e259', 'es', 'El % de leads inbound desperdiciados (sin contacto, mal calificados, sin nurturing) es:', 'Bloque A — Pain:', '9e7cddc9-fd4c-4152-abf1-c649ab6e81ba');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e6c65e84-cf9e-4fa2-8302-4c3bf263e259', 'en', 'El % de leads inbound desperdiciados (sin contacto, mal calificados, sin nurturing) es:', 'Bloque A — Pain:', 'c75964aa-2879-4ab8-a7f1-2aefc16cd011');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('9cf0f03a-17cc-4490-88c7-a8f8fe9ba15f', 'es', 'El tiempo y esfuerzo del equipo dedicado a producir contenido manualmente es:', 'Bloque A — Pain:', 'f9187b46-4484-409c-8c29-58ffd0d96677');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('9cf0f03a-17cc-4490-88c7-a8f8fe9ba15f', 'en', 'El tiempo y esfuerzo del equipo dedicado a producir contenido manualmente es:', 'Bloque A — Pain:', '6999b133-b1dc-4f0e-b5ec-90d8b836122f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f74c8161-66dd-4349-9a48-e42a53f16def', 'es', 'La presión de generar más leads cualificados (MQL/SQL) y más rápido es:', 'Bloque A — Pain:', '5140d096-0033-45f6-89b0-c20c7dc41281');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f74c8161-66dd-4349-9a48-e42a53f16def', 'en', 'La presión de generar más leads cualificados (MQL/SQL) y más rápido es:', 'Bloque A — Pain:', 'cad358d8-0327-41ea-971d-948d7352adcd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('567cd51a-202d-4447-868a-ebc2930a62ff', 'es', 'La inconsistencia de mensajes, branding y personalización a través de canales es:', 'Bloque A — Pain:', '8eede67f-cfbf-474b-a1e3-8c32542421c6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('567cd51a-202d-4447-868a-ebc2930a62ff', 'en', 'La inconsistencia de mensajes, branding y personalización a través de canales es:', 'Bloque A — Pain:', 'fe56f370-b8d6-4caa-b3fa-ae76236bb8ab');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('afff2c8e-8703-4d51-bc27-b5e7ff0a82b5', 'es', 'Tenemos un CRM corporativo único con histórico de 12+ meses de leads, cuentas y outcome:', 'Bloque B — Datos:', '939e5904-a47c-47c9-8547-92b2c02bf226');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('afff2c8e-8703-4d51-bc27-b5e7ff0a82b5', 'en', 'Tenemos un CRM corporativo único con histórico de 12+ meses de leads, cuentas y outcome:', 'Bloque B — Datos:', '316fc495-de80-4e59-8cf5-ee1b54a9ed19');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da15c07b-447b-4fdd-b555-546da0d497dc', 'es', 'Existe instrumentación adecuada del sitio web (eventos, formularios, tracking) y datos de comportamiento por contacto:', 'Bloque B — Datos:', 'b754e1c8-e600-4df2-88ee-5aec4fc1fe07');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('da15c07b-447b-4fdd-b555-546da0d497dc', 'en', 'Existe instrumentación adecuada del sitio web (eventos, formularios, tracking) y datos de comportamiento por contacto:', 'Bloque B — Datos:', '7547c6fd-e2cf-431c-a927-ce0c65f8778f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('86b7b08d-a305-415f-aec5-2135954fcc7d', 'es', 'Las plataformas de marketing automation, paid media y CRM están integradas (no aisladas):', 'Bloque B — Datos:', 'dfdab0f6-1f94-4aae-82b5-b029e28bd433');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('86b7b08d-a305-415f-aec5-2135954fcc7d', 'en', 'Las plataformas de marketing automation, paid media y CRM están integradas (no aisladas):', 'Bloque B — Datos:', '8ea5cc36-12dc-4222-b83a-ea24b91bd802');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('dcafd314-437d-4819-ae35-36ba35aa1460', 'es', 'Existe un ICP (Ideal Customer Profile) y modelo de segmentación documentado y operativo:', 'Bloque B — Datos:', '675e5313-12db-4482-b275-662b4f65d3df');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('dcafd314-437d-4819-ae35-36ba35aa1460', 'en', 'Existe un ICP (Ideal Customer Profile) y modelo de segmentación documentado y operativo:', 'Bloque B — Datos:', '491ad556-779a-463e-8ac5-cfbb82e667d7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('adfa8ee7-f538-46f5-a901-cccbd18e32bc', 'es', 'El liderazgo de marketing está abierto a incorporar IA y patrocina la iniciativa:', 'Bloque C — Equipo:', '03315c9f-49b6-46ce-8fec-48309ad0e59d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('adfa8ee7-f538-46f5-a901-cccbd18e32bc', 'en', 'El liderazgo de marketing está abierto a incorporar IA y patrocina la iniciativa:', 'Bloque C — Equipo:', '8d51d041-c0b4-4f6e-a459-73e689433bf1');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0d56911b-cb3b-44ef-adb2-077c4d1d0a41', 'es', 'Existen aliados naturales (champions tecnológicos / superusuarios) en el equipo:', 'Bloque C — Equipo:', '06b34db6-fceb-4e0f-a4d9-85176a37a703');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0d56911b-cb3b-44ef-adb2-077c4d1d0a41', 'en', 'Existen aliados naturales (champions tecnológicos / superusuarios) en el equipo:', 'Bloque C — Equipo:', '4347ceb6-c3c7-4828-a748-30966b2cff1a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('237e72f2-0fad-496a-814c-a9a709be1130', 'es', 'La cultura del equipo tolera contenido generado por IA con humano-en-el-bucle:', 'Bloque C — Equipo:', '6f808e15-81da-4c91-af7d-c73db3a75975');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('237e72f2-0fad-496a-814c-a9a709be1130', 'en', 'La cultura del equipo tolera contenido generado por IA con humano-en-el-bucle:', 'Bloque C — Equipo:', 'dc4644b4-4c90-4982-b030-180a712531c0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('acccae2b-5559-4c41-8cde-92228de2c738', 'es', 'El equipo ha pasado por proyectos de transformación o adopción tecnológica previos con resultados razonables:', 'Bloque C — Equipo:', 'd2dce954-475d-4b49-910d-a9485049c21b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('acccae2b-5559-4c41-8cde-92228de2c738', 'en', 'El equipo ha pasado por proyectos de transformación o adopción tecnológica previos con resultados razonables:', 'Bloque C — Equipo:', '7c7499d8-53e8-4751-b70a-118e6ec8d0cf');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('00dda0d7-776a-48b7-9b6d-2eee173047ab', 'es', 'Tenemos metas explícitas de aumentar pipeline / reducir CAC / acelerar ciclo comercial:', 'Bloque D — Estrategia:', 'c71d2951-5c67-4c3d-8188-319358a6df87');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('00dda0d7-776a-48b7-9b6d-2eee173047ab', 'en', 'Tenemos metas explícitas de aumentar pipeline / reducir CAC / acelerar ciclo comercial:', 'Bloque D — Estrategia:', 'b2901b90-8497-4b5f-8791-e5aca7a97833');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f4d5f7c3-d1fe-45f3-87fe-a14974c528b4', 'es', 'Hay presupuesto razonable para invertir en IA en marketing en los próximos 12 meses:', 'Bloque D — Estrategia:', '33484f60-ac0e-4654-8ad1-8f4fd053ceec');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f4d5f7c3-d1fe-45f3-87fe-a14974c528b4', 'en', 'Hay presupuesto razonable para invertir en IA en marketing en los próximos 12 meses:', 'Bloque D — Estrategia:', 'a3f7d934-44a8-40f5-8ba2-dbb18ce407b0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2879e03a-5b1c-45d7-a4bf-9a15936fb143', 'es', 'La regulación aplicable nos permite usar IA en comunicación con leads/clientes (LFPDPPP, GDPR, opt-in):', 'Bloque D — Estrategia:', 'e70f2e86-3fa9-4e82-a1c3-c9b4517b9146');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2879e03a-5b1c-45d7-a4bf-9a15936fb143', 'en', 'La regulación aplicable nos permite usar IA en comunicación con leads/clientes (LFPDPPP, GDPR, opt-in):', 'Bloque D — Estrategia:', '7b7609ca-89f1-4fa3-8b2d-523cd4e212ab');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a77f9f9d-9f59-4503-9738-fb2056066f97', 'es', 'Existe alineación con Ventas (SLAs, definiciones MQL/SQL, handoff) que sostiene la iniciativa:', 'Bloque D — Estrategia:', '3497d0e7-00ab-4c86-8fb6-3ef193d2f361');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a77f9f9d-9f59-4503-9738-fb2056066f97', 'en', 'Existe alineación con Ventas (SLAs, definiciones MQL/SQL, handoff) que sostiene la iniciativa:', 'Bloque D — Estrategia:', '0811e78d-9c05-4921-85dc-c3a2285ecaa9');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b03bf00e-f98d-49b6-8ec5-65ec6f92ed43', 'es', 'El volumen de tickets repetitivos que mis agentes resuelven varias veces al día es:', 'Bloque A — Pain operativo:', '7e09143b-6dba-4b1f-8c18-d9327c967002');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b03bf00e-f98d-49b6-8ec5-65ec6f92ed43', 'en', 'The volume of recurring tickets that my agents resolve multiple times a day is:', 'Block A — Operating Pain:', '15317b4c-480e-411a-b1a1-2d398308c2a8');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('85b4a5c0-c34f-42a1-8668-fb744a823a33', 'es', 'El tiempo promedio de manejo / resolución de un ticket que quisiéramos reducir es:', 'Bloque A — Pain operativo:', 'f8e0d832-2df9-4ad2-8a58-43f11b0841de');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('85b4a5c0-c34f-42a1-8668-fb744a823a33', 'en', 'The average handling/resolution time for a ticket that we would like to reduce is:', 'Block A — Operating Pain:', 'f9ecd633-4ddc-470e-8234-fb7a6faa1501');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bd666e16-ff40-4e8f-88d9-fc7b27ce11ce', 'es', 'El tiempo de espera o de respuesta que sufren nuestras cuentas hoy es:', 'Bloque A — Pain operativo:', '1649678b-8cf4-45a4-8139-68e3d2d3f76c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bd666e16-ff40-4e8f-88d9-fc7b27ce11ce', 'en', 'The waiting or response time that our accounts experience today is:', 'Block A — Operating Pain:', '0c1eb9de-a486-401e-946f-5d9742b8ec5c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('75712c54-21ab-46b2-a185-c4343d5ec7be', 'es', 'La tasa de escalamiento entre niveles de soporte (errores, re-trabajos, re-asignaciones) es:', 'Bloque A — Pain operativo:', '3393c0b6-e1b5-42f8-9b74-dfe011a36fcd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('75712c54-21ab-46b2-a185-c4343d5ec7be', 'en', 'The escalation rate between support levels (errors, rework, reassignments) is:', 'Block A — Operating Pain:', '95fa3dc3-b3c5-49cc-8100-8597667d350e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('639eab4f-b8d7-42a0-99b0-31cab0f063d5', 'es', 'Tenemos registros digitales completos de tickets/llamadas históricas (12+ meses):', 'Bloque B — Datos:', 'c8bd3f61-3274-455a-a886-5802a8a4d9e9');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('639eab4f-b8d7-42a0-99b0-31cab0f063d5', 'en', 'We have complete digital records of historical tickets/calls (12+ months):', 'Block B — Data:', 'f461ffdf-5664-4318-bba7-d24110cca18b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('de45652c-c9e4-48da-98a0-f85e20fe1ee0', 'es', 'Las llamadas y/o chats están grabadas o transcritas con calidad razonable:', 'Bloque B — Datos:', 'e0d7c63e-a800-42c2-ae84-0e5be6d132f0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('de45652c-c9e4-48da-98a0-f85e20fe1ee0', 'en', 'The calls and/or chats are recorded or transcribed with reasonable quality:', 'Block B — Data:', '303d6792-51e9-4d11-b9bf-cbc1f26d9589');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('61eb6ddb-60a9-4f8c-866b-a6572b3b2dbe', 'es', 'Existe una base de conocimiento técnica (KB) actualizada y accesible:', 'Bloque B — Datos:', 'e85ea9f8-4607-49ad-9116-d3edac2353ce');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('61eb6ddb-60a9-4f8c-866b-a6572b3b2dbe', 'en', 'There is an up-to-date and accessible technical knowledge base (KB):', 'Block B — Data:', '078c2202-0e29-487c-b8fc-ed3557b16ffb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('8817fe33-18b1-4859-a426-3705e6d2e5de', 'es', 'Los datos del área están integrados con CRM, ERP y otros sistemas relevantes:', 'Bloque B — Datos:', 'e3a7c6e1-ea06-4041-a0b9-3eef2f6eb6d5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('8817fe33-18b1-4859-a426-3705e6d2e5de', 'en', 'The data for this area is integrated with CRM, ERP, and other relevant systems:', 'Block B — Data:', 'cb77cf34-755b-40cd-bb45-41e8d6ed624f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b2c39bbd-508c-4c8c-8a98-f1843e2dd441', 'es', 'El liderazgo del área de servicio está abierto a incorporar IA y patrocina la iniciativa:', 'Bloque C — Equipo:', '90063976-cbc4-41be-8fe9-46f9e7665092');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b2c39bbd-508c-4c8c-8a98-f1843e2dd441', 'en', 'The service area leadership is open to incorporating AI and sponsors the initiative:', 'Block C — Team:', 'a667068c-a3c0-4870-b258-0bfa195f7ad3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e6dbf5d2-df45-4b8e-80d7-e691270bc8dd', 'es', 'Existen aliados naturales (champions tecnológicos / superusuarios) en el equipo:', 'Bloque C — Equipo:', 'c807c000-ec5b-4487-9dcf-45490fee4424');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e6dbf5d2-df45-4b8e-80d7-e691270bc8dd', 'en', 'There are natural allies (technological champions / superusers) on the team:', 'Block C — Team:', '0c3cb856-f26f-471c-b6c5-0192015fba16');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bd7e45cb-b004-44e1-bf1a-f645982c8e9a', 'es', 'La cultura del área tolera experimentos donde la IA puede equivocarse al inicio:', 'Bloque C — Equipo:', 'def11478-2890-40b9-a20b-c72aa160b49e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('bd7e45cb-b004-44e1-bf1a-f645982c8e9a', 'en', 'The culture in the area tolerates experiments where AI can make mistakes at the beginning:', 'Block C — Team:', 'd6302cdd-b71d-4a6e-a068-a551516e1fcf');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0e2da4a4-212d-498b-af0f-bf146c99822d', 'es', 'El equipo ha pasado por proyectos de transformación previos con resultados razonables:', 'Bloque C — Equipo:', '13f07719-3748-45cd-9598-324e4a6151c3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0e2da4a4-212d-498b-af0f-bf146c99822d', 'en', 'The team has gone through previous transformation projects with reasonable results:', 'Block C — Team:', 'd7c24469-b78d-4b29-a9f8-f451472bfe85');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('27d41648-1800-4c5d-81ae-1270aa27aacc', 'es', 'Tenemos metas explícitas de mejorar NPS / CSAT / retención o reducir costo de atención:', 'Bloque D — Estrategia:', '660ab723-2086-4c21-aa47-039ba044861b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('27d41648-1800-4c5d-81ae-1270aa27aacc', 'en', 'We have explicit goals to improve NPS / CSAT / retention or reduce the cost of care:', 'Block D — Strategy:', 'a4262476-3446-48de-9d49-acc179a2a452');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('62ec5384-12ce-47c1-b01a-1ca18b3027a1', 'es', 'Hay presupuesto razonable para invertir en IA en servicio al cliente en los próximos 12 meses:', 'Bloque D — Estrategia:', '74e5c1cc-5ea9-4406-a384-6bc5bf31ddf8');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('62ec5384-12ce-47c1-b01a-1ca18b3027a1', 'en', 'There is a reasonable budget to invest in AI for customer service in the next 12 months:', 'Block D — Strategy:', 'f5d0a9cd-4d1a-4ccb-ac4b-06916da8d81e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1c4854b6-e5a8-4ddd-b097-a5fc2a9d3091', 'es', 'La regulación aplicable nos permite usar IA en interacciones con cuentas/clientes:', 'Bloque D — Estrategia:', '14d32071-a8cc-4c58-aed1-a93a25139189');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1c4854b6-e5a8-4ddd-b097-a5fc2a9d3091', 'en', 'Applicable regulations allow us to use AI in interactions with accounts/customers:', 'Block D — Strategy:', 'c7d538c0-61a5-4166-bf85-e534fa4bcfc0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('4d8a6461-461b-4acf-893e-d412a4084eca', 'es', 'Existe un caso de negocio claro de impacto en costos, ingresos o experiencia:', 'Bloque D — Estrategia:', 'b6448368-32a9-4ed6-a57a-ea1d2cca7e19');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('4d8a6461-461b-4acf-893e-d412a4084eca', 'en', 'There is a clear business case for impact on costs, revenue, or experience:', 'Block D — Strategy:', 'eeee2662-c5b9-492c-872b-4a5859f74518');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e61747ef-b34c-4940-acee-035a356c56ce', 'es', 'El tiempo y los errores en el cierre contable mensual son un dolor importante:', 'Bloque A — Pain:', '21dbb16b-2caf-4161-bf2f-ca6c74d58695');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e61747ef-b34c-4940-acee-035a356c56ce', 'en', 'Time and errors in the monthly accounting close are a major pain:', 'Block A — Pain:', '3fae7c8f-6be9-4927-81a7-4177bb71effd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2050d87e-c634-461e-a79f-0e4fb6e5d4e6', 'es', 'Nuestro DSO / días de cobranza pendiente y el costo de capital de trabajo asociado son altos:', 'Bloque A — Pain:', '26c087a5-38a6-4d47-b4d9-552cf4c79559');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2050d87e-c634-461e-a79f-0e4fb6e5d4e6', 'en', 'Our DSO / days outstanding collection and associated working capital costs are high:', 'Block A — Pain:', '61cbb1d3-03ea-4348-b57e-423dd515ea2e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('82fb0c7e-bf63-45b2-8eb0-b94899c97d8a', 'es', 'El error en el forecast de cash flow / sorpresas de liquidez es relevante:', 'Bloque A — Pain:', '1a2f1ba2-97ea-4337-96b9-0e66cd289034');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('82fb0c7e-bf63-45b2-8eb0-b94899c97d8a', 'en', 'The error in the cash flow forecast / liquidity surprises is relevant:', 'Block A — Pain:', '059467c0-9dad-4969-bdae-f22bfbad9a21');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1fae063c-2145-466d-990b-e0e9b76701a6', 'es', 'El tiempo del equipo financiero en tareas manuales repetitivas (conciliaciones, reportes, categorización) es alto:', 'Bloque A — Pain:', '21567870-6515-4fed-a342-4fdce37c097e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1fae063c-2145-466d-990b-e0e9b76701a6', 'en', 'The time the finance team spends on repetitive manual tasks (reconciliations, reporting, categorization) is high:', 'Block A — Pain:', 'bf4aaec6-2fae-427e-959c-9b5e3567beca');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1778c715-5d72-489b-be50-a8d9b568d5cd', 'es', 'Tenemos un ERP / sistema contable corporativo único con histórico de 12+ meses:', 'Bloque B — Datos:', '77d652d5-f107-4823-acdf-004c468be159');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1778c715-5d72-489b-be50-a8d9b568d5cd', 'en', 'We have a unique corporate ERP/accounting system with a history of 12+ months:', 'Block B — Data:', 'c882adce-70bc-46b1-8e70-46e3500dbc1b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0519de3d-851f-460b-a24c-93ea36fee8be', 'es', 'Los datos bancarios y de transacciones están digitalizados, completos y trazables (extractos, AR, AP):', 'Bloque B — Datos:', 'b0d20eed-a0f1-4cb6-ace8-255f44b48f54');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0519de3d-851f-460b-a24c-93ea36fee8be', 'en', 'Banking and transaction data are digitized, complete and traceable (statements, AR, AP):', 'Block B — Data:', '355b53a1-5cca-49d5-ad2b-ad58e216f2d4');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b533a32e-0d6c-41e4-9390-ad133b2ea64e', 'es', 'El plan de cuentas, taxonomía de centros y políticas contables están estandarizados y documentados:', 'Bloque B — Datos:', '45e5ce9f-2074-44b3-8743-48efa8489309');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b533a32e-0d6c-41e4-9390-ad133b2ea64e', 'en', 'The chart of accounts, taxonomy of centers, and accounting policies are standardized and documented:', 'Block B — Data:', 'bcb89a67-f627-4c5d-9999-e6ebfe9cc056');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d5806625-5102-4b88-ab19-f64bcabebae0', 'es', 'Los datos están integrados ERP-banco-cobranza-presupuesto (no en silos ni Excel sueltos):', 'Bloque B — Datos:', 'd9d64440-a8fc-4d0c-96b6-42eca71258d0');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d5806625-5102-4b88-ab19-f64bcabebae0', 'en', 'The data is integrated across ERP, bank, collections, and budgeting systems (not in silos or separate Excel files):', 'Block B — Data:', '006b8bd9-53f8-4b36-a9d4-4d09f5183171');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('64534080-aae1-421b-a25a-ec872e2d008b', 'es', 'El liderazgo de finanzas (CFO, controller) está abierto a incorporar IA y patrocina la iniciativa:', 'Bloque C — Equipo:', 'ff224dd7-494d-40a8-8359-1aaede23807c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('64534080-aae1-421b-a25a-ec872e2d008b', 'en', 'Finance leadership (CFO, controller) is open to incorporating AI and sponsors the initiative:', 'Block C — Team:', '5c1a145d-90e3-472f-8798-38ac62851d02');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6063fe17-6c0f-401f-b8d4-d6723c78ebb5', 'es', 'Existen aliados naturales (champions tecnológicos / superusuarios) en el equipo financiero:', 'Bloque C — Equipo:', '5ab68b9f-a8a6-48eb-bd42-cb502a9a188f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6063fe17-6c0f-401f-b8d4-d6723c78ebb5', 'en', 'There are natural allies (technological champions / superusers) on the finance team:', 'Block C — Team:', '44ff898e-d963-4031-abdb-9c4dfe705ab4');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('fc545736-2ec9-45d7-a0cd-c1f58a5d6b6c', 'es', 'La cultura tolera IA con humano-en-el-bucle, especialmente en cifras que firma el CFO:', 'Bloque C — Equipo:', '3554542a-8f85-4e67-82b1-51cdb2d90d0f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('fc545736-2ec9-45d7-a0cd-c1f58a5d6b6c', 'en', 'The culture tolerates AI with a human-in-the-loop, especially on figures signed off by the CFO:', 'Block C — Team:', '658691a1-f30e-4183-a975-2bd96b66e945');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cb6dad4a-aeb5-434d-963a-e1e555821ed6', 'es', 'El equipo ha pasado por proyectos de digitalización financiera previos con resultados razonables:', 'Bloque C — Equipo:', '3ac2def3-c224-4773-afbb-64f8e86fa233');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cb6dad4a-aeb5-434d-963a-e1e555821ed6', 'en', 'The team has experience with previous financial digitization projects with reasonable results:', 'Block C — Team:', 'c1dcc9f9-dd79-49c5-8061-383767446ab2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d9179a4e-ebde-43bd-aa2d-aba4cc3197df', 'es', 'Tenemos metas explícitas: reducir DSO, mejorar accuracy de forecast, acelerar cierre, reducir errores:', 'Bloque D — Estrategia:', '8e552934-0a9c-4cac-bf9c-e109cf040ca4');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('d9179a4e-ebde-43bd-aa2d-aba4cc3197df', 'en', 'We have explicit goals: reduce DSO, improve forecast accuracy, accelerate closing times, reduce errors:', 'Block D — Strategy:', '4486b3b6-af2d-4520-9482-a6db4d5ded11');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e9e51183-630d-4e6e-a4b1-b0f2acca3b85', 'es', 'Hay presupuesto razonable para invertir en IA en finanzas en los próximos 12 meses:', 'Bloque D — Estrategia:', 'e7024b2a-c75d-42d9-b2e3-58035678034d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e9e51183-630d-4e6e-a4b1-b0f2acca3b85', 'en', 'There is a reasonable budget to invest in AI in finance in the next 12 months:', 'Block D — Strategy:', 'b944c89f-aae7-4910-a8d3-bf65b0bfe051');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('09d095c2-6217-4d43-8a87-14ebc0b97868', 'es', 'El compliance fiscal/contable está cubierto y el marco regulatorio (NIIF/IFRS, SAT/SII/DIAN, auditoría externa) está identificado:', 'Bloque D — Estrategia:', 'b2be4ae0-e0a5-4753-b8c9-f1460269a9eb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('09d095c2-6217-4d43-8a87-14ebc0b97868', 'en', 'Tax/accounting compliance is covered and the regulatory framework (IFRS, SAT/SII/DIAN, external audit) is identified:', 'Block D — Strategy:', '838a9b40-5a71-4ef3-a7bc-1df072e85d19');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0fac74ec-1138-4771-b0a5-bca69e0e3687', 'es', 'Hay alineación con CFO, comité de auditoría y board sobre prioridades de transformación financiera:', 'Bloque D — Estrategia:', '3cbab023-e329-4635-9d04-9dbada611650');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('0fac74ec-1138-4771-b0a5-bca69e0e3687', 'en', 'There is alignment with the CFO, audit committee, and board on financial transformation priorities:', 'Block D — Strategy:', 'd9c6a3ae-2eb3-4608-86ca-cc5a7ed59713');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c91a4583-703c-485c-a18d-de5c095fc6d3', 'es', 'El volumen de vacantes activas y el time-to-hire que sufrimos hoy es:', 'Bloque A — Pain:', '19628615-301e-48a2-b119-f154b1f66589');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c91a4583-703c-485c-a18d-de5c095fc6d3', 'en', 'The volume of active vacancies and the time-to-hire we are experiencing today is:', 'Block A — Pain:', '687886c1-56bd-4dcc-877a-d54076339028');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a90001bd-7b6d-4bcf-a853-2555648114b0', 'es', 'El tiempo administrativo del equipo de RRHH (publicar, screen, agendar, responder consultas) es:', 'Bloque A — Pain:', 'c79adb82-0d3e-4406-a427-c17b041ff24a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a90001bd-7b6d-4bcf-a853-2555648114b0', 'en', 'The administrative time of the HR team (posting, screen, scheduling, answering queries) is:', 'Block A — Pain:', '70ecebb1-2a0d-4dc2-9a2c-c067bc7ba24b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6c1c9643-3675-481d-88a1-a2cf730e8ffe', 'es', 'Nuestra tasa de rotación / pérdida de talento clave y el costo asociado es:', 'Bloque A — Pain:', 'a545fd3b-b234-46d6-8762-5ee5fda52c0e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6c1c9643-3675-481d-88a1-a2cf730e8ffe', 'en', 'Our turnover rate/loss of key talent and the associated cost is:', 'Block A — Pain:', '5ccc89be-69da-470c-b57a-306d7b866362');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a99139b1-694b-4be0-8f83-a86f2398111c', 'es', 'La inconsistencia entre descripciones de cargo, entrevistas y experiencia del empleado es:', 'Bloque A — Pain:', 'd78c128c-f11e-4b50-85b0-943665647b89');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('a99139b1-694b-4be0-8f83-a86f2398111c', 'en', 'The inconsistency between job descriptions, interviews, and employee experience is:', 'Block A — Pain:', '644743d0-e339-4563-82c5-0beb42073180');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('5c659a4c-490d-4a03-8f17-8499c1a2b7d3', 'es', 'Tenemos un ATS / sistema de reclutamiento corporativo único con histórico de 12+ meses:', 'Bloque B — Datos:', 'd3a2d607-e0d0-40e9-a9c2-3a20c9361d42');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('5c659a4c-490d-4a03-8f17-8499c1a2b7d3', 'en', 'We have a unique ATS / corporate recruiting system with a 12+ month history:', 'Block B — Data:', 'eb975cf2-eb9e-43ed-970b-25fe92e7b88c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ca002f78-bcc9-40c2-8d1d-5e56da4f5463', 'es', 'Tenemos un HRIS / sistema de nómina con datos de empleados actualizados y trazables:', 'Bloque B — Datos:', '0d65d663-cdad-4707-8f32-2d81d85377d5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ca002f78-bcc9-40c2-8d1d-5e56da4f5463', 'en', 'We have an HRIS/payroll system with up-to-date and traceable employee data:', 'Block B — Data:', 'a24829cd-f7d0-46ce-b07a-d0c2888a5355');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('83fc4f79-5248-4b93-9ee8-99d4e48e0213', 'es', 'Las políticas, manuales y procesos de RRHH están digitalizados, accesibles y vigentes:', 'Bloque B — Datos:', 'caf5009a-c6f4-4c00-81c1-6e7e74d31a75');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('83fc4f79-5248-4b93-9ee8-99d4e48e0213', 'en', 'HR policies, manuals, and processes are digitized, accessible, and up-to-date:', 'Block B — Data:', '261a156f-d559-4ed5-97e9-a3209088ec1c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ea0371c6-0ff5-4a2c-bd34-2d9ed4e2c029', 'es', 'Los datos de desempeño, clima y encuestas están digitalizados y son trazables a persona/equipo:', 'Bloque B — Datos:', 'c249d554-a0b8-4509-9ad7-120342fa5d4d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ea0371c6-0ff5-4a2c-bd34-2d9ed4e2c029', 'en', 'Performance, climate, and survey data are digitized and traceable to person/team:', 'Block B — Data:', '8c946819-affa-44d8-965f-bff3c5931fce');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('62adb645-b468-440b-9720-eb1dec46825f', 'es', 'El liderazgo de RRHH está abierto a incorporar IA y patrocina la iniciativa:', 'Bloque C — Equipo:', 'bb82e370-5e35-4c54-9798-69155af1196e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('62adb645-b468-440b-9720-eb1dec46825f', 'en', 'HR leadership is open to incorporating AI and sponsors the initiative:', 'Block C — Team:', '5c2f83b5-781f-4949-8439-637cf49076f5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('dcedca7b-d0c0-42c1-8ba8-0bcf605c9a0b', 'es', 'Existen aliados naturales (champions tecnológicos / superusuarios) en el equipo de RRHH:', 'Bloque C — Equipo:', 'b7db5de3-f882-4142-a3ee-a738dfdbe0bb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('dcedca7b-d0c0-42c1-8ba8-0bcf605c9a0b', 'en', 'There are natural allies (technological champions / superusers) in the HR team:', 'Block C — Team:', 'fca25c37-83ee-4fcf-8fd6-9d1dace002a6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('28a8ecc7-ccf2-43c3-9e67-21876ca6a844', 'es', 'La cultura tolera IA con humano-en-el-bucle, especialmente en decisiones que afectan personas:', 'Bloque C — Equipo:', '702ee394-8b84-44e5-b685-a354c28eeb92');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('28a8ecc7-ccf2-43c3-9e67-21876ca6a844', 'en', 'Culture tolerates AI with human-in-the-loop, especially in decisions that affect people:', 'Block C — Team:', '84bc9392-3862-41af-89e1-3160a357b8e3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3bf6ff20-9de5-4547-a516-b876b677c04d', 'es', 'El equipo ha pasado por proyectos de transformación o adopción tecnológica previos con resultados razonables:', 'Bloque C — Equipo:', 'eca6a85b-ae77-4e9a-b2b0-7a4b936dd969');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3bf6ff20-9de5-4547-a516-b876b677c04d', 'en', 'The team has undergone previous technological transformation or adoption projects with reasonable results:', 'Block C — Team:', '0f3135a5-fcfc-4ef9-9828-a22e08836729');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('97f8388d-eea6-454f-a960-cf3807c391ff', 'es', 'Tenemos metas explícitas: time-to-hire, cost-to-hire, retención, NPS empleado, movilidad interna:', 'Bloque D — Estrategia:', 'd10c0cfa-8ccd-4d60-bf8c-fec19f4bdd0a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('97f8388d-eea6-454f-a960-cf3807c391ff', 'en', 'We have explicit goals: time-to-hire, cost-to-hire, retention, employee NPS, internal mobility:', 'Block D — Strategy:', '368f89ca-ffb3-4be8-86b3-7eae87a04257');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('5f96ca91-8f32-4f95-9021-70f7fea9cca8', 'es', 'Hay presupuesto razonable para invertir en IA en RRHH en los próximos 12 meses:', 'Bloque D — Estrategia:', 'f1b31494-37cd-4d68-ba44-2b1e40ed4f38');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('5f96ca91-8f32-4f95-9021-70f7fea9cca8', 'en', 'There is a reasonable budget to invest in AI in HR in the next 12 months:', 'Block D — Strategy:', 'f2c94245-15d6-4cb7-8100-26cc99d7a981');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('64ba7692-f96d-4f5a-94e5-59d20408ca0f', 'es', 'El marco legal-laboral y de protección de datos personales (LFPDPPP, GDPR, EU AI Act, no discriminación) está identificado y manejado:', 'Bloque D — Estrategia:', 'a1437e15-d90b-421b-b9be-deb1575d9751');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('64ba7692-f96d-4f5a-94e5-59d20408ca0f', 'en', 'The legal framework for labor and personal data protection (LFPDPPP, GDPR, EU AI Act, non-discrimination) is identified and managed:', 'Block D — Strategy:', '19dc3396-0c82-4c4a-95d8-7397cc77a373');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c3fe5a06-5121-4406-a0a2-991bd1b6dae2', 'es', 'Hay alineación con líderes de negocio sobre necesidades de talento y prioridades de RRHH:', 'Bloque D — Estrategia:', '28ed4334-9ca6-4f85-a09e-f15ec2ce3a59');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c3fe5a06-5121-4406-a0a2-991bd1b6dae2', 'en', 'There is alignment with business leaders on talent needs and HR priorities:', 'Block D — Strategy:', '6bd39c5c-4561-44e2-999b-6120b229c1fe');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('edcd5538-57f7-4311-a96a-a9cf47469ca6', 'es', 'El volumen de paros no planificados (correctivos) en máquinas críticas que sufrimos es:', 'BLOQUE A — Pain operativo en planta', '13a6f444-2391-4858-b07b-75e6095c5455');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('edcd5538-57f7-4311-a96a-a9cf47469ca6', 'en', 'The volume of unplanned (corrective) downtime on critical machines that we experience is:', 'BLOCK A — Plant operating pain', 'c019f881-7a11-47a9-9c3d-51a937ac2365');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('89d75cc7-ff29-4dd7-990c-7e8c528daf24', 'es', 'La tasa de no-conformidades, scrap o retrabajos que tenemos hoy es:', 'BLOQUE A — Pain operativo en planta', 'a5277597-47ba-4dad-ab7f-1d1af885853e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('89d75cc7-ff29-4dd7-990c-7e8c528daf24', 'en', 'The rate of non-conformities, scrap, or rework we have today is:', 'BLOCK A — Plant operating pain', '5656baf0-14c6-444b-a48d-8e3bfdfae8c6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3d3dc10d-dcca-46c3-9d74-b16208ad2ecd', 'es', 'El error de pronóstico de demanda y la dificultad para planificar producción es:', 'BLOQUE A — Pain operativo en planta', 'afc719c3-668c-4cfc-acb6-213d9e5bdfb4');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('3d3dc10d-dcca-46c3-9d74-b16208ad2ecd', 'en', 'The demand forecasting error and the difficulty in production planning is:', 'BLOCK A — Plant operating pain', 'b388ccae-2939-44a3-b48d-924c8bf826b2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('39b963e9-16bc-441a-b365-e3735e2ffaef', 'es', 'La rotación / curva de aprendizaje de operadores y dependencia de operadores expertos es:', 'BLOQUE A — Pain operativo en planta', '7c3239de-096d-4149-ac97-3fbb88144938');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('39b963e9-16bc-441a-b365-e3735e2ffaef', 'en', 'The turnover/learning curve of operators and dependence on expert operators is:', 'BLOCK A — Plant operating pain', 'ca222ed3-19bb-40a5-9447-015dc7514ec3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('28614f3a-d0dc-4516-930e-13dd90b7b042', 'es', 'Las máquinas críticas tienen sensores básicos (vibración, temperatura, corriente, presión):', 'BLOQUE B — Readiness de datos operativos', 'b02cd593-4558-4b49-b54e-1e3c3b1f4624');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('28614f3a-d0dc-4516-930e-13dd90b7b042', 'en', 'Critical machines have basic sensors (vibration, temperature, current, pressure):', 'BLOCK B — Operational Data Readiness', 'c3de7559-b8a6-4288-8057-52040b36bbda');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('52724075-5b2f-4b0d-b2ff-203a24e2c45e', 'es', 'Tenemos histórico digital de al menos 12 meses de operación, calidad y mantenimiento:', 'BLOQUE B — Readiness de datos operativos', '7cd704ab-4754-4e42-9262-4462da481edd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('52724075-5b2f-4b0d-b2ff-203a24e2c45e', 'en', 'We have a digital history of at least 12 months of operation, quality, and maintenance:', 'BLOCK B — Operational Data Readiness', '7a8662f3-df25-41d5-81a8-63b3e5745407');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('9435d954-1036-44a9-a163-800398fc3f7f', 'es', 'Las recetas, procedimientos y registros de turno están digitalizados y accesibles:', 'BLOQUE B — Readiness de datos operativos', '4820ffe6-b8a1-4dd7-a5f4-1127b61c6a0a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('9435d954-1036-44a9-a163-800398fc3f7f', 'en', 'Recipes, procedures, and shift records are digitized and accessible:', 'BLOCK B — Operational Data Readiness', '8e0b70f4-741f-45d3-ae3c-98461c1784f2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cec5f074-77ff-4f5e-83af-e5c5711218d2', 'es', 'Existe alguna conexión / lectura de datos entre PLCs/SCADA y sistemas IT:', 'BLOQUE B — Readiness de datos operativos', 'ec50648b-5472-4294-a7f5-089c7f911c8d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('cec5f074-77ff-4f5e-83af-e5c5711218d2', 'en', 'Is there any connection/data reading between PLCs/SCADA and IT systems?', 'BLOCK B — Operational Data Readiness', '4caaf545-5abd-4f6c-bdb7-a723361a5358');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c1d7c3d8-ff1e-4f87-a76d-a468913cc97e', 'es', 'El Jefe de Planta / Director de Operaciones está abierto a incorporar IA y patrocina:', 'BLOQUE C — Readiness del equipo de planta', '08dda58f-f165-4e86-930a-8a794240913b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c1d7c3d8-ff1e-4f87-a76d-a468913cc97e', 'en', 'The Plant Manager / Operations Director is open to incorporating AI and sponsors:', 'BLOCK C — Plant Equipment Readiness', 'f9bb86b0-0545-4f2c-aabf-e4a84844b94d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2b43d0ca-835c-46d7-8c0b-f11561e329ff', 'es', 'Hay champions de transformación digital en mantenimiento, calidad o planificación:', 'BLOQUE C — Readiness del equipo de planta', 'f70c2361-9a31-4bf2-a62d-53b8087dc912');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('2b43d0ca-835c-46d7-8c0b-f11561e329ff', 'en', 'There are champions of digital transformation in maintenance, quality, or planning:', 'BLOCK C — Plant Equipment Readiness', 'f9b4db8d-543c-4e4a-9f8d-3ef9648ee311');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('32e373ee-47e6-4059-b605-c80f2cc1ef79', 'es', 'El equipo tiene cultura de mejora continua / lean / TPM en operación:', 'BLOQUE C — Readiness del equipo de planta', '90d86eb2-2159-4926-90a1-ed0713cb41e6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('32e373ee-47e6-4059-b605-c80f2cc1ef79', 'en', 'The team has a culture of continuous improvement / lean / TPM in operation:', 'BLOCK C — Plant Equipment Readiness', 'fb7d63f2-1764-4aff-83af-ea5c3674f2f7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f1d402f5-f94f-43e1-80b6-daa8a9d3d93c', 'es', 'Los operadores están abiertos a usar nuevas herramientas (tablets, apps, sensores):', 'BLOQUE C — Readiness del equipo de planta', '41f9e9f6-0b10-4245-a601-f91248234a9a');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f1d402f5-f94f-43e1-80b6-daa8a9d3d93c', 'en', 'Operators are open to using new tools (tablets, apps, sensors):', 'BLOCK C — Plant Equipment Readiness', '7d6329f4-b151-474a-b910-a03eb87b2669');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6e38d9df-f3f6-4af8-9038-3dff2c1385c7', 'es', 'Tenemos metas explícitas de OEE, scrap, productividad o reducción de costos operativos:', 'BLOQUE D — Alineación estratégica', 'caf6188b-9d0d-46a6-bb71-d469b9016556');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('6e38d9df-f3f6-4af8-9038-3dff2c1385c7', 'en', 'We have explicit goals for OEE, scrap, productivity, or reduction of operating costs:', 'BLOCK D — Strategic Alignment', '616d6196-80b1-48dc-b5fb-962c282615d2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('99f8f8ea-2119-48d9-8c02-302deb72babd', 'es', 'Hay presupuesto razonable para industria 4.0 / IA en planta en los próximos 12 meses:', 'BLOQUE D — Alineación estratégica', '7ad7e7e3-a16f-43e3-9f1d-bd146594e0e5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('99f8f8ea-2119-48d9-8c02-302deb72babd', 'en', 'There is a reasonable budget for Industry 4.0 / AI in the plant in the next 12 months:', 'BLOCK D — Strategic Alignment', 'df80539b-37ba-410c-b9f4-8ef91e367772');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('15ec12bf-3b5e-48c0-a3d3-ecc3602b662f', 'es', 'Existe apoyo de gerencia general / comité directivo para iniciativas de planta inteligente:', 'BLOQUE D — Alineación estratégica', '9665cb9e-9ffd-43e1-98bd-ed5256515fed');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('15ec12bf-3b5e-48c0-a3d3-ecc3602b662f', 'en', 'There is general management/steering committee support for smart plant initiatives:', 'BLOCK D — Strategic Alignment', 'bdae537d-914a-4e5a-9c0b-1cee1fac18e5');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('58789f06-8bee-42dc-8365-846d132756fe', 'es', 'Existe un caso de negocio claro de impacto en costos operativos o productividad:', 'BLOQUE D — Alineación estratégica', '9ee2e1de-39c4-49c3-8e88-21235120d48d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('58789f06-8bee-42dc-8365-846d132756fe', 'en', 'There is a clear business case for impact on operating costs or productivity:', 'BLOCK D — Strategic Alignment', '054a0dc0-d883-40a2-85d6-b02391501cdc');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f1ecccd9-6663-42f6-925b-ab96ac7150e9', 'es', 'El volumen de contratos / documentos legales que el equipo revisa manualmente cada mes es:', 'BLOQUE A — Pain operativo', '894042f9-9758-4307-97aa-39c99e93097c');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f1ecccd9-6663-42f6-925b-ab96ac7150e9', 'en', 'The volume of contracts/legal documents that the team manually reviews each month is:', 'BLOCK A — Operational Pain', 'e904de1c-a33b-43d9-9793-32092460d10b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('71b936f9-2c42-4daa-9081-cc61204f8775', 'es', 'El tiempo que invertimos en compliance manual y documentación regulatoria es:', 'BLOQUE A — Pain operativo', '57d71d5b-3799-470c-b058-53b222aebaee');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('71b936f9-2c42-4daa-9081-cc61204f8775', 'en', 'The time we invest in compliance manuals and regulatory documentation is:', 'BLOCK A — Operational Pain', '5c76fefc-ca55-4a8b-9869-544fdb3f0bbd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e32e3d67-b7ce-47c3-969b-841c2ea46ac4', 'es', 'La presión regulatoria actual (auditorías, fiscalizaciones, sanciones recientes) sobre nuestro sector es:', 'BLOQUE A — Pain operativo', '5438610d-2178-4999-bfde-89b061a4ae5d');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e32e3d67-b7ce-47c3-969b-841c2ea46ac4', 'en', 'The current regulatory pressure (audits, inspections, recent sanctions) on our sector is:', 'BLOCK A — Operational Pain', 'e72765eb-089d-45a9-94bf-66de1e8cfe6e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f8a04108-2dcc-431d-83fe-e921a6ab6d29', 'es', 'Nuestra tasa de errores u omisiones en documentación legal / compliance es:', 'BLOQUE A — Pain operativo', '4a8f06bd-e1fe-413c-994a-2f51cb2b08fd');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('f8a04108-2dcc-431d-83fe-e921a6ab6d29', 'en', 'Our error or omission rate in legal/compliance documentation is:', 'BLOCK A — Operational Pain', '80b7c1f6-690a-400a-9df9-e710110fdf4f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('fc793638-66e0-440c-8b00-8f288d21d325', 'es', 'Tenemos repositorio digital actualizado de contratos, políticas y documentación legal:', 'BLOQUE B — Readiness de datos', '28533105-9db8-4257-823d-7f6e5439c236');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('fc793638-66e0-440c-8b00-8f288d21d325', 'en', 'We have an updated digital repository of contracts, policies, and legal documentation:', 'BLOCK B — Data Readiness', 'abddc362-2fda-4838-b387-110573000620');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ff1727cf-1eca-465c-9f2e-a5c586e6e73e', 'es', 'La taxonomía/clasificación de documentos legales está definida y se aplica:', 'BLOQUE B — Readiness de datos', 'a26f5ef9-a436-4be2-999c-d639a2ffe5e6');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('ff1727cf-1eca-465c-9f2e-a5c586e6e73e', 'en', 'The taxonomy/classification of legal documents is defined and applied:', 'BLOCK B — Data Readiness', '1cec363f-9850-4522-afeb-903a4ee1b2eb');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('4bcfd96f-b181-4874-be38-44e299697516', 'es', 'Existe un sistema de gestión documental (DMS) con búsqueda y trazabilidad:', 'BLOQUE B — Readiness de datos', 'a5480f44-a4a4-425c-8125-69051f356776');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('4bcfd96f-b181-4874-be38-44e299697516', 'en', 'There is a document management system (DMS) with search and traceability:', 'BLOCK B — Data Readiness', 'da2b329f-0b5e-4be7-8d88-e687b1804621');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('894d3482-3fa3-46c1-91f8-a890bb6266d8', 'es', 'Los datos están integrados con sistemas de negocio (CRM, ERP, ticketing):', 'BLOQUE B — Readiness de datos', '101b21ce-1807-45f5-b4c8-509d32542ea8');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('894d3482-3fa3-46c1-91f8-a890bb6266d8', 'en', 'The data is integrated with business systems (CRM, ERP, ticketing):', 'BLOCK B — Data Readiness', 'a8176ed9-4a39-4d07-a3d6-3944da90bbee');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c604f7af-7c5c-455a-8930-abbd771f1d38', 'es', 'El General Counsel / liderazgo legal está abierto a incorporar IA y patrocina:', 'BLOQUE C — Readiness del equipo', '7bba923e-f169-43bc-b295-277109fcbce1');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c604f7af-7c5c-455a-8930-abbd771f1d38', 'en', 'The General Counsel/legal leadership is open to incorporating AI and sponsors:', 'BLOCK C — Team Readiness', '342a53a3-afe1-4a0b-ac33-100f2e1513c7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c6c3e97b-7524-454b-baf3-1bf743c2b84d', 'es', 'Hay perfiles legaltech o aliados naturales en el equipo:', 'BLOQUE C — Readiness del equipo', '0756041e-64e4-492b-837d-67a4f98b1fb7');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('c6c3e97b-7524-454b-baf3-1bf743c2b84d', 'en', 'There are legaltech profiles or natural allies on the team:', 'BLOCK C — Team Readiness', 'ec8a3103-4207-40f9-8336-0315984d91f2');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b941053a-c7fd-4686-a535-dae07019cd07', 'es', 'La cultura tolera experimentos donde la IA puede equivocarse al inicio:', 'BLOQUE C — Readiness del equipo', 'dbad89d2-51b5-4b06-85a9-170a0970042b');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('b941053a-c7fd-4686-a535-dae07019cd07', 'en', 'Culture tolerates experiments where AI can make mistakes at the beginning:', 'BLOCK C — Team Readiness', '729fbfc8-fdec-4101-97e4-ad92364b4856');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e7206ad5-5881-4a71-92f3-548d7c200553', 'es', 'El equipo ha pasado por proyectos de transformación previos con éxito razonable:', 'BLOQUE C — Readiness del equipo', 'fa34b044-85d8-496c-a563-661d3557306f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e7206ad5-5881-4a71-92f3-548d7c200553', 'en', 'The team has successfully completed previous transformation projects:', 'BLOCK C — Team Readiness', 'ddd507ef-7f24-473b-b78a-87d22eb04343');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1fbc631e-ea88-4df7-8b56-7eae7edc7da8', 'es', 'Tenemos metas explícitas de eficiencia legal, reducción de riesgo o velocidad de revisión:', 'BLOQUE D — Alineación estratégica', 'e764caad-bb8c-4a25-b705-ee9c4e2b29f3');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('1fbc631e-ea88-4df7-8b56-7eae7edc7da8', 'en', 'We have explicit goals for legal efficiency, risk reduction, or speed of review:', 'BLOCK D — Strategic Alignment', 'ebe2e199-598b-4f80-b666-18fa70addd85');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('08a73c29-d455-49ee-8913-249daec52306', 'es', 'Hay presupuesto razonable para invertir en legaltech / IA en los próximos 12 meses:', 'BLOQUE D — Alineación estratégica', '9ad875e3-3b94-442c-8e9f-9120b835445f');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('08a73c29-d455-49ee-8913-249daec52306', 'en', 'There is a reasonable budget to invest in legaltech/AI in the next 12 months:', 'BLOCK D — Strategic Alignment', 'e2811e0b-c853-40e0-973e-4ef875bb0bbe');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('960caa5d-4024-4296-b0e5-60617a4595c8', 'es', 'La regulación aplicable nos permite usar IA en revisión y procedimientos legales:', 'BLOQUE D — Alineación estratégica', 'bc0e4f75-ce6c-4b6e-ac72-fcd8099cc2cf');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('960caa5d-4024-4296-b0e5-60617a4595c8', 'en', 'Applicable regulations allow us to use AI in legal reviews and proceedings:', 'BLOCK D — Strategic Alignment', 'fee49015-33c7-48c4-83b2-08c131f65b8e');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e981a972-6c8f-49da-8e18-e2edd32686de', 'es', 'Existe un caso de negocio claro de impacto en costos, riesgos o tiempo:', 'BLOQUE D — Alineación estratégica', 'ef0f0957-fc7d-44e1-917a-5fae1d5b6031');
INSERT INTO public."question_translations" ("question_id", "locale", "text", "block_title", "id") VALUES ('e981a972-6c8f-49da-8e18-e2edd32686de', 'en', 'There is a clear business case for impact on costs, risks, or time:', 'BLOCK D — Strategic Alignment', '43276922-0da9-4a32-ab70-f4aed92debde');

-- questions: 132 rows
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'A', 'A1', 0, 'datos', '97453540-1bf6-4216-b5f3-0a86f52c3054', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'A', 'A2', 1, 'datos', 'bb6ad488-e837-4825-b3f7-23f0f5d9c076', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'A', 'A3', 2, 'datos', 'f74f492a-f8b8-4d9a-a7b5-efce0d8dbc23', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'A', 'A4', 3, 'datos', 'b9651a0f-aa52-4c6e-8ad6-e60cdd2ad58e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'B', 'B1', 4, 'tech', 'e85064f7-94ac-4c1b-bef1-c682102349a7', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'B', 'B2', 5, 'tech', 'd2b562de-b5ce-405e-9ad1-c17865910f3e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'B', 'B3', 6, 'tech', 'cbcee84a-6d89-48cb-9265-ddfe4eb1bc04', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'B', 'B4', 7, 'tech', '685881d6-2dde-466b-a402-d028e736045f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'C', 'C1', 8, 'talento', '45b55f81-94fa-4c63-91c0-d88df0a1c8f0', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'C', 'C2', 9, 'talento', '076fe32e-1dbd-44e0-bcc4-ee064d656935', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'C', 'C3', 10, 'talento', 'ea444f24-9b9c-4212-b4d3-f658bcff232d', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'C', 'C4', 11, 'talento', 'da26e8bb-d3f1-4b5e-8770-7a28d644ddf5', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'D', 'D1', 12, 'procesos', 'a127c661-4f45-4bf3-86b4-8e5bd4edb378', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'D', 'D2', 13, 'procesos', '513e6901-3496-4b10-b8da-22ae0ce63e00', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'D', 'D3', 14, 'procesos', '57892957-0f73-447e-9af4-e43962e0cc9b', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'D', 'D4', 15, 'procesos', 'f70908b7-b984-4462-9e71-e51877a0dcfa', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'E', 'E1', 16, 'cultura', '6de1e602-06dd-494a-8c57-facfa803763a', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'E', 'E2', 17, 'cultura', 'da2cf8ad-6f68-4769-af52-ab9392865423', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'E', 'E3', 18, 'cultura', 'd94910ac-67ea-4368-8ec1-ec0331cc3f75', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('maturity', NULL, 'E', 'E4', 19, 'cultura', 'a9b34724-6ba6-4d8f-b521-f55eda11bf5e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'A', 'A1', 1, NULL, 'e030c7d9-bb61-42e3-8ccc-04a3cbf18ed4', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'A', 'A2', 2, NULL, '15ce479c-bb6a-4c3e-887e-92587f112c9f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'A', 'A3', 3, NULL, 'ee991588-9879-4dc7-9c21-f975882a1cc8', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'A', 'A4', 4, NULL, '1ceb2d31-b054-43b1-9a49-083960ab27de', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'B', 'B1', 5, NULL, '7bd3992d-ae89-4d5b-829e-b4a360dcc438', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'B', 'B2', 6, NULL, 'cee9dc55-f425-40dd-b56e-79341378ff46', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'B', 'B3', 7, NULL, '1483486c-023b-4041-992b-7df5fcb4cdf2', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'B', 'B4', 8, NULL, '3b78bef1-d0a2-48b0-8312-f4987e40fa7f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'C', 'C1', 9, NULL, 'c5ccb66b-af15-4861-a161-e023a8265912', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'C', 'C2', 10, NULL, '72e9eb9a-b13a-4a50-9e04-2e126fc540d2', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'C', 'C3', 11, NULL, 'd3e96ace-986f-4833-af13-33212bb776c5', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'C', 'C4', 12, NULL, '3c6b44f2-c848-40ac-a936-797c78157ddd', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'D', 'D1', 13, NULL, '6fb31fa6-6164-47f2-b234-ba8824c2b2e9', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'D', 'D2', 14, NULL, '0c45751c-da9f-4f15-9cf5-9ceef2170441', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'D', 'D3', 15, NULL, '55d67477-55e8-410e-bbad-e43ff9aaa222', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'ventas', 'D', 'D4', 16, NULL, '0f4e09d3-8e0f-4eb3-8620-f7f07f1202a9', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'A', 'A1', 1, NULL, 'e6c65e84-cf9e-4fa2-8302-4c3bf263e259', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'A', 'A2', 2, NULL, '9cf0f03a-17cc-4490-88c7-a8f8fe9ba15f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'A', 'A3', 3, NULL, 'f74c8161-66dd-4349-9a48-e42a53f16def', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'A', 'A4', 4, NULL, '567cd51a-202d-4447-868a-ebc2930a62ff', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'B', 'B1', 5, NULL, 'afff2c8e-8703-4d51-bc27-b5e7ff0a82b5', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'B', 'B2', 6, NULL, 'da15c07b-447b-4fdd-b555-546da0d497dc', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'B', 'B3', 7, NULL, '86b7b08d-a305-415f-aec5-2135954fcc7d', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'B', 'B4', 8, NULL, 'dcafd314-437d-4819-ae35-36ba35aa1460', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'C', 'C1', 9, NULL, 'adfa8ee7-f538-46f5-a901-cccbd18e32bc', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'C', 'C2', 10, NULL, '0d56911b-cb3b-44ef-adb2-077c4d1d0a41', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'C', 'C3', 11, NULL, '237e72f2-0fad-496a-814c-a9a709be1130', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'C', 'C4', 12, NULL, 'acccae2b-5559-4c41-8cde-92228de2c738', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'D', 'D1', 13, NULL, '00dda0d7-776a-48b7-9b6d-2eee173047ab', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'D', 'D2', 14, NULL, 'f4d5f7c3-d1fe-45f3-87fe-a14974c528b4', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'D', 'D3', 15, NULL, '2879e03a-5b1c-45d7-a4bf-9a15936fb143', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'marketing', 'D', 'D4', 16, NULL, 'a77f9f9d-9f59-4503-9738-fb2056066f97', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'A', 'A1', 1, NULL, 'b03bf00e-f98d-49b6-8ec5-65ec6f92ed43', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'A', 'A2', 2, NULL, '85b4a5c0-c34f-42a1-8668-fb744a823a33', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'A', 'A3', 3, NULL, 'bd666e16-ff40-4e8f-88d9-fc7b27ce11ce', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'A', 'A4', 4, NULL, '75712c54-21ab-46b2-a185-c4343d5ec7be', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'B', 'B1', 5, NULL, '639eab4f-b8d7-42a0-99b0-31cab0f063d5', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'B', 'B2', 6, NULL, 'de45652c-c9e4-48da-98a0-f85e20fe1ee0', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'B', 'B3', 7, NULL, '61eb6ddb-60a9-4f8c-866b-a6572b3b2dbe', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'B', 'B4', 8, NULL, '8817fe33-18b1-4859-a426-3705e6d2e5de', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'C', 'C1', 9, NULL, 'b2c39bbd-508c-4c8c-8a98-f1843e2dd441', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'C', 'C2', 10, NULL, 'e6dbf5d2-df45-4b8e-80d7-e691270bc8dd', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'C', 'C3', 11, NULL, 'bd7e45cb-b004-44e1-bf1a-f645982c8e9a', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'C', 'C4', 12, NULL, '0e2da4a4-212d-498b-af0f-bf146c99822d', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'D', 'D1', 13, NULL, '27d41648-1800-4c5d-81ae-1270aa27aacc', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'D', 'D2', 14, NULL, '62ec5384-12ce-47c1-b01a-1ca18b3027a1', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'D', 'D3', 15, NULL, '1c4854b6-e5a8-4ddd-b097-a5fc2a9d3091', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'servicio', 'D', 'D4', 16, NULL, '4d8a6461-461b-4acf-893e-d412a4084eca', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'A', 'A1', 1, NULL, 'e61747ef-b34c-4940-acee-035a356c56ce', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'A', 'A2', 2, NULL, '2050d87e-c634-461e-a79f-0e4fb6e5d4e6', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'A', 'A3', 3, NULL, '82fb0c7e-bf63-45b2-8eb0-b94899c97d8a', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'A', 'A4', 4, NULL, '1fae063c-2145-466d-990b-e0e9b76701a6', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'B', 'B1', 5, NULL, '1778c715-5d72-489b-be50-a8d9b568d5cd', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'B', 'B2', 6, NULL, '0519de3d-851f-460b-a24c-93ea36fee8be', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'B', 'B3', 7, NULL, 'b533a32e-0d6c-41e4-9390-ad133b2ea64e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'B', 'B4', 8, NULL, 'd5806625-5102-4b88-ab19-f64bcabebae0', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'C', 'C1', 9, NULL, '64534080-aae1-421b-a25a-ec872e2d008b', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'C', 'C2', 10, NULL, '6063fe17-6c0f-401f-b8d4-d6723c78ebb5', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'C', 'C3', 11, NULL, 'fc545736-2ec9-45d7-a0cd-c1f58a5d6b6c', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'C', 'C4', 12, NULL, 'cb6dad4a-aeb5-434d-963a-e1e555821ed6', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'D', 'D1', 13, NULL, 'd9179a4e-ebde-43bd-aa2d-aba4cc3197df', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'D', 'D2', 14, NULL, 'e9e51183-630d-4e6e-a4b1-b0f2acca3b85', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'D', 'D3', 15, NULL, '09d095c2-6217-4d43-8a87-14ebc0b97868', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'finanzas', 'D', 'D4', 16, NULL, '0fac74ec-1138-4771-b0a5-bca69e0e3687', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'A', 'A1', 1, NULL, 'c91a4583-703c-485c-a18d-de5c095fc6d3', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'A', 'A2', 2, NULL, 'a90001bd-7b6d-4bcf-a853-2555648114b0', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'A', 'A3', 3, NULL, '6c1c9643-3675-481d-88a1-a2cf730e8ffe', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'A', 'A4', 4, NULL, 'a99139b1-694b-4be0-8f83-a86f2398111c', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'B', 'B1', 5, NULL, '5c659a4c-490d-4a03-8f17-8499c1a2b7d3', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'B', 'B2', 6, NULL, 'ca002f78-bcc9-40c2-8d1d-5e56da4f5463', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'B', 'B3', 7, NULL, '83fc4f79-5248-4b93-9ee8-99d4e48e0213', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'B', 'B4', 8, NULL, 'ea0371c6-0ff5-4a2c-bd34-2d9ed4e2c029', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'C', 'C1', 9, NULL, '62adb645-b468-440b-9720-eb1dec46825f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'C', 'C2', 10, NULL, 'dcedca7b-d0c0-42c1-8ba8-0bcf605c9a0b', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'C', 'C3', 11, NULL, '28a8ecc7-ccf2-43c3-9e67-21876ca6a844', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'C', 'C4', 12, NULL, '3bf6ff20-9de5-4547-a516-b876b677c04d', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'D', 'D1', 13, NULL, '97f8388d-eea6-454f-a960-cf3807c391ff', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'D', 'D2', 14, NULL, '5f96ca91-8f32-4f95-9021-70f7fea9cca8', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'D', 'D3', 15, NULL, '64ba7692-f96d-4f5a-94e5-59d20408ca0f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'rrhh', 'D', 'D4', 16, NULL, 'c3fe5a06-5121-4406-a0a2-991bd1b6dae2', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'A', 'A1', 1, NULL, 'edcd5538-57f7-4311-a96a-a9cf47469ca6', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'A', 'A2', 2, NULL, '89d75cc7-ff29-4dd7-990c-7e8c528daf24', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'A', 'A3', 3, NULL, '3d3dc10d-dcca-46c3-9d74-b16208ad2ecd', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'A', 'A4', 4, NULL, '39b963e9-16bc-441a-b365-e3735e2ffaef', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'B', 'B1', 5, NULL, '28614f3a-d0dc-4516-930e-13dd90b7b042', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'B', 'B2', 6, NULL, '52724075-5b2f-4b0d-b2ff-203a24e2c45e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'B', 'B3', 7, NULL, '9435d954-1036-44a9-a163-800398fc3f7f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'B', 'B4', 8, NULL, 'cec5f074-77ff-4f5e-83af-e5c5711218d2', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'C', 'C1', 9, NULL, 'c1d7c3d8-ff1e-4f87-a76d-a468913cc97e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'C', 'C2', 10, NULL, '2b43d0ca-835c-46d7-8c0b-f11561e329ff', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'C', 'C3', 11, NULL, '32e373ee-47e6-4059-b605-c80f2cc1ef79', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'C', 'C4', 12, NULL, 'f1d402f5-f94f-43e1-80b6-daa8a9d3d93c', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'D', 'D1', 13, NULL, '6e38d9df-f3f6-4af8-9038-3dff2c1385c7', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'D', 'D2', 14, NULL, '99f8f8ea-2119-48d9-8c02-302deb72babd', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'D', 'D3', 15, NULL, '15ec12bf-3b5e-48c0-a3d3-ecc3602b662f', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'operaciones', 'D', 'D4', 16, NULL, '58789f06-8bee-42dc-8365-846d132756fe', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'A', 'A1', 1, NULL, 'f1ecccd9-6663-42f6-925b-ab96ac7150e9', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'A', 'A2', 2, NULL, '71b936f9-2c42-4daa-9081-cc61204f8775', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'A', 'A3', 3, NULL, 'e32e3d67-b7ce-47c3-969b-841c2ea46ac4', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'A', 'A4', 4, NULL, 'f8a04108-2dcc-431d-83fe-e921a6ab6d29', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'B', 'B1', 5, NULL, 'fc793638-66e0-440c-8b00-8f288d21d325', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'B', 'B2', 6, NULL, 'ff1727cf-1eca-465c-9f2e-a5c586e6e73e', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'B', 'B3', 7, NULL, '4bcfd96f-b181-4874-be38-44e299697516', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'B', 'B4', 8, NULL, '894d3482-3fa3-46c1-91f8-a890bb6266d8', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'C', 'C1', 9, NULL, 'c604f7af-7c5c-455a-8930-abbd771f1d38', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'C', 'C2', 10, NULL, 'c6c3e97b-7524-454b-baf3-1bf743c2b84d', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'C', 'C3', 11, NULL, 'b941053a-c7fd-4686-a535-dae07019cd07', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'C', 'C4', 12, NULL, 'e7206ad5-5881-4a71-92f3-548d7c200553', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'D', 'D1', 13, NULL, '1fbc631e-ea88-4df7-8b56-7eae7edc7da8', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'D', 'D2', 14, NULL, '08a73c29-d455-49ee-8913-249daec52306', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'D', 'D3', 15, NULL, '960caa5d-4024-4296-b0e5-60617a4595c8', NULL, NULL, NULL, 'published');
INSERT INTO public."questions" ("module", "area_key", "block_id", "code", "position", "dimension", "id", "vector_type", "weight", "readiness", "status") VALUES ('area', 'legal', 'D', 'D4', 16, NULL, 'e981a972-6c8f-49da-8e18-e2edd32686de', NULL, NULL, NULL, 'published');

-- quotes: 6 rows
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 500.00, '[{"active": true, "review": false, "area_key": "ventas", "sessions": 0}, {"active": true, "review": false, "area_key": "finanzas", "sessions": 0}, {"active": true, "review": false, "area_key": "rrhh", "sessions": 0}]', false, NULL, 500.00, 0.00, 500.00, 'USD', 'f0d5e55e-8112-4902-a9c2-7200a75d7b7d', '2026-11-22T22:41:28.766653+00:00', '2026-11-22T22:41:28.766653+00:00');
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 500.00, '[]', false, NULL, 500.00, 0.00, 500.00, 'USD', '5894a4b9-0067-47cc-b896-f3f7c2790ccd', '2026-11-22T22:43:08.563232+00:00', '2026-11-22T22:43:08.563232+00:00');
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 500.00, '[{"active": true, "review": false, "area_key": "ventas", "sessions": 1}, {"active": true, "review": false, "area_key": "marketing", "sessions": 1}, {"active": true, "review": false, "area_key": "servicio", "sessions": 1}, {"active": true, "review": false, "area_key": "finanzas", "sessions": 1}, {"active": true, "review": false, "area_key": "rrhh", "sessions": 1}, {"active": true, "review": false, "area_key": "operaciones", "sessions": 1}, {"active": true, "review": false, "area_key": "legal", "sessions": 1}]', false, NULL, 1550.00, 0.00, 1550.00, 'USD', '9c8a82cb-9e3c-4822-857b-17e8bc3b89b9', '2026-11-22T22:43:32.992905+00:00', '2026-11-22T22:43:32.992905+00:00');
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 500.00, '[]', false, NULL, 500.00, 0.00, 500.00, 'USD', 'db153131-2834-4cdf-8c12-78a24f1e5e69', '2026-11-22T22:46:40.713472+00:00', '2026-11-22T22:46:40.713472+00:00');
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('77b78756-aaf9-4654-8bf2-e21a2b5eab0e', 500.00, '[{"active": true, "review": false, "area_key": "ventas", "sessions": 1}]', false, NULL, 650.00, 0.00, 650.00, 'USD', '0ac6997d-f1de-4f29-aa6d-fc4592a774fc', '2026-11-22T23:50:46.411402+00:00', '2026-11-22T23:50:46.411402+00:00');
INSERT INTO public."quotes" ("organization_id", "base_price", "areas", "final_report", "distributor_code", "subtotal", "discount", "total", "currency", "id", "created_at", "updated_at") VALUES ('47e59e0b-9d55-42bd-9b74-3adfabfd312b', 500.00, '[{"active": true, "review": false, "area_key": "ventas", "sessions": 1}, {"active": true, "review": false, "area_key": "marketing", "sessions": 1}, {"active": true, "review": false, "area_key": "servicio", "sessions": 1}, {"active": true, "review": false, "area_key": "finanzas", "sessions": 1}, {"active": true, "review": false, "area_key": "rrhh", "sessions": 1}, {"active": true, "review": false, "area_key": "operaciones", "sessions": 1}, {"active": true, "review": false, "area_key": "legal", "sessions": 1}]', false, NULL, 1550.00, 0.00, 1550.00, 'USD', '970247d2-738a-43f4-afaf-70f92c1ca416', '2026-11-23T18:14:32.254176+00:00', '2026-11-23T18:14:32.254176+00:00');

-- refresh_tokens: 2 rows
INSERT INTO public."refresh_tokens" ("user_id", "token_hash", "expires_at", "revoked_at", "id", "created_at", "updated_at") VALUES ('571f5aa9-1621-4c69-887f-598bcd7b6df9', 'e33a751c5be840b9882867f2883a9933a4d54c8529e6a48e0fa210e88e0a9ff8', '2026-12-20T20:55:53.044504+00:00', NULL, 'b8e7b510-11e6-44cc-bb76-b825cdf6afef', '2026-11-20T20:55:52.401966+00:00', '2026-11-20T20:55:52.401966+00:00');
INSERT INTO public."refresh_tokens" ("user_id", "token_hash", "expires_at", "revoked_at", "id", "created_at", "updated_at") VALUES ('806914d0-54ed-4bcd-9511-e3f6714de27f', 'df066f971176d7f2546151acc68f39e4e0b476373ea60ed564f344cdd933261c', '2026-12-24T16:27:21.899215+00:00', NULL, 'b6136a88-9434-41fe-8b12-0aa2284acee6', '2026-11-24T16:27:21.082952+00:00', '2026-11-24T16:27:21.082952+00:00');

-- reviews: 2 rows
INSERT INTO public."reviews" ("assessment_id", "mode", "stage", "consultant_id", "id", "created_at", "updated_at") VALUES ('322f8c50-8d68-40ce-a36c-ff8bbad3fbf2', 'sync', 1, NULL, '5f408ccc-44a4-4231-a07d-2d63ca16fc13', '2026-11-22T22:45:34.666247+00:00', '2026-11-22T22:45:34.666247+00:00');
INSERT INTO public."reviews" ("assessment_id", "mode", "stage", "consultant_id", "id", "created_at", "updated_at") VALUES ('d8984ed6-2ee2-46a9-a4d4-6775b8da1d27', 'sync', 1, NULL, '41adf62f-98c6-4b99-98ea-23cae3360f95', '2026-11-23T18:17:44.576112+00:00', '2026-11-23T18:17:44.576112+00:00');

-- users: 8 rows
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('matiaslopezramirez2001@gmail.com', NULL, 'admin', 'es', 'active', NULL, '3a97451a-d8e9-4ca2-aa67-10a20068eedb', '2026-11-20T14:58:31.568062+00:00', '2026-11-20T15:41:05.300266+00:00', '3a97451a-d8e9-4ca2-aa67-10a20068eedb');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('fabrizio.render@tryaigap.com', 'Fabrizio Test', 'client', 'es', 'active', '9868d530-f514-4c04-951a-5676b0965060', '571f5aa9-1621-4c69-887f-598bcd7b6df9', '2026-11-20T20:55:52.401966+00:00', '2026-11-20T20:55:52.401966+00:00', NULL);
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('mat.lopezr@duocuc.cl', NULL, 'admin', 'es', 'active', NULL, '9559170e-f032-45d6-b21e-ed4cf68b3024', '2026-11-20T21:12:31.396866+00:00', '2026-11-20T21:12:31.396866+00:00', '9559170e-f032-45d6-b21e-ed4cf68b3024');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('mati.gonzalezm@duocuc.cl', NULL, 'admin', 'es', 'active', NULL, '9c46c0cf-59f8-434e-b68d-a7bb5e329f38', '2026-11-22T21:26:54.330934+00:00', '2026-11-22T21:26:54.330934+00:00', '9c46c0cf-59f8-434e-b68d-a7bb5e329f38');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('fabr.martinez@duocuc.cl', NULL, 'admin', 'es', 'active', NULL, '61d07829-f103-4980-81b8-385c10dab2ec', '2026-11-22T21:26:54.633171+00:00', '2026-11-22T21:26:54.633171+00:00', '61d07829-f103-4980-81b8-385c10dab2ec');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('tiofelipens@gmail.com', NULL, 'client', 'es', 'active', '77b78756-aaf9-4654-8bf2-e21a2b5eab0e', '3405a689-5424-4b43-b2ea-6febdd7e83b0', '2026-11-22T22:40:21.929576+00:00', '2026-11-22T22:40:40.497537+00:00', '3405a689-5424-4b43-b2ea-6febdd7e83b0');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('sandra.b.manriquez@gmail.com', NULL, 'client', 'es', 'active', '47e59e0b-9d55-42bd-9b74-3adfabfd312b', '9e3e059b-53b0-4ca8-ba90-7d913013c8da', '2026-11-23T18:12:01.099580+00:00', '2026-11-23T18:12:38.895565+00:00', '9e3e059b-53b0-4ca8-ba90-7d913013c8da');
INSERT INTO public."users" ("email", "full_name", "role", "locale", "status", "organization_id", "id", "created_at", "updated_at", "supabase_user_id") VALUES ('qa-eval-1795537638@duocuc.cl', 'Fabrizio Martinez QA Test', 'client', 'es', 'active', 'f9f1bc10-9596-4060-ad20-2721b87ada42', '806914d0-54ed-4bcd-9511-e3f6714de27f', '2026-11-24T16:27:21.082952+00:00', '2026-11-24T16:27:21.082952+00:00', NULL);

-- webhook_events: 3 rows
INSERT INTO public."webhook_events" ("provider", "event_id", "type", "processed_at", "id", "created_at", "updated_at") VALUES ('stripe', 'evt_mock_cf2b0641-b7f7-446e-84e6-689804e06f71', 'checkout.session.completed', '2026-11-22T22:43:40.925001+00:00', '9acc4b79-0123-4fc1-8e44-00fcb941e554', '2026-11-22T22:43:40.770855+00:00', '2026-11-22T22:43:40.770855+00:00');
INSERT INTO public."webhook_events" ("provider", "event_id", "type", "processed_at", "id", "created_at", "updated_at") VALUES ('stripe', 'evt_mock_21ba370e-52c2-4bc3-a6ab-b3be09f07e16', 'checkout.session.completed', '2026-11-22T22:47:13.809641+00:00', '4de82b16-e91e-4b90-b8d1-2f9aba11fdc9', '2026-11-22T22:47:13.662943+00:00', '2026-11-22T22:47:13.662943+00:00');
INSERT INTO public."webhook_events" ("provider", "event_id", "type", "processed_at", "id", "created_at", "updated_at") VALUES ('stripe', 'evt_mock_befd8674-a9af-467f-b478-bd2d22d6fca7', 'checkout.session.completed', '2026-11-23T18:14:45.182658+00:00', '9bfd65e3-5614-45ad-a328-b66d26d530b4', '2026-11-23T18:14:45.031472+00:00', '2026-11-23T18:14:45.031472+00:00');

ALTER TABLE public."assessments" ADD CONSTRAINT "assessments_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."invitations" ADD CONSTRAINT "invitations_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."question_translations" ADD CONSTRAINT "question_translations_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE public."quotes" ADD CONSTRAINT "quotes_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."users" ADD CONSTRAINT "users_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE SET NULL;
ALTER TABLE public."reviews" ADD CONSTRAINT "reviews_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."answers" ADD CONSTRAINT "answers_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."answers" ADD CONSTRAINT "answers_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE public."answers" ADD CONSTRAINT "answers_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."consultant_notes" ADD CONSTRAINT "consultant_notes_consultant_id_fkey" FOREIGN KEY (consultant_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."consultant_notes" ADD CONSTRAINT "consultant_notes_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."delegations" ADD CONSTRAINT "delegations_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."delegations" ADD CONSTRAINT "delegations_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE public."documents" ADD CONSTRAINT "documents_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."documents" ADD CONSTRAINT "documents_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."documents" ADD CONSTRAINT "documents_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE SET NULL;
ALTER TABLE public."documents" ADD CONSTRAINT "documents_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."leads" ADD CONSTRAINT "leads_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."magic_link_tokens" ADD CONSTRAINT "magic_link_tokens_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public."org_members" ADD CONSTRAINT "org_members_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."org_members" ADD CONSTRAINT "org_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."payments" ADD CONSTRAINT "payments_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."payments" ADD CONSTRAINT "payments_quote_id_fkey" FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE SET NULL;
ALTER TABLE public."refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public."report_jobs" ADD CONSTRAINT "report_jobs_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."reviews" ADD CONSTRAINT "reviews_consultant_id_fkey" FOREIGN KEY (consultant_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."area_states" ADD CONSTRAINT "area_states_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE;
ALTER TABLE public."area_states" ADD CONSTRAINT "area_states_leader_member_id_fkey" FOREIGN KEY (leader_member_id) REFERENCES org_members(id) ON DELETE SET NULL;
ALTER TABLE public."consultant_ratings" ADD CONSTRAINT "consultant_ratings_review_id_fkey" FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE;
ALTER TABLE public."review_chapters" ADD CONSTRAINT "review_chapters_review_id_fkey" FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE;
ALTER TABLE public."review_chapters" ADD CONSTRAINT "review_chapters_validator_id_fkey" FOREIGN KEY (validator_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."payments" ADD CONSTRAINT "fk_payments_reconciled_by" FOREIGN KEY (reconciled_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."consultant_assignments" ADD CONSTRAINT "consultant_assignments_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
ALTER TABLE public."consultant_assignments" ADD CONSTRAINT "consultant_assignments_consultant_id_fkey" FOREIGN KEY (consultant_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public."consultant_assignments" ADD CONSTRAINT "consultant_assignments_assigned_by_fkey" FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public."audit_logs" ADD CONSTRAINT "audit_logs_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL;

CREATE UNIQUE INDEX alembic_version_pkc ON public.alembic_version USING btree (version_num);
CREATE UNIQUE INDEX answers_pkey ON public.answers USING btree (id);
CREATE UNIQUE INDEX area_states_pkey ON public.area_states USING btree (id);
CREATE UNIQUE INDEX assessments_pkey ON public.assessments USING btree (id);
CREATE UNIQUE INDEX audit_logs_pkey ON public.audit_logs USING btree (id);
CREATE UNIQUE INDEX consultant_assignments_pkey ON public.consultant_assignments USING btree (id);
CREATE UNIQUE INDEX consultant_notes_pkey ON public.consultant_notes USING btree (id);
CREATE UNIQUE INDEX consultant_ratings_pkey ON public.consultant_ratings USING btree (id);
CREATE UNIQUE INDEX delegations_pkey ON public.delegations USING btree (id);
CREATE UNIQUE INDEX distributor_codes_pkey ON public.distributor_codes USING btree (id);
CREATE UNIQUE INDEX documents_pkey ON public.documents USING btree (id);
CREATE UNIQUE INDEX invitations_pkey ON public.invitations USING btree (id);
CREATE INDEX ix_delegations_token_hash ON public.delegations USING btree (token_hash);
CREATE UNIQUE INDEX ix_distributor_codes_code ON public.distributor_codes USING btree (code);
CREATE INDEX ix_invitations_token_hash ON public.invitations USING btree (token_hash);
CREATE INDEX ix_leads_company_email ON public.leads USING btree (company_email);
CREATE INDEX ix_magic_link_tokens_token_hash ON public.magic_link_tokens USING btree (token_hash);
CREATE INDEX ix_payments_provider_ref ON public.payments USING btree (provider_ref);
CREATE INDEX ix_refresh_tokens_token_hash ON public.refresh_tokens USING btree (token_hash);
CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);
CREATE UNIQUE INDEX ix_users_supabase_user_id ON public.users USING btree (supabase_user_id);
CREATE UNIQUE INDEX ix_webhook_events_event_id ON public.webhook_events USING btree (event_id);
CREATE UNIQUE INDEX leads_pkey ON public.leads USING btree (id);
CREATE UNIQUE INDEX magic_link_tokens_pkey ON public.magic_link_tokens USING btree (id);
CREATE UNIQUE INDEX org_members_pkey ON public.org_members USING btree (id);
CREATE UNIQUE INDEX organizations_pkey ON public.organizations USING btree (id);
CREATE UNIQUE INDEX payments_pkey ON public.payments USING btree (id);
CREATE UNIQUE INDEX question_translations_pkey ON public.question_translations USING btree (id);
CREATE UNIQUE INDEX questions_pkey ON public.questions USING btree (id);
CREATE UNIQUE INDEX quotes_pkey ON public.quotes USING btree (id);
CREATE UNIQUE INDEX refresh_tokens_pkey ON public.refresh_tokens USING btree (id);
CREATE UNIQUE INDEX report_jobs_pkey ON public.report_jobs USING btree (id);
CREATE UNIQUE INDEX review_chapters_pkey ON public.review_chapters USING btree (id);
CREATE UNIQUE INDEX reviews_pkey ON public.reviews USING btree (id);
CREATE UNIQUE INDEX uq_answer ON public.answers USING btree (assessment_id, question_id);
CREATE UNIQUE INDEX uq_area_state ON public.area_states USING btree (assessment_id, area_key);
CREATE UNIQUE INDEX uq_consultant_assignment ON public.consultant_assignments USING btree (organization_id, consultant_id);
CREATE UNIQUE INDEX uq_qtrans ON public.question_translations USING btree (question_id, locale);
CREATE UNIQUE INDEX uq_question_code ON public.questions USING btree (module, area_key, code);
CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);
CREATE UNIQUE INDEX webhook_events_pkey ON public.webhook_events USING btree (id);
