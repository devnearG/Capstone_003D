-- =============================================================================
-- TryAIGap - Esquema DDL de Base de Datos PostgreSQL (Supabase)
-- Arquitectura: Relacional PostgreSQL 15 con Row Level Security (RLS)
-- =============================================================================

CREATE TABLE distributor_codes (
	code VARCHAR(40) NOT NULL, 
	discount_pct SMALLINT NOT NULL, 
	active BOOLEAN NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id)
);

CREATE TABLE organizations (
	name VARCHAR(200) NOT NULL, 
	sector VARCHAR(80), 
	size VARCHAR(40), 
	country VARCHAR(80), 
	currency VARCHAR(3) NOT NULL, 
	legal_name VARCHAR(200), 
	address TEXT, 
	tax_id VARCHAR(40), 
	logo_url TEXT, 
	doc_locale VARCHAR(2) NOT NULL, 
	theme VARCHAR(10) NOT NULL, 
	plan VARCHAR(10) NOT NULL, 
	status VARCHAR(12) NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_org_plan CHECK (plan in ('free','pro')), 
	CONSTRAINT ck_org_status CHECK (status in ('active','suspended'))
);

CREATE TABLE questions (
	module VARCHAR(10) NOT NULL, 
	area_key VARCHAR(20), 
	block_id VARCHAR(4) NOT NULL, 
	code VARCHAR(8) NOT NULL, 
	position SMALLINT NOT NULL, 
	dimension VARCHAR(20), 
	vector_type VARCHAR(30), 
	weight SMALLINT, 
	readiness SMALLINT, 
	status VARCHAR(12) NOT NULL, 
	id UUID NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_question_code UNIQUE (module, area_key, code)
);

CREATE TABLE webhook_events (
	provider VARCHAR(20) NOT NULL, 
	event_id VARCHAR(120) NOT NULL, 
	type VARCHAR(80), 
	processed_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id)
);

CREATE TABLE assessments (
	organization_id UUID NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	plan VARCHAR(10) NOT NULL, 
	started_at TIMESTAMP WITH TIME ZONE, 
	completed_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE
);

CREATE TABLE invitations (
	organization_id UUID NOT NULL, 
	full_name VARCHAR(160) NOT NULL, 
	email VARCHAR(320) NOT NULL, 
	whatsapp VARCHAR(32), 
	phone VARCHAR(32), 
	area_key VARCHAR(20), 
	token_hash VARCHAR(128) NOT NULL, 
	status VARCHAR(12) NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE
);

CREATE TABLE question_translations (
	question_id UUID NOT NULL, 
	locale VARCHAR(2) NOT NULL, 
	text TEXT NOT NULL, 
	block_title VARCHAR(200), 
	id UUID NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_qtrans UNIQUE (question_id, locale), 
	FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);

CREATE TABLE quotes (
	organization_id UUID NOT NULL, 
	base_price NUMERIC(12, 2) NOT NULL, 
	areas JSONB NOT NULL, 
	final_report BOOLEAN NOT NULL, 
	distributor_code VARCHAR(40), 
	subtotal NUMERIC(12, 2) NOT NULL, 
	discount NUMERIC(12, 2) NOT NULL, 
	total NUMERIC(12, 2) NOT NULL, 
	currency VARCHAR(3) NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE
);

CREATE TABLE users (
	email VARCHAR(320) NOT NULL, 
	supabase_user_id UUID, 
	full_name VARCHAR(160), 
	role VARCHAR(20) NOT NULL, 
	locale VARCHAR(2) NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	organization_id UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_user_role CHECK (role in ('client','consultant','admin')), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE SET NULL
);

