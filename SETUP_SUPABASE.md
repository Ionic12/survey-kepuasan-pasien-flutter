# 🚀 Panduan Setup Supabase untuk Survey App

## ✅ Status Integrasi

### Yang Sudah Siap:
- ✅ Package `supabase_flutter` sudah terinstall
- ✅ Konfigurasi Supabase di `main.dart` sudah ada
- ✅ Service layer (`supabase_service.dart`) sudah dibuat
- ✅ SQL Schema sudah dibuat (`supabase_schema.sql`)
- ✅ Aplikasi sudah terintegrasi dengan Supabase

### Yang Perlu Dilakukan:
1. ⚠️ **Jalankan SQL Schema di Supabase Dashboard**
2. ✅ **Test koneksi ke Supabase**

---

## 📋 Langkah-Langkah Setup

### **Langkah 1: Buka Supabase Dashboard**

1. Buka browser dan kunjungi: https://app.supabase.com
2. Login dengan akun Anda
3. Pilih project: **zxixsaxepynkyocjinjx**

### **Langkah 2: Jalankan SQL Schema**

1. Di dashboard Supabase, klik **SQL Editor** di sidebar kiri
2. Klik tombol **New Query**
3. Buka file [`supabase_schema.sql`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/supabase_schema.sql)
4. **Copy semua isi file** tersebut
5. **Paste** ke SQL Editor di Supabase
6. Klik tombol **Run** atau tekan `Ctrl + Enter`
7. Tunggu hingga muncul pesan sukses

> **💡 Tip:** Jika ada error, pastikan tidak ada tabel dengan nama yang sama sebelumnya.

### **Langkah 3: Verifikasi Tabel Sudah Dibuat**

1. Di dashboard Supabase, klik **Table Editor** di sidebar kiri
2. Anda harus melihat tabel-tabel berikut:
   - ✅ `survey_responses` - Tabel utama untuk menyimpan jawaban survey
   - ✅ `survey_questions` - Tabel untuk pertanyaan survey
   - ✅ `survey_statistics` - Tabel untuk statistik (opsional)

3. Klik tabel `survey_questions` dan pastikan ada 3 pertanyaan default

### **Langkah 4: Test Aplikasi**

Aplikasi Anda sudah siap digunakan! Sekarang coba:

1. Jalankan aplikasi Flutter (sudah berjalan di Chrome)
2. Isi survey dengan memilih emoji rating
3. Klik "Kirim Survey"
4. Cek di Supabase Dashboard → **Table Editor** → `survey_responses`
5. Anda harus melihat data baru masuk!

---

## 🗂️ Struktur Database

### **Tabel: `survey_responses`**

Kolom utama:
- `id` - UUID unik untuk setiap response
- `created_at` - Timestamp otomatis
- `question_1_rating` - Rating untuk pertanyaan 1 (1-4)
- `question_2_rating` - Rating untuk pertanyaan 2 (1-4)
- `question_3_rating` - Rating untuk pertanyaan 3 (1-4)
- `respondent_name` - Nama responden (opsional)
- `respondent_email` - Email responden (opsional)
- `additional_comments` - Komentar tambahan (opsional)

### **Rating Scale:**
- **1** = 😞 Tidak Sesuai
- **2** = 😐 Kurang Sesuai
- **3** = 🙂 Sesuai
- **4** = 😄 Sangat Sesuai

---

## 🔧 Konfigurasi Supabase

Konfigurasi sudah ada di [`lib/main.dart`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/lib/main.dart):

```dart
await Supabase.initialize(
  url: 'https://zxixsaxepynkyocjinjx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

> **⚠️ Catatan Keamanan:** Anon key ini aman untuk digunakan di client-side karena sudah dilindungi oleh Row Level Security (RLS).

---

## 📊 Fitur Analytics (Opsional)

Service layer sudah menyediakan method untuk analytics:

### **1. Get Survey Statistics**
```dart
final stats = await SupabaseService().getSurveyStats();
print('Total responses: ${stats['total_responses']}');
print('Average Q1: ${stats['avg_question_1']}');
print('Satisfaction rate: ${stats['satisfaction_rate']}%');
```

### **2. Get Daily Summary**
```dart
final summary = await SupabaseService().getDailySummary(limit: 7);
// Mendapatkan ringkasan 7 hari terakhir
```

### **3. Get Rating Distribution**
```dart
final distribution = await SupabaseService().getRatingDistribution();
// Mendapatkan distribusi rating per pertanyaan
```

---

## 🔒 Keamanan (Row Level Security)

Database sudah dikonfigurasi dengan RLS:

✅ **Siapa saja bisa submit survey** (anonymous)
- Tidak perlu login untuk mengisi survey
- Data langsung masuk ke database

✅ **Hanya authenticated users yang bisa lihat hasil**
- Admin perlu login untuk melihat analytics
- Data responden terlindungi

---

## 🧪 Testing

### **Test Koneksi ke Supabase:**

Tambahkan di `main.dart` setelah initialize:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zxixsaxepynkyocjinjx.supabase.co',
    anonKey: '...',
  );
  
  // Test koneksi
  final service = SupabaseService();
  final connected = await service.testConnection();
  print('Supabase connected: $connected');
  
  runApp(const MyApp());
}
```

---

## ❓ Troubleshooting

### **Error: "relation survey_responses does not exist"**
**Solusi:** Anda belum menjalankan SQL schema. Kembali ke Langkah 2.

### **Error: "JWT expired"**
**Solusi:** Anon key sudah expired. Generate anon key baru di Supabase Dashboard → Settings → API.

### **Data tidak masuk ke database**
**Solusi:** 
1. Cek console browser/terminal untuk error message
2. Pastikan RLS policy sudah aktif
3. Cek network tab untuk melihat request ke Supabase

### **Error: "Invalid API key"**
**Solusi:** Pastikan URL dan anon key di `main.dart` sudah benar.

---

## 📝 Next Steps

Setelah setup selesai, Anda bisa:

1. **Customize pertanyaan** di tabel `survey_questions`
2. **Buat dashboard admin** untuk melihat analytics
3. **Export data** ke Excel/CSV dari Supabase
4. **Setup email notifications** saat ada survey baru
5. **Tambahkan field custom** seperti lokasi, device info, dll

---

## 📞 Support

Jika ada pertanyaan atau masalah, silakan hubungi developer atau cek dokumentasi Supabase:
- 📖 Supabase Docs: https://supabase.com/docs
- 🎓 Flutter + Supabase: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter

---

**Selamat! Aplikasi survey Anda sudah siap digunakan! 🎉**
