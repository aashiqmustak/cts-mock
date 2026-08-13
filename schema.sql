-- SQL Schema for PriorX Supabase Backend
-- Create a single flexible key-value JSONB table to sync all application states.

CREATE TABLE IF NOT EXISTS priorx_store (
  key TEXT PRIMARY KEY,
  data JSONB NOT NULL
);
