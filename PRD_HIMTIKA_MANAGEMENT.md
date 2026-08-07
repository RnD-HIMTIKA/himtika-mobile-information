# Product Requirement Document (PRD)
## Fitur: Dynamic HIMTIKA Management & Integration

---

| Metric | Detail |
| :--- | :--- |
| **Feature Name** | HIMTIKA Admin Management & Dynamic Content |
| **Status** | In Progress (Tahap 1 Selesai / Completed ✅) |
| **Target Version** | v1.1.0 |
| **Author** | HIMTIKA R&D Labs |
| **Platform** | Flutter (Mobile) & Supabase (Backend/Database/Storage) |

---

## 1. Executive Summary (Ringkasan Eksekutif)

Saat ini, data informasi HIMTIKA (Kabinet, Visi-Misi, Sejarah, Daftar Divisi, dan Anggota Pengurus) pada aplikasi **HIMTIKA Mobile Information** disimpan secara *hardcoded* (statis) di dalam kode sumber aplikasi. Hal ini menyulitkan pembaruan data setiap kali ada pergantian kabinet atau perubahan pengurus harian.

Fitur **Dynamic HIMTIKA Management** ini bertujuan untuk mentransformasi modul HIMTIKA menjadi dinamis dengan menyediakan **Panel Admin** bagi Pengurus untuk mengelola seluruh data HIMTIKA melalui **Supabase Database & Storage**. Dengan begitu, data pada aplikasi pengguna mobile akan ter-update secara *real-time* tanpa perlu merilis ulang (*re-deploy*) aplikasi ke app store, **serta tanpa mengubah sedikit pun tampilan UI/UX yang sudah ada.**

---

## 2. Goals & Objectives (Tujuan)

1. **Efisiensi Pengelolaan Data**: Memungkinkan Admin (Pengurus) memperbarui informasi kabinet, visi-misi, sejarah, divisi, dan anggota pengurus langsung dari aplikasi.
2. **Fleksibilitas Bebas Maintenance**: Menghilangkan kebutuhan untuk melakukan *coding* ulang dan rilis *build* baru setiap kali ada pergantian periode kabinet.
3. **Preservasi Desain UI/UX**: Memastikan tampilan UI pada aplikasi mobile 100% konsisten dan identik dengan desain yang sudah ada saat ini.
4. **Pengalaman Pengguna yang Akurat**: Memastikan pengguna selalu mendapatkan informasi kepengurusan HIMTIKA yang paling mutakhir.

---

## 3. User Roles & Access Control (Peran & Hak Akses)

| Role | Hak Akses & Deskripsi |
| :--- | :--- |
| **Mahasiswa / User Umum** | **Read-Only**: Mengakses menu HIMTIKA untuk melihat informasi Kabinet, Visi-Misi, Sejarah, dan struktur pengurus per divisi. |
| **Admin / Pengurus HIMTIKA** | **Read-Write**: Mengakses menu "Kelola HIMTIKA" di Admin Panel untuk melakukan aksi **Create, Read, Update, Delete (CRUD)** data kabinet, divisi, dan pengurus. |

---

## 4. User Stories

### A. Sisi Admin (Pengurus)
* **US-01**: Sebagai Admin, saya ingin mengedit nama kabinet, tagline, logo, dan periode agar informasi kabinet sesuai dengan periode yang berjalan.
* **US-02**: Sebagai Admin, saya ingin memperbarui Visi, Misi, dan Sejarah HIMTIKA jika terjadi perubahan dokumen organisasi.
* **US-03**: Sebagai Admin, saya ingin menambah, mengubah, atau menghapus daftar divisi beserta deskripsi dan logonya.
* **US-04**: Sebagai Admin, saya ingin memasukkan dan mengunggah foto anggota pengurus per divisi beserta jabatan mereka.

### B. Sisi User (Mahasiswa/Umum)
* **US-05**: Sebagai pengguna, saya ingin melihat halaman HIMTIKA yang menyajikan data kabinet dan divisi terbaru yang di-fetch secara dinamis dari server.
* **US-06**: Sebagai pengguna, saya ingin melihat foto dan nama pengurus per divisi dengan waktu muat (*loading*) yang cepat dan tampilan UI yang tetap persis sama seperti sebelumnya.

---

## 5. Database Schema & Storage Design (Supabase)

### A. Supabase Database Tables (Sudah Dibuat & Di-run ✅)

#### 1. Tabel `himtika_kabinet`
Menyimpan informasi tentang kabinet yang sedang aktif.
```sql
CREATE TABLE himtika_kabinet (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_kabinet TEXT NOT NULL,
    tagline TEXT,
    deskripsi TEXT,
    logo_url TEXT,
    periode VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
```

