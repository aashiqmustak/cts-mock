-- ==========================================
-- COMPLETE SUPABASE SQL SCHEMA FOR PRIORX
-- Includes All Tables, Constraints, and Authentication/RLS Policies
-- Run this script in your Supabase SQL Editor
-- ==========================================

-- 1. PROFILES TABLE (Linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'patient', -- 'administrator', 'doctor', 'insuranceReviewer', 'hospitalStaff', 'patient', 'adminHospital'
  facility TEXT,
  specialization TEXT,
  license_number TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PATIENTS TABLE
CREATE TABLE IF NOT EXISTS public.patients (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  date_of_birth TEXT NOT NULL,
  gender TEXT NOT NULL,
  insurance_id TEXT NOT NULL,
  insurance_plan TEXT NOT NULL,
  payer TEXT NOT NULL,
  primary_diagnosis TEXT,
  chronic_conditions TEXT[] DEFAULT '{}',
  primary_physician_id TEXT,
  primary_physician_name TEXT,
  contact_phone TEXT NOT NULL,
  contact_email TEXT,
  facility_id TEXT NOT NULL,
  total_authorizations INT DEFAULT 0,
  approved_authorizations INT DEFAULT 0,
  pending_authorizations INT DEFAULT 0,
  last_visit TIMESTAMPTZ,
  mrn TEXT,
  guardian_name TEXT,
  guardian_phone TEXT,
  guardian_relationship TEXT
);

-- 3. DOCTORS TABLE
CREATE TABLE IF NOT EXISTS public.doctors (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  npi TEXT NOT NULL,
  specialization TEXT NOT NULL,
  facility TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  total_requests INT DEFAULT 0,
  approved_requests INT DEFAULT 0,
  rejected_requests INT DEFAULT 0,
  approval_rate NUMERIC DEFAULT 0.0,
  avg_processing_time_ms NUMERIC DEFAULT 0.0,
  cms_specialty_code TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  availability TEXT
);

-- 4. AUTHORIZATIONS TABLE
CREATE TABLE IF NOT EXISTS public.authorizations (
  id TEXT PRIMARY KEY,
  auth_number TEXT NOT NULL UNIQUE,
  patient_id TEXT NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  patient_dob TEXT NOT NULL,
  patient_insurance_id TEXT NOT NULL,
  requesting_doctor_id TEXT NOT NULL,
  requesting_doctor_name TEXT NOT NULL,
  facility_name TEXT NOT NULL,
  facility_npi TEXT NOT NULL,
  diagnosis_code TEXT NOT NULL,
  diagnosis_description TEXT NOT NULL,
  procedure_code TEXT NOT NULL,
  procedure_description TEXT NOT NULL,
  drug_name TEXT,
  drug_ndc TEXT,
  insurance_plan_id TEXT NOT NULL,
  insurance_plan_name TEXT NOT NULL,
  status TEXT NOT NULL, -- e.g., 'pending', 'approved', 'rejected'
  priority TEXT NOT NULL DEFAULT 'routine', -- 'routine', 'urgent', 'emergent', 'stat'
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  decided_at TIMESTAMPTZ,
  processing_time_ms INT,
  reviewer_notes TEXT,
  rejection_reason TEXT,
  policy_clause_cited TEXT,
  document_ids TEXT[] DEFAULT '{}',
  ai_decision_id TEXT,
  is_urgent BOOLEAN DEFAULT FALSE,
  sla_status TEXT,
  data_source TEXT,
  cms_npi_number TEXT,
  cms_specialty TEXT
);

-- 5. AI DECISIONS TABLE
CREATE TABLE IF NOT EXISTS public.ai_decisions (
  id TEXT PRIMARY KEY,
  authorization_id TEXT NOT NULL REFERENCES public.authorizations(id) ON DELETE CASCADE,
  recommendation TEXT NOT NULL, -- 'approve', 'reject', 'escalate'
  confidence_score NUMERIC NOT NULL,
  medical_necessity_score NUMERIC NOT NULL,
  risk_score NUMERIC NOT NULL,
  appeal_likelihood NUMERIC NOT NULL,
  appeal_confidence_low NUMERIC,
  appeal_confidence_high NUMERIC,
  auto_escalated BOOLEAN DEFAULT FALSE,
  reasoning_chain JSONB NOT NULL DEFAULT '[]',
  final_justification TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  processing_time_ms INT NOT NULL,
  model_version TEXT NOT NULL,
  fraud_signals JSONB NOT NULL DEFAULT '{}'
);

-- 6. APPEALS TABLE
CREATE TABLE IF NOT EXISTS public.appeals (
  id TEXT PRIMARY KEY,
  appeal_number TEXT NOT NULL UNIQUE,
  authorization_id TEXT NOT NULL REFERENCES public.authorizations(id) ON DELETE CASCADE,
  auth_number TEXT NOT NULL,
  patient_name TEXT NOT NULL,
  filed_by_id TEXT NOT NULL,
  filed_by_name TEXT NOT NULL,
  status TEXT NOT NULL,
  filed_at TIMESTAMPTZ DEFAULT NOW(),
  decided_at TIMESTAMPTZ,
  grounds_for_appeal TEXT NOT NULL,
  supporting_evidence TEXT,
  ai_success_probability NUMERIC NOT NULL,
  ai_probability_low NUMERIC,
  ai_probability_high NUMERIC,
  draft_appeal_letter TEXT,
  rejection_reason TEXT,
  document_ids TEXT[] DEFAULT '{}'
);

-- 7. AUDIT LOGS TABLE
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id TEXT PRIMARY KEY,
  action TEXT NOT NULL,
  actor_id TEXT NOT NULL,
  actor_name TEXT NOT NULL,
  actor_role TEXT NOT NULL,
  resource_id TEXT,
  resource_type TEXT,
  description TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}',
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  entry_hash TEXT NOT NULL,
  previous_hash TEXT,
  ip_address TEXT NOT NULL
);