CREATE TABLE answers (
	assessment_id UUID NOT NULL, 
	question_id UUID NOT NULL, 
	value SMALLINT, 
	state VARCHAR(12) NOT NULL, 
	updated_by UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_answer UNIQUE (assessment_id, question_id), 
	CONSTRAINT ck_answer_value CHECK (value is null or (value >= 1 and value <= 5)), 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE, 
	FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE, 
	FOREIGN KEY(updated_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE audit_logs (
	actor_id UUID, 
	action VARCHAR(80) NOT NULL, 
	resource_type VARCHAR(80), 
	resource_id VARCHAR(80), 
	details JSONB NOT NULL, 
	ip_address VARCHAR(45), 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	id UUID NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(actor_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE consultant_assignments (
	organization_id UUID NOT NULL, 
	consultant_id UUID NOT NULL, 
	assigned_by UUID, 
	status VARCHAR(12) NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_consultant_assignment UNIQUE (organization_id, consultant_id), 
	CONSTRAINT ck_assignment_status CHECK (status in ('active','revoked')), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
	FOREIGN KEY(consultant_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(assigned_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE consultant_notes (
	organization_id UUID NOT NULL, 
	consultant_id UUID, 
	body TEXT NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
	FOREIGN KEY(consultant_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE delegations (
	assessment_id UUID NOT NULL, 
	question_id UUID NOT NULL, 
	delegate_name VARCHAR(160) NOT NULL, 
	delegate_email VARCHAR(320) NOT NULL, 
	token_hash VARCHAR(128) NOT NULL, 
	status VARCHAR(12) NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	answered_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE, 
	FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE CASCADE
);

CREATE TABLE documents (
	organization_id UUID NOT NULL, 
	assessment_id UUID, 
	question_id UUID, 
	area_key VARCHAR(20), 
	filename VARCHAR(255) NOT NULL, 
	mime_type VARCHAR(120) NOT NULL, 
	size_bytes INTEGER NOT NULL, 
	storage_key TEXT NOT NULL, 
	uploaded_by UUID, 
	deleted_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE, 
	FOREIGN KEY(question_id) REFERENCES questions (id) ON DELETE SET NULL, 
	FOREIGN KEY(uploaded_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE leads (
	full_name VARCHAR(160) NOT NULL, 
	job_title VARCHAR(120), 
	company_email VARCHAR(320) NOT NULL, 
	company_name VARCHAR(200) NOT NULL, 
	company_size VARCHAR(40), 
	industry VARCHAR(80), 
	country VARCHAR(80), 
	terms_accepted BOOLEAN NOT NULL, 
	locale VARCHAR(2) NOT NULL, 
	user_id UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE magic_link_tokens (
	user_id UUID NOT NULL, 
	token_hash VARCHAR(128) NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	used_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE org_members (
	organization_id UUID NOT NULL, 
	user_id UUID, 
	role VARCHAR(20) NOT NULL, 
	area_key VARCHAR(20), 
	status VARCHAR(20) NOT NULL, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE payments (
	organization_id UUID NOT NULL, 
	quote_id UUID, 
	provider VARCHAR(20) NOT NULL, 
	provider_ref VARCHAR(160), 
	amount NUMERIC(12, 2) NOT NULL, 
	currency VARCHAR(3) NOT NULL, 
	status VARCHAR(12) NOT NULL, 
	proof_storage_key TEXT, 
	proof_filename VARCHAR(255), 
	reconciliation_status VARCHAR(12) NOT NULL, 
	reconciled_at TIMESTAMP WITH TIME ZONE, 
	reconciled_by UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(organization_id) REFERENCES organizations (id) ON DELETE CASCADE, 
	FOREIGN KEY(quote_id) REFERENCES quotes (id) ON DELETE SET NULL, 
	FOREIGN KEY(reconciled_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE refresh_tokens (
	user_id UUID NOT NULL, 
	token_hash VARCHAR(128) NOT NULL, 
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	revoked_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE report_jobs (
	assessment_id UUID NOT NULL, 
	locale VARCHAR(2) NOT NULL, 
	status VARCHAR(12) NOT NULL, 
	storage_key TEXT, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE
);

CREATE TABLE reviews (
	assessment_id UUID NOT NULL, 
	mode VARCHAR(10) NOT NULL, 
	stage SMALLINT NOT NULL, 
	consultant_id UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE, 
	FOREIGN KEY(consultant_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE TABLE area_states (
	assessment_id UUID NOT NULL, 
	area_key VARCHAR(20) NOT NULL, 
	active BOOLEAN NOT NULL, 
	progress SMALLINT NOT NULL, 
	leader_member_id UUID, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_area_state UNIQUE (assessment_id, area_key), 
	FOREIGN KEY(assessment_id) REFERENCES assessments (id) ON DELETE CASCADE, 
	FOREIGN KEY(leader_member_id) REFERENCES org_members (id) ON DELETE SET NULL
);

CREATE TABLE consultant_ratings (
	review_id UUID NOT NULL, 
	chapter_key VARCHAR(40) NOT NULL, 
	knowledge SMALLINT NOT NULL, 
	friendliness SMALLINT NOT NULL, 
	methodology SMALLINT NOT NULL, 
	comments TEXT, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(review_id) REFERENCES reviews (id) ON DELETE CASCADE
);

CREATE TABLE review_chapters (
	review_id UUID NOT NULL, 
	chapter_key VARCHAR(40) NOT NULL, 
	validated BOOLEAN NOT NULL, 
	validator_id UUID, 
	note TEXT, 
	validated_at TIMESTAMP WITH TIME ZONE, 
	id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(review_id) REFERENCES reviews (id) ON DELETE CASCADE, 
	FOREIGN KEY(validator_id) REFERENCES users (id) ON DELETE SET NULL
);


-- =============================================================================
-- Supabase Row Level Security (RLS) y Almacenamiento Seguro
-- =============================================================================

-- TryAIGap baseline security migration
-- FastAPI uses direct PostgreSQL credentials and bypasses RLS.
-- Public Supabase roles have no policies, so browser/direct clients cannot read or mutate app data.

do $$
declare
  table_name text;
begin
  for table_name in
    select tablename
    from pg_tables
    where schemaname = 'public'
      and tablename <> 'alembic_version'
  loop
    execute format('alter table public.%I enable row level security', table_name);
  end loop;
end $$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'evidence',
  'evidence',
  false,
  104857600,
  array[
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/webp',
    'text/plain',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
