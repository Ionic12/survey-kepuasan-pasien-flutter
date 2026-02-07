-- ============================================
-- FIX RLS POLICY UNTUK SURVEY APP
-- Jalankan script ini jika survey gagal terkirim
-- ============================================

-- 1. Disable RLS sementara untuk testing
ALTER TABLE survey_responses DISABLE ROW LEVEL SECURITY;

-- 2. Hapus semua policy yang ada
DROP POLICY IF EXISTS "Anyone can submit survey" ON survey_responses;
DROP POLICY IF EXISTS "Anyone can view responses" ON survey_responses;
DROP POLICY IF EXISTS "Authenticated users can view responses" ON survey_responses;

-- 3. Enable RLS kembali
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- 4. Buat policy baru yang benar untuk INSERT (anonymous users)
CREATE POLICY "Enable insert for anonymous users"
ON survey_responses
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- 5. Buat policy untuk SELECT (semua orang bisa lihat untuk testing)
CREATE POLICY "Enable read access for all users"
ON survey_responses
FOR SELECT
TO anon, authenticated
USING (true);

-- ============================================
-- ALTERNATIVE: Jika masih gagal, disable RLS
-- ============================================
-- Uncomment baris di bawah jika masih error:
-- ALTER TABLE survey_responses DISABLE ROW LEVEL SECURITY;

-- ============================================
-- TEST: Insert sample data
-- ============================================
INSERT INTO survey_responses (question_1_rating, question_2_rating, question_3_rating, additional_comments) 
VALUES (3, 4, 3, 'Test setelah fix RLS');

-- Cek data
SELECT id, created_at, question_1_rating, question_2_rating, question_3_rating, additional_comments 
FROM survey_responses 
ORDER BY created_at DESC 
LIMIT 5;