#### 2. Tabel `himtika_about`
Menyimpan informasi Visi, Misi, dan Sejarah HIMTIKA.
```sql
CREATE TABLE himtika_about (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visi TEXT NOT NULL,
    misi JSONB NOT NULL,
    sejarah_text TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
```

#### 3. Tabel `himtika_divisi`
Menyimpan daftar divisi/bagian di HIMTIKA.
```sql
CREATE TABLE himtika_divisi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_divisi TEXT NOT NULL,
    deskripsi TEXT,
    logo_url TEXT,
    urutan INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
```

#### 4. Tabel `himtika_pengurus`
Menyimpan data anggota pengurus per divisi.
```sql
CREATE TABLE himtika_pengurus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    divisi_id UUID REFERENCES himtika_divisi(id) ON DELETE CASCADE,
    nama TEXT NOT NULL,
    jabatan TEXT NOT NULL,
    foto_url TEXT,
    urutan INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
```

### B. Supabase Storage Bucket (Sudah Aktif ✅)
* **Bucket Name**: `division_logos` & `himtika-assets`
* **Folder Structure**:
  * `/kabinet/`: Menyimpan logo dan banner kabinet.
  * `/divisi/`: Menyimpan logo divisi.
  * `/pengurus/`: Menyimpan foto profil anggota pengurus.

---

## 6. Functional Requirements & Feature Flow

### A. Admin Panel Workflow (`lib/features/AdminPanel`)
1. Admin mengakses menu **Admin Panel** → memilih sub-menu **"Kelola HIMTIKA"**.
2. Tersedia 3 Tab/Form Pengelolaan:
   - **Tab 1: Informasi Kabinet & Profil**: Form edit Nama Kabinet, Tagline, Visi-Misi, Sejarah, dan Upload Logo Kabinet.
   - **Tab 2: Kelola Divisi**: Daftar Divisi dengan tombol *Add New Division*, *Edit*, dan *Delete*.
   - **Tab 3: Kelola Pengurus**: Pengelolaan daftar pengurus per divisi (upload foto, input nama & jabatan).
3. Setiap aksi simpan/unggah foto akan memicu unggah file ke Supabase Storage, lalu menyimpan URL publik gambar ke Supabase Database.

### B. Mobile App Client Workflow (`lib/features/himtika`)
1. User menekan menu **HIMTIKA** di `HomePage`.
2. `HimtikaBloc` memanggil `HimtikaRemoteDataSource` untuk melakukan `SELECT` query ke Supabase.
3. UI dirender secara dinamis dengan **tampilan UI 100% sama dengan desain sebelumnya**:
   - [himtika_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/himtika_screen.dart): Menampilkan Kabinet aktif & list divisi dari database.
   - [kabinet_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/kabinet_screen.dart): Menampilkan info kabinet terkini.
   - [divisi_detail_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/divisi_detail_screen.dart): Menampilkan daftar pengurus per divisi sesuai data Supabase.

---

## 7. Non-Functional Requirements

1. **Security & RLS (Row Level Security)**:
   - Public (`anon`) hanya memiliki izin `SELECT` (baca data).
   - Pengguna terautentikasi dengan peran `pengurus` / `admin` memiliki izin `INSERT`, `UPDATE`, `DELETE`.
2. **Performance & Image Optimization**:
   - Gambar yang di-upload oleh admin dikompresi sebelum diunggah (`flutter_image_compress`).
   - Penggunaan `ImageOptimizer.getOptimizedUrl` untuk caching dan kompresi gambar saat render di mobile client.
3. **Offline & Error Handling**:
   - Tampilan *fallback* atau penyimpan sementara (*cached state*) jika koneksi internet pengguna terputus.

---

## 8. Implementation Plan Status (3 Tahap Utama)

Pengembangan dan pengintegrasian fitur ini dibagi menjadi **3 Tahap Utama**:

```mermaid
graph TD
    subgraph TAHAP 1: Setup Backend & Data Layer [SELESAI ✅]
        A1[1.1 Eksekusi SQL Tables di Supabase] --> A2[1.2 Buat Storage Bucket 'division_logos']
        A3[1.3 Buat Model, Entity & RemoteDataSource di Flutter]
        A2 --> A3
        A3 --> A4[1.4 Inisialisasi Dependency Injection & Repository]
    end

    subgraph TAHAP 2: Fitur Admin Panel [SELANJUTNYA ⏳]
        B1[2.1 Tambah Menu 'Kelola HIMTIKA' di Admin Panel] --> B2[2.2 Buat BLoC & State Management Admin]
        B2 --> B3[2.3 Buat UI Form Edit Kabinet, Visi-Misi, Sejarah]
        B3 --> B4[2.4 Buat UI Form CRUD Divisi & Pengurus + Upload Foto]
    end

    subgraph TAHAP 3: Migrasi Client Mobile [AKAN DATANG ⏳]
        C1[3.1 Refactor HimtikaBloc & DivisiDetailBloc] --> C2[3.2 Hubungkan Supabase Data ke UI Existing]
        C2 --> C3[3.3 Verifikasi Tampilan UI 100% Identik dengan Sebelumnya]
        C3 --> C4[3.4 Testing End-to-End Admin to Mobile Client]
    end

    TAHAP 1 --> TAHAP 2
    TAHAP 2 --> TAHAP 3
```

