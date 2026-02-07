-- ============================================
-- MIGRATION STEP-BY-STEP
-- Copy dan jalankan SATU PER SATU di Supabase SQL Editor
-- ============================================

-- STEP 1: Tambah kolom question_4_rating
ALTER TABLE survey_responses 
ADD COLUMN question_4_rating INTEGER;

-- STEP 2: Update data lama dengan nilai default
UPDATE survey_responses 
SET question_4_rating = 3 
WHERE question_4_rating IS NULL;

-- STEP 3: Tambah constraint
ALTER TABLE survey_responses 
ADD CONSTRAINT check_question_4_rating 
CHECK (question_4_rating >= 1 AND question_4_rating <= 4);

-- STEP 4: Jadikan NOT NULL
ALTER TABLE survey_responses 
ALTER COLUMN question_4_rating SET NOT NULL;

-- STEP 5: Verifikasi - cek struktur tabel
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'survey_responses' 
AND column_name LIKE 'question%'
ORDER BY column_name;
