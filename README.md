# Flutter Survey App - Setup Guide

## 📋 Deskripsi
Aplikasi Flutter untuk survey kepuasan pelanggan dengan 3 pertanyaan dan 4 pilihan penilaian menggunakan emoji. Data survey disimpan ke Supabase.

## ✨ Fitur
- 🎨 **Desain Modern**: Gradient background yang menarik (Purple to Blue)
- 😊 **4 Pilihan Emoji**: Tidak Sesuai, Kurang Sesuai, Sesuai, Sangat Sesuai
- 📊 **3 Pertanyaan Survey**: Kualitas layanan, kecepatan, dan rekomendasi
- 🔄 **Animasi Smooth**: Scale animation pada emoji buttons dan page transitions
- 📱 **Responsive**: Layout yang menyesuaikan berbagai ukuran layar
- ☁️ **Supabase Integration**: Menyimpan hasil survey ke database cloud
- ✅ **Result Screen**: Menampilkan ringkasan jawaban setelah submit

## 🚀 Setup Supabase

### 1. Buat Project Supabase
1. Kunjungi [supabase.com](https://supabase.com)
2. Sign up / Login
3. Klik "New Project"
4. Isi detail project (nama, database password, region)
5. Tunggu project selesai dibuat (~2 menit)

### 2. Buat Tabel Database
Jalankan SQL query berikut di Supabase SQL Editor:

```sql
-- Create survey_responses table
CREATE TABLE survey_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  responses JSONB NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- Create policy to allow insert for anyone
CREATE POLICY "Allow public insert" ON survey_responses
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Create policy to allow select for anyone (optional - for analytics)
CREATE POLICY "Allow public select" ON survey_responses
  FOR SELECT
  TO public
  USING (true);
```

### 3. Dapatkan Credentials
1. Di Supabase Dashboard, klik "Settings" (icon gear)
2. Pilih "API"
3. Copy:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public key** (key yang panjang)

### 4. Update Konfigurasi App
Buka file `lib/main.dart` dan ganti:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Ganti dengan Project URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Ganti dengan anon public key
);
```

## 📦 Instalasi & Menjalankan App

### Prerequisites
- Flutter SDK installed (versi 3.0 atau lebih baru)
- Android Studio / VS Code dengan Flutter extension
- Emulator atau physical device

### Langkah-langkah

1. **Install Dependencies**
```bash
cd C:\Users\ASUS\.gemini\antigravity\scratch\flutter_survey_app
flutter pub get
```

2. **Jalankan App**
```bash
flutter run
```

Atau pilih device dan tekan F5 di VS Code / Android Studio

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point & Supabase initialization
├── models/
│   └── survey_question.dart     # Data model untuk pertanyaan & rating
├── services/
│   └── supabase_service.dart    # Service untuk komunikasi dengan Supabase
├── screens/
│   ├── survey_screen.dart       # Main survey screen dengan PageView
│   └── result_screen.dart       # Result/summary screen
└── widgets/
    ├── emoji_button.dart        # Reusable emoji rating button
    └── question_card.dart       # Card untuk menampilkan pertanyaan
```

## 🎯 Cara Menggunakan

1. **Buka App**: Akan langsung masuk ke survey screen
2. **Jawab Pertanyaan**: Tap emoji yang sesuai dengan penilaian Anda
3. **Navigasi**: 
   - Tombol "Selanjutnya" untuk ke pertanyaan berikutnya
   - Tombol "Sebelumnya" untuk kembali
4. **Submit**: Setelah pertanyaan terakhir, tap "Kirim Survey"
5. **Lihat Hasil**: Result screen akan menampilkan ringkasan jawaban
6. **Survey Baru**: Tap "Isi Survey Baru" untuk mengulang

## 🎨 Kustomisasi

### Mengubah Pertanyaan
Edit file `lib/screens/survey_screen.dart`:

```dart
final List<SurveyQuestion> _questions = [
  SurveyQuestion(
    id: 'q1',
    question: 'Pertanyaan Anda di sini?',
  ),
  // Tambah atau ubah pertanyaan
];
```

### Mengubah Warna Gradient
Edit di `lib/screens/survey_screen.dart`:

```dart
gradient: LinearGradient(
  colors: [
    Colors.deepPurple.shade700,  // Ubah warna sesuai keinginan
    Colors.blue.shade400,
  ],
),
```

### Menambah/Mengurangi Pilihan Rating
Edit enum di `lib/models/survey_question.dart`

## 📊 Melihat Data di Supabase

1. Buka Supabase Dashboard
2. Pilih "Table Editor"
3. Klik tabel `survey_responses`
4. Lihat semua data survey yang masuk

Format data yang tersimpan:
```json
{
  "id": "uuid",
  "responses": {
    "q1": 4,
    "q2": 3,
    "q3": 4
  },
  "submitted_at": "2026-02-04T11:30:00Z"
}
```

## 🔧 Troubleshooting

### Error: Supabase not initialized
- Pastikan sudah mengganti `YOUR_SUPABASE_URL` dan `YOUR_SUPABASE_ANON_KEY` di `main.dart`

### Error: Insert failed
- Cek koneksi internet
- Pastikan tabel `survey_responses` sudah dibuat
- Pastikan RLS policy sudah di-enable

### Emoji tidak muncul
- Pastikan device/emulator support emoji
- Coba restart app

## 📱 Build untuk Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🎉 Selesai!
Aplikasi survey kepuasan Anda sudah siap digunakan!
