# Supabase Configuration Guide

## Setup Instructions

### 1. Create Supabase Account & Project
1. Go to https://supabase.com
2. Sign up or login
3. Click "New Project"
4. Fill in:
   - Project name: `flutter-survey-app` (or any name)
   - Database password: (create a strong password)
   - Region: Choose closest to your location
5. Wait for project to be created (~2 minutes)

### 2. Create Database Table

Go to SQL Editor in Supabase Dashboard and run this query:

```sql
-- Create survey_responses table
CREATE TABLE survey_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  responses JSONB NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert survey responses
CREATE POLICY "Allow public insert" ON survey_responses
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Allow anyone to read survey responses (for analytics)
CREATE POLICY "Allow public select" ON survey_responses
  FOR SELECT
  TO public
  USING (true);
```

### 3. Get Your Credentials

1. In Supabase Dashboard, click "Settings" (gear icon)
2. Click "API" in the sidebar
3. Copy these values:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (long string)

### 4. Update Flutter App

Open `lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Paste your Project URL here
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Paste your anon public key here
);
```

Example:
```dart
await Supabase.initialize(
  url: 'https://abcdefghijk.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODk1ODQwMDAsImV4cCI6MjAwNTE2MDAwMH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
);
```

### 5. Test the Connection

1. Run the app: `flutter run`
2. Fill out the survey
3. Click "Kirim Survey"
4. Go to Supabase Dashboard → Table Editor → survey_responses
5. You should see your survey data!

## Database Schema

### survey_responses table

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, auto-generated |
| responses | JSONB | Survey answers in JSON format |
| submitted_at | TIMESTAMP | When the survey was submitted |

### Example Data

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "responses": {
    "q1": 4,
    "q2": 3,
    "q3": 4
  },
  "submitted_at": "2026-02-04T11:30:00+07:00"
}
```

Rating values:
- 1 = Tidak Sesuai 😞
- 2 = Kurang Sesuai 😐
- 3 = Sesuai 🙂
- 4 = Sangat Sesuai 😄

## Optional: View Analytics

You can query your survey data in Supabase SQL Editor:

```sql
-- Get total responses
SELECT COUNT(*) as total_responses FROM survey_responses;

-- Get average rating for each question
SELECT 
  AVG((responses->>'q1')::int) as avg_q1,
  AVG((responses->>'q2')::int) as avg_q2,
  AVG((responses->>'q3')::int) as avg_q3
FROM survey_responses;

-- Get responses from last 7 days
SELECT * FROM survey_responses
WHERE submitted_at > NOW() - INTERVAL '7 days'
ORDER BY submitted_at DESC;
```

## Troubleshooting

### "Supabase not initialized" error
- Make sure you replaced `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` in `main.dart`
- Check that the values are correct (no extra spaces)

### "Insert failed" error
- Check internet connection
- Verify the table `survey_responses` exists in Supabase
- Make sure RLS policies are created

### Can't see data in Supabase
- Refresh the Table Editor page
- Check if the insert was successful (no error message in app)
- Verify you're looking at the correct project

## Security Notes

- The `anon public key` is safe to use in client apps
- Row Level Security (RLS) is enabled to control access
- Current policies allow anyone to insert and read data
- For production, consider adding authentication and stricter policies
