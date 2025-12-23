# himtika_mobile_information

## 🚀 Cara Menjalankan Aplikasi

Project ini menggunakan 2 Environment: **Development** (Team) dan **Production** (User).

### Prasyarat
Pastikan Anda memiliki file `.vscode/launch.json` yang berisi konfigurasi `--dart-define`.

### 1. Menjalankan Mode Development (Default untuk Ngoding)
Gunakan konfigurasi "HIMFO (DEV - Majapahit)" di VS Code.
- Terhubung ke: Database `himfo-dev`
- Branch Git: `feat/...` atau `Majapahit`
- Gunakan untuk: Development fitur baru & Testing.

### 2. Menjalankan Mode Production (Hanya untuk Release)
Gunakan konfigurasi "HIMFO (PROD - Live)" di VS Code.
- Terhubung ke: Database Production (Data Asli User!)
- Branch Git: `master`
- **PERINGATAN:** Jangan melakukan tes hapus data sembarangan di sini.

### Workflow Git (SOP)
1.  **Local:** Gunakan `supabase start` untuk generate migrasi SQL.
2.  **Dev:** Push ke branch fitur -> PR ke `Majapahit` untuk deploy ke Dev.
3.  **Prod:** PR dari `Majapahit` ke `master` untuk deploy ke Production.