-- ============================================
-- SUPABASE SQL SCHEMA FOR SURVEY APP
-- Aplikasi Survey Kepuasan Klinik Novi Maharani
-- ============================================

-- Table: survey_responses
-- Menyimpan semua response dari survey kepuasan
CREATE TABLE survey_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Informasi responden (opsional)
  respondent_name TEXT,
  respondent_email TEXT,
  respondent_phone TEXT,
  
  -- Jawaban untuk setiap pertanyaan (1-4, dimana 1=tidak sesuai, 4=sangat sesuai)
  question_1_rating INTEGER NOT NULL CHECK (question_1_rating >= 1 AND question_1_rating <= 4),
  question_2_rating INTEGER NOT NULL CHECK (question_2_rating >= 1 AND question_2_rating <= 4),
  question_3_rating INTEGER NOT NULL CHECK (question_3_rating >= 1 AND question_3_rating <= 4),
  
  -- Komentar tambahan (opsional)
  additional_comments TEXT,
  
  -- Metadata
  device_info TEXT,
  app_version TEXT,
  
  -- Index untuk performa query
  CONSTRAINT valid_ratings CHECK (
    question_1_rating BETWEEN 1 AND 4 AND
    question_2_rating BETWEEN 1 AND 4 AND
    question_3_rating BETWEEN 1 AND 4
  )
);

-- Index untuk query berdasarkan tanggal
CREATE INDEX idx_survey_responses_created_at ON survey_responses(created_at DESC);

-- Index untuk query berdasarkan email (jika ingin track responden yang sama)
CREATE INDEX idx_survey_responses_email ON survey_responses(respondent_email);

-- ============================================
-- Table: survey_questions
-- Menyimpan daftar pertanyaan survey (untuk fleksibilitas)
-- ============================================
CREATE TABLE survey_questions (
  id SERIAL PRIMARY KEY,
  question_text TEXT NOT NULL,
  question_order INTEGER NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Insert pertanyaan default
INSERT INTO survey_questions (question_text, question_order) VALUES
  ('Bagaimana pelayanan kami?', 1),
  ('Apakah fasilitas kami memadai?', 2),
  ('Apakah Anda akan merekomendasikan kami?', 3);

-- ============================================
-- Table: survey_statistics (Optional)
-- Untuk menyimpan statistik agregat (untuk dashboard admin)
-- ============================================
CREATE TABLE survey_statistics (
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  total_responses INTEGER DEFAULT 0,
  avg_question_1 DECIMAL(3,2),
  avg_question_2 DECIMAL(3,2),
  avg_question_3 DECIMAL(3,2),
  avg_overall DECIMAL(3,2),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index untuk query berdasarkan tanggal
CREATE INDEX idx_survey_statistics_date ON survey_statistics(date DESC);

-- ============================================
-- VIEWS untuk Analytics
-- ============================================

-- View: Daily Survey Summary
CREATE OR REPLACE VIEW daily_survey_summary AS
SELECT 
  DATE(created_at) as survey_date,
  COUNT(*) as total_responses,
  ROUND(AVG(question_1_rating)::numeric, 2) as avg_q1,
  ROUND(AVG(question_2_rating)::numeric, 2) as avg_q2,
  ROUND(AVG(question_3_rating)::numeric, 2) as avg_q3,
  ROUND(AVG((question_1_rating + question_2_rating + question_3_rating) / 3.0)::numeric, 2) as avg_overall
FROM survey_responses
GROUP BY DATE(created_at)
ORDER BY survey_date DESC;

-- View: Rating Distribution
CREATE OR REPLACE VIEW rating_distribution AS
SELECT 
  'Question 1' as question,
  question_1_rating as rating,
  COUNT(*) as count
FROM survey_responses
GROUP BY question_1_rating
UNION ALL
SELECT 
  'Question 2' as question,
  question_2_rating as rating,
  COUNT(*) as count
FROM survey_responses
GROUP BY question_2_rating
UNION ALL
SELECT 
  'Question 3' as question,
  question_3_rating as rating,
  COUNT(*) as count
FROM survey_responses
GROUP BY question_3_rating
ORDER BY question, rating;

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS pada tabel survey_responses
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- Policy: Semua orang bisa insert (submit survey)
CREATE POLICY "Anyone can submit survey" 
  ON survey_responses 
  FOR INSERT 
  WITH CHECK (true);

-- Policy: Hanya authenticated users yang bisa read (untuk admin)
CREATE POLICY "Authenticated users can view responses" 
  ON survey_responses 
  FOR SELECT 
  USING (auth.role() = 'authenticated');

-- Enable RLS pada tabel survey_questions
ALTER TABLE survey_questions ENABLE ROW LEVEL SECURITY;

-- Policy: Semua orang bisa read questions
CREATE POLICY "Anyone can view questions" 
  ON survey_questions 
  FOR SELECT 
  USING (is_active = true);

-- Policy: Hanya authenticated users yang bisa update questions
CREATE POLICY "Authenticated users can update questions" 
  ON survey_questions 
  FOR UPDATE 
  USING (auth.role() = 'authenticated');

-- ============================================
-- FUNCTIONS untuk Analytics
-- ============================================

-- Function: Get survey statistics for date range
CREATE OR REPLACE FUNCTION get_survey_stats(
  start_date DATE,
  end_date DATE
)
RETURNS TABLE (
  total_responses BIGINT,
  avg_q1 NUMERIC,
  avg_q2 NUMERIC,
  avg_q3 NUMERIC,
  avg_overall NUMERIC,
  satisfaction_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::BIGINT as total_responses,
    ROUND(AVG(question_1_rating)::numeric, 2) as avg_q1,
    ROUND(AVG(question_2_rating)::numeric, 2) as avg_q2,
    ROUND(AVG(question_3_rating)::numeric, 2) as avg_q3,
    ROUND(AVG((question_1_rating + question_2_rating + question_3_rating) / 3.0)::numeric, 2) as avg_overall,
    ROUND((COUNT(CASE WHEN (question_1_rating + question_2_rating + question_3_rating) / 3.0 >= 3 THEN 1 END)::NUMERIC / COUNT(*)::NUMERIC * 100), 2) as satisfaction_rate
  FROM survey_responses
  WHERE DATE(created_at) BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS untuk Auto-update
-- ============================================

-- Function untuk update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk survey_questions
CREATE TRIGGER update_survey_questions_updated_at
  BEFORE UPDATE ON survey_questions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (untuk testing)
-- ============================================

-- Insert beberapa sample responses
INSERT INTO survey_responses (question_1_rating, question_2_rating, question_3_rating, additional_comments) VALUES
  (4, 4, 4, 'Pelayanan sangat memuaskan!'),
  (3, 4, 3, 'Secara keseluruhan baik'),
  (4, 3, 4, 'Dokter dan perawat sangat ramah'),
  (2, 3, 2, 'Waktu tunggu agak lama'),
  (4, 4, 4, 'Sangat puas dengan pelayanan');

-- ============================================
-- NOTES:
-- ============================================
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Rating scale: 1 = Tidak Sesuai, 2 = Kurang Sesuai, 3 = Sesuai, 4 = Sangat Sesuai
-- 3. RLS sudah diaktifkan untuk keamanan
-- 4. Semua orang bisa submit survey (anonymous)
-- 5. Hanya authenticated users (admin) yang bisa lihat hasil
-- ============================================
