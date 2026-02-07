-- ============================================
-- UPDATED SQL SCHEMA FOR 4-QUESTION SURVEY
-- Copy-paste script ini ke Supabase SQL Editor
-- ============================================

-- 1. Drop existing table if you want to start fresh (OPTIONAL - HATI-HATI!)
-- DROP TABLE IF EXISTS survey_responses CASCADE;

-- 2. Buat tabel survey_responses dengan 4 pertanyaan
CREATE TABLE IF NOT EXISTS survey_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Rating untuk 4 pertanyaan (1-4)
  question_1_rating INTEGER NOT NULL CHECK (question_1_rating >= 1 AND question_1_rating <= 4),
  question_2_rating INTEGER NOT NULL CHECK (question_2_rating >= 1 AND question_2_rating <= 4),
  question_3_rating INTEGER NOT NULL CHECK (question_3_rating >= 1 AND question_3_rating <= 4),
  question_4_rating INTEGER NOT NULL CHECK (question_4_rating >= 1 AND question_4_rating <= 4),
  
  -- Informasi tambahan (opsional)
  respondent_name TEXT,
  respondent_email TEXT,
  respondent_phone TEXT,
  additional_comments TEXT,
  app_version TEXT
);

-- 3. Buat index untuk performa
CREATE INDEX IF NOT EXISTS idx_survey_responses_created_at ON survey_responses(created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- 5. Buat policy: Semua orang bisa insert (submit survey)
DROP POLICY IF EXISTS "Anyone can submit survey" ON survey_responses;
CREATE POLICY "Anyone can submit survey" 
  ON survey_responses 
  FOR INSERT 
  WITH CHECK (true);

-- 6. Buat policy: Semua orang bisa read (untuk testing)
DROP POLICY IF EXISTS "Anyone can view responses" ON survey_responses;
CREATE POLICY "Anyone can view responses" 
  ON survey_responses 
  FOR SELECT 
  USING (true);

-- ============================================
-- MIGRATION: Jika tabel lama sudah ada dengan 3 pertanyaan
-- ============================================

-- Jika Anda sudah punya data lama dengan 3 pertanyaan, jalankan ini:
-- ALTER TABLE survey_responses ADD COLUMN IF NOT EXISTS question_4_rating INTEGER CHECK (question_4_rating >= 1 AND question_4_rating <= 4);

-- Update data lama dengan nilai default (misalnya 3 = "sesuai")
-- UPDATE survey_responses SET question_4_rating = 3 WHERE question_4_rating IS NULL;

-- Jadikan kolom NOT NULL setelah semua data ter-update
-- ALTER TABLE survey_responses ALTER COLUMN question_4_rating SET NOT NULL;

-- ============================================
-- SELESAI! Tabel sudah siap untuk 4 pertanyaan
-- ============================================

-- Test: Insert sample data
INSERT INTO survey_responses (
  question_1_rating, 
  question_2_rating, 
  question_3_rating, 
  question_4_rating,
  additional_comments
) 
VALUES (4, 4, 4, 4, 'Test data - semua aspek sangat baik!');

-- Cek apakah data berhasil masuk
SELECT * FROM survey_responses ORDER BY created_at DESC LIMIT 5;