### 📍 TAHAP 1: Setup Backend & Data Integration (SELESAI / COMPLETED ✅)
* **1.1. Setup Database Supabase ✅**: Eksekusi SQL DDL di Supabase untuk membuat 4 tabel (`himtika_kabinet`, `himtika_about`, `himtika_divisi`, `himtika_pengurus`) + RLS Policies + Seed Data.
* **1.2. Setup Storage Supabase ✅**: Bucket `division_logos` sudah siap & berisi aset gambar divisi.
* **1.3. Flutter Data Layer Integration ✅**:
  - `Entities`: [himtika_kabinet.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/domain/entities/himtika_kabinet.dart), [himtika_about.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/domain/entities/himtika_about.dart), [himtika_divisi.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/domain/entities/himtika_divisi.dart), [himtika_pengurus.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/domain/entities/himtika_pengurus.dart).
  - `Models`: [himtika_kabinet_model.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/models/himtika_kabinet_model.dart), [himtika_about_model.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/models/himtika_about_model.dart), [himtika_divisi_model.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/models/himtika_divisi_model.dart), [himtika_pengurus_model.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/models/himtika_pengurus_model.dart).
  - `RemoteDataSource`: [himtika_remote_datasource.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/datasources/himtika_remote_datasource.dart).
  - `Repository`: [himtika_repository.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/domain/repositories/himtika_repository.dart) & [himtika_repository_impl.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/data/repositories/himtika_repository_impl.dart).
  - `Dependency Injection`: [injection_container.dart](file:///c:/RND-09/himtika-mobile-information/lib/core/injection_container.dart#L158-L167).

### 📍 TAHAP 2: Fitur Admin Panel (SELANJUTNYA / PENDING ⏳)
* **2.1. Penambahan Navigation Admin**: Menambahkan opsi menu **"Kelola HIMTIKA"** pada [sidebar.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/AdminPanel/presentation/pages/sidebar.dart) dan [dashboard.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/AdminPanel/presentation/pages/dashboard.dart).
* **2.2. Development Admin BLoC**: Membuat BLoC untuk menangani aksi simpan, edit, hapus, dan upload gambar.
* **2.3. Build Admin UI Screens & Forms**:
  - Screen Edit Kabinet & Profil (Visi, Misi, Sejarah).
  - Screen CRUD Divisi (Tambah/Edit/Hapus Divisi + Upload Logo).
  - Screen CRUD Pengurus (Tambah/Edit/Hapus Pengurus per Divisi + Upload Foto).

### 📍 TAHAP 3: Migrasi Client Mobile (AKAN DATANG / PENDING ⏳)
* **3.1. Development Client BLoC**: Mengubah `HimtikaBloc` & `DivisiDetailBloc` dari data hardcoded ke data dari `HimtikaRemoteDataSource`.
* **3.2. Data Mapping to Existing UI**: Menghubungkan data dinamis Supabase ke layar:
  - [himtika_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/himtika_screen.dart)
  - [about_himtika_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/about_himtika_screen.dart)
  - [kabinet_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/kabinet_screen.dart)
  - [sejarah_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/sejarah_screen.dart)
  - [divisi_detail_screen.dart](file:///c:/RND-09/himtika-mobile-information/lib/features/himtika/presentation/pages/divisi_detail_screen.dart)
* **3.3. Quality Assurance & UI Verification**: Memastikan tampilan UI 100% sama dengan desain awal serta melakukan pengujian alur data dari Admin Panel ke aplikasi pengguna.

---

## 9. Success Metrics (Indikator Keberhasilan)

* Admin berhasil mengubah data Kabinet, Divisi, dan Pengurus dari Admin Panel.
* Perubahan data dari Admin Panel langsung muncul di layar pengguna mobile tanpa perlu merilis *update* baru di toko aplikasi.
* Tampilan UI/UX pada layar mobile pengguna 100% konsisten dengan desain sebelumnya.
* Waktu *load* data HIMTIKA di aplikasi mobile kurang dari 2 detik pada kondisi jaringan stabil.