-- 8. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 'authorization', 'appeal', 'system', 'reminder', 'alert'
  is_read BOOLEAN DEFAULT FALSE,
  resource_id TEXT,
  resource_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. FHIR SYNCS TABLE
CREATE TABLE IF NOT EXISTS public.fhir_syncs (
  resource_type TEXT PRIMARY KEY,
  status TEXT NOT NULL, -- 'healthy', 'degraded', 'error', 'syncing'
  synced_count INT NOT NULL,
  last_sync_at TIMESTAMPTZ,
  error_message TEXT,
  pending_count INT
);

-- 10. APPOINTMENTS TABLE
CREATE TABLE IF NOT EXISTS public.appointments (
  id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  doctor_name TEXT NOT NULL,
  date_time TIMESTAMPTZ NOT NULL,
  reason TEXT NOT NULL
);

-- 11. SURGERIES TABLE
CREATE TABLE IF NOT EXISTS public.surgeries (
  id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  surgeon_name TEXT NOT NULL,
  operation_theatre TEXT NOT NULL,
  date_time TIMESTAMPTZ NOT NULL,
  procedure TEXT NOT NULL
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.authorizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appeals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fhir_syncs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surgeries ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Allow public select profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Allow users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Helper template policy generator for authenticated users
-- Applies to Patients, Doctors, AuthRequests, AI decisions, Appeals, Audit logs, Notifications, FHIR, Appointments, Surgeries

CREATE POLICY "Allow authenticated read" ON public.patients FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.patients FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.doctors FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.doctors FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.authorizations FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.authorizations FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.ai_decisions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.ai_decisions FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.appeals FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.appeals FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.audit_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.audit_logs FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.notifications FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.notifications FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.fhir_syncs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.fhir_syncs FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.appointments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.appointments FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read" ON public.surgeries FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write" ON public.surgeries FOR ALL TO authenticated USING (true);

-- ==========================================
-- AUTHENTICATION TRIGGER CONFIGURATION
-- Automatically confirms email and creates a profile record for new users
-- ==========================================

-- Trigger to automatically confirm new users' email address (instantly authenticates them)
CREATE OR REPLACE FUNCTION public.auto_confirm_user_email()
RETURNS trigger AS $$
BEGIN
  new.email_confirmed_at := NOW();
  new.confirmed_at := NOW();
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_before_created
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user_email();

-- Trigger to automatically copy new users to the public.profiles table
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'patient')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
