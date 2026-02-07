# 🔧 Panduan Fix RLS (Row Level Security)

## ⚠️ Masalah: Survey Gagal Terkirim

Jika Anda mendapat error saat mengirim survey, kemungkinan besar masalahnya adalah **RLS Policy** yang memblokir insert data.

---

## 🚀 Solusi Cepat (3 Langkah)

### **Langkah 1: Jalankan Fix RLS SQL**

1. Buka **Supabase Dashboard**: https://app.supabase.com
2. Pilih project Anda
3. Klik **SQL Editor** → **New Query**
4. Copy-paste seluruh isi file [`fix_rls.sql`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/fix_rls.sql)
5. Klik **Run** atau tekan `Ctrl+Enter`

### **Langkah 2: Verifikasi Policy**

Setelah menjalankan SQL, verifikasi policy sudah benar:

1. Di Supabase Dashboard, klik **Authentication** → **Policies**
2. Pilih tabel `survey_responses`
3. Anda harus melihat 2 policies:
   - ✅ **Enable insert for anonymous users** (untuk INSERT)
   - ✅ **Enable read access for all users** (untuk SELECT)

### **Langkah 3: Test Aplikasi**

1. Restart aplikasi Flutter (hot reload dengan `r`)
2. Isi survey dan klik "Kirim Survey"
3. Cek console untuk melihat log detail
4. Verifikasi data masuk di **Table Editor** → `survey_responses`

---

## 🔍 Debugging

Dengan update terbaru, aplikasi akan menampilkan **log detail** di console:

```
🔄 Memulai pengiriman survey...
✅ Validasi rating berhasil
   Q1: 4, Q2: 3, Q3: 4
📦 Data yang akan dikirim: {question_1_rating: 4, ...}
🌐 Mengirim ke Supabase...
✅ Response dari Supabase: [...]
✅ Survey berhasil dikirim ke Supabase!
```

### **Jika Masih Error:**

Aplikasi akan menampilkan error detail:

#### **Error: "relation does not exist"**
```
⚠️  TABEL BELUM DIBUAT!
```
**Solusi:** Jalankan [`supabase_simple_schema.sql`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/supabase_simple_schema.sql) terlebih dahulu

#### **Error: "JWT expired"**
```
⚠️  API KEY EXPIRED!
```
**Solusi:** Update anon key di [`main.dart`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/lib/main.dart)

#### **Error: "policy"**
```
⚠️  RLS POLICY ERROR!
```
**Solusi:** Jalankan [`fix_rls.sql`](file:///c:/Users/ASUS/.gemini/antigravity/scratch/flutter_survey_app/fix_rls.sql)

---

## 🛠️ Solusi Alternatif: Disable RLS (Untuk Testing)

Jika masih gagal dan Anda ingin testing dulu, **disable RLS sementara**:

```sql
-- Jalankan di SQL Editor
ALTER TABLE survey_responses DISABLE ROW LEVEL SECURITY;
```

> **⚠️ Peringatan:** Ini hanya untuk testing! Untuk production, sebaiknya gunakan RLS yang benar.

---

## ✅ Verifikasi RLS Sudah Benar

Jalankan query ini di SQL Editor untuk cek policy:

```sql
-- Cek policy yang aktif
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'survey_responses';
```

Anda harus melihat:
- Policy untuk **INSERT** dengan roles `{anon, authenticated}`
- Policy untuk **SELECT** dengan roles `{anon, authenticated}`

---

## 📊 Test Manual di Supabase

Untuk memastikan RLS bekerja, test insert manual:

```sql
-- Test insert sebagai anonymous user
INSERT INTO survey_responses (
  question_1_rating, 
  question_2_rating, 
  question_3_rating, 
  additional_comments
) VALUES (4, 3, 4, 'Test manual insert');

-- Cek data
SELECT * FROM survey_responses ORDER BY created_at DESC LIMIT 5;
```

Jika berhasil, berarti RLS sudah OK!

---

## 🎯 Checklist Troubleshooting

- [ ] Tabel `survey_responses` sudah dibuat
- [ ] RLS policy sudah dikonfigurasi dengan benar
- [ ] Test insert manual berhasil
- [ ] Aplikasi Flutter sudah di-restart
- [ ] Console menampilkan log detail
- [ ] Data masuk ke database

---

## 📞 Masih Bermasalah?

Jika masih gagal setelah mengikuti semua langkah:

1. **Screenshot error message** dari console
2. **Copy-paste error detail** yang muncul
3. **Cek network tab** di browser DevTools untuk melihat request ke Supabase

---

**Setelah fix RLS, aplikasi survey Anda akan langsung berfungsi! 🎉**
