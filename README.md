================================================================================
                    DOKUMENTASI LENGKAP APLIKASI E-IGD
          SISTEM GAWAT DARURAT DIGITAL (EMERGENCY DIGITAL SYSTEM)
================================================================================

INFORMASI UMUM APLIKASI
================================================================================
Nama Aplikasi        : E-IGD (Emergency - Instalasi Gawat Darurat Digital)
Versi                : 1.0.0+1
Platform             : Android (Flutter)
Database             : SQLite (Local Database)
State Management     : Provider
Arsitektur           : Clean Architecture (Sederhana)

================================================================================
                        DAFTAR FITUR APLIKASI
================================================================================

1. SPLASH SCREEN
2. AUTHENTICATION (Login & Register)
3. DASHBOARD IGD
4. INPUT/TAMBAH PASIEN (Triage Form)
5. DETAIL PASIEN
6. UPDATE STATUS PASIEN
7. LAPORAN & STATISTIK
8. PENCARIAN & FILTER PASIEN
9. NOTIFIKASI EMERGENCY
10. LOGOUT

================================================================================
                    PENJELASAN DETAIL SETIAP FITUR
================================================================================

1. SPLASH SCREEN
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/splash_page.dart

FUNGSI:
- Menampilkan logo aplikasi E-IGD saat aplikasi pertama kali dibuka
- Memberikan kesan profesional dengan animasi logo
- Otomatis redirect ke halaman Login setelah beberapa detik

FITUR:
- Logo E-IGD dengan desain modern (kotak putih dengan huruf E merah)
- Background gradient merah sesuai tema aplikasi
- Animasi loading indicator
- Auto-navigation ke halaman login

CARA KERJA:
- Saat aplikasi dibuka, splash screen muncul selama 2-3 detik
- Setelah itu otomatis mengarahkan ke halaman Login


2. AUTHENTICATION (Login & Register)
--------------------------------------------------------------------------------
Lokasi File: 
- lib/features/auth/presentation/pages/login_page.dart
- lib/features/auth/presentation/pages/register_page.dart

FUNGSI LOGIN:
- Halaman untuk masuk ke aplikasi
- Validasi input email dan password
- Toggle visibility password (show/hide)
- Navigasi ke halaman Register untuk pengguna baru
- Setelah login berhasil, redirect ke Home Page

FITUR LOGIN:
- Input field Email dengan validasi format email
- Input field Password dengan toggle visibility
- Tombol "Masuk" untuk proses login
- Link "Belum punya akun? Daftar" untuk navigasi ke Register
- Validasi form (email wajib, password minimal 6 karakter)
- Loading indicator saat proses login
- UI modern dengan gradient merah dan logo E-IGD di tengah

FUNGSI REGISTER:
- Halaman untuk membuat akun baru
- Validasi semua field input
- Konfirmasi password harus sama dengan password

FITUR REGISTER:
- Input field Nama Lengkap (wajib diisi)
- Input field Email dengan validasi format
- Input field Password dengan toggle visibility
- Input field Konfirmasi Password dengan validasi harus sama
- Tombol "Daftar" untuk proses registrasi
- Link "Sudah punya akun? Masuk" untuk kembali ke Login
- Validasi lengkap semua field
- Loading indicator saat proses registrasi
- UI modern dengan card form yang rounded top

CATATAN PENTING:
- Login dan Register saat ini hanya UI saja (tidak ada backend authentication)
- Data tidak disimpan secara permanen
- Setelah login/register, langsung masuk ke aplikasi


3. DASHBOARD IGD
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/dashboard_page.dart

FUNGSI UTAMA:
- Menampilkan overview semua pasien yang terdaftar
- Menampilkan statistik pasien secara real-time
- Menampilkan notifikasi emergency untuk pasien prioritas tinggi
- Menyediakan akses cepat ke fitur-fitur utama

FITUR DASHBOARD:

A. HEADER & NAVIGATION
   - Logo E-IGD di AppBar
   - Tombol Logout di kanan atas AppBar
   - Bottom Navigation Bar dengan 2 tab: Dashboard dan Laporan

B. NOTIFIKASI EMERGENCY BANNER
   - Banner merah yang muncul otomatis jika ada pasien MERAH dengan status MENUNGGU
   - Menampilkan pesan: "Ada pasien emergency yang belum ditangani"
   - Bisa diklik untuk langsung filter pasien MERAH
   - Auto-scroll ke daftar pasien setelah diklik
   - Icon warning dan arrow indicator

C. HEADER SUMMARY CARD
   - Card besar dengan gradient merah
   - Menampilkan "Total Pasien" dengan angka besar
   - Icon people untuk visualisasi
   - Menampilkan info filter jika ada filter aktif
   - Menunjukkan jumlah pasien yang ditampilkan vs total

D. QUICK STATISTICS CARDS
   - Card "Menunggu": Menampilkan jumlah pasien dengan status MENUNGGU
   - Card "Selesai": Menampilkan jumlah pasien dengan status SELESAI
   - Warna berbeda untuk setiap status (orange untuk menunggu, hijau untuk selesai)
   - Icon dan angka besar untuk mudah dibaca

E. STATISTIK TRIAGE
   - Card statistik yang menampilkan distribusi pasien berdasarkan triage
   - Tiga kategori: MERAH, KUNING, HIJAU
   - Setiap kategori menampilkan:
     * Label kategori dengan warna sesuai
     * Jumlah pasien dalam badge
     * Progress bar persentase
     * Persentase dalam angka
   - Visualisasi yang mudah dipahami dengan progress bar

F. PENCARIAN & FILTER
   - Search bar untuk mencari pasien berdasarkan nama
   - Filter chips untuk filter berdasarkan kategori triage:
     * Semua (menampilkan semua pasien)
     * MERAH (hanya pasien triage merah)
     * KUNING (hanya pasien triage kuning)
     * HIJAU (hanya pasien triage hijau)
   - Search dan filter bisa dikombinasikan
   - Real-time filtering saat mengetik

G. DAFTAR PASIEN
   - Menampilkan semua pasien dalam bentuk card
   - Urutan prioritas: MERAH → KUNING → HIJAU
   - Jika sama kategori, diurutkan berdasarkan waktu kedatangan (terbaru dulu)
   - Setiap card menampilkan:
     * Nama pasien
     * Usia dan jenis kelamin
     * Kategori triage dengan badge berwarna
     * Status penanganan dengan chip berwarna
     * Waktu kedatangan
   - Klik card untuk melihat detail pasien
   - Empty state jika tidak ada pasien

H. FLOATING ACTION BUTTON
   - Tombol "Tambah Pasien" di kanan bawah
   - Warna merah sesuai tema
   - Navigasi ke halaman form tambah pasien

FITUR TAMBAHAN:
- Pull to refresh untuk reload data
- Auto-refresh saat kembali dari halaman detail
- Error handling dengan pesan error yang jelas
- Loading indicator saat memuat data


4. INPUT/TAMBAH PASIEN (Triage Form)
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/patient_form_page.dart

FUNGSI:
- Form untuk menambahkan pasien baru ke sistem
- Form untuk mengedit data pasien yang sudah ada
- Validasi semua field yang wajib diisi
- Auto-generate waktu kedatangan

FITUR FORM:

A. FIELD INPUT:
   1. Nama Pasien (Text Field)
      - Wajib diisi
      - Validasi: tidak boleh kosong
      
   2. Usia (Text Field)
      - Wajib diisi
      - Validasi: harus berupa angka
      - Input type: number
      
   3. Jenis Kelamin (Dropdown)
      - Pilihan: Laki-laki / Perempuan
      - Default: Laki-laki
      
   4. Keluhan Utama (Text Field)
      - Opsional (boleh kosong)
      - Multi-line text input
      
   5. Kategori Triage (Dropdown)
      - Wajib dipilih
      - Pilihan: MERAH / KUNING / HIJAU
      - Validasi: harus dipilih
      - Warna sesuai kategori
      
   6. Waktu Kedatangan (Auto-generated)
      - Otomatis diisi dengan DateTime.now()
      - Format: dd/MM/yyyy HH:mm
      - Tidak bisa diubah manual

B. VALIDASI:
   - Semua field wajib divalidasi sebelum submit
   - Pesan error muncul di bawah field yang error
   - Form tidak bisa disubmit jika ada error

C. PROTEKSI EDIT:
   - Jika pasien sudah berstatus "SELESAI", form tidak bisa diedit
   - Muncul pesan error dan otomatis kembali ke halaman sebelumnya
   - Mencegah perubahan data pasien yang sudah selesai ditangani

D. TOMBOL AKSI:
   - Tombol "Simpan" untuk menyimpan data
   - Tombol "Batal" untuk membatalkan dan kembali
   - Loading indicator saat proses save

CARA KERJA:
1. User klik tombol "Tambah Pasien" di dashboard
2. Form muncul dengan field kosong
3. User isi semua field yang wajib
4. Klik "Simpan"
5. Data tersimpan ke database lokal
6. Otomatis kembali ke dashboard dengan data terbaru


5. DETAIL PASIEN
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/patient_detail_page.dart

FUNGSI:
- Menampilkan informasi lengkap seorang pasien
- Update status penanganan pasien
- Input/edit petugas penanggung jawab
- Edit data pasien
- Hapus pasien (opsional)

FITUR DETAIL:

A. INFORMASI PASIEN:
   - Nama Pasien
   - Usia
   - Jenis Kelamin
   - Keluhan Utama
   - Kategori Triage (dengan badge berwarna)
   - Status Penanganan (dengan chip berwarna)
   - Petugas Penanggung Jawab
   - Waktu Kedatangan
   - Created At & Updated At

B. ALERT EMERGENCY:
   - Jika pasien MERAH dan status MENUNGGU
   - Muncul banner merah besar dengan pesan:
     "EMERGENCY CASE – PRIORITAS TINGGI"
   - Alert sangat mencolok untuk menarik perhatian

C. UPDATE STATUS:
   - Dialog untuk update status penanganan
   - Pilihan status: MENUNGGU, DITANGANI, SELESAI
   - Input field untuk Petugas Penanggung Jawab
   - Tombol "Simpan" untuk menyimpan perubahan
   - Tombol "Batal" untuk membatalkan
   - Setelah update, dashboard otomatis refresh

D. TOMBOL AKSI:
   - Tombol "Update Status" (muncul jika status belum SELESAI)
   - Tombol "Edit" (muncul jika status belum SELESAI)
   - Tombol "Hapus Pasien" (opsional, dengan konfirmasi)

E. PROTEKSI:
   - Jika status sudah "SELESAI":
     * Tombol "Update Status" hilang
     * Tombol "Edit" hilang
     * Data tidak bisa diubah
   - Mencegah perubahan data pasien yang sudah selesai

F. NAVIGASI:
   - Klik "Edit" → navigasi ke form edit
   - Setelah edit/update → kembali ke detail dengan data terbaru
   - Dashboard otomatis refresh setelah perubahan


6. UPDATE STATUS PASIEN
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/patient_detail_page.dart

FUNGSI:
- Mengubah status penanganan pasien
- Menambahkan/mengubah petugas penanggung jawab
- Update waktu updated_at otomatis

FITUR:
- Dialog popup untuk update status
- Dropdown pilihan status:
  * MENUNGGU (orange)
  * DITANGANI (blue)
  * SELESAI (green)
- Input field Petugas Penanggung Jawab
- Validasi: Status wajib dipilih
- Auto-update timestamp
- Refresh dashboard setelah update

ALUR KERJA:
1. User buka detail pasien
2. Klik tombol "Update Status"
3. Dialog muncul dengan dropdown status dan field petugas
4. Pilih status baru dan isi petugas (opsional)
5. Klik "Simpan"
6. Status terupdate di database
7. Halaman detail refresh dengan data baru
8. Dashboard juga otomatis refresh


7. LAPORAN & STATISTIK
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/report_page.dart

FUNGSI:
- Menampilkan laporan harian pasien
- Statistik pasien berdasarkan tanggal tertentu
- Analisis data berdasarkan triage dan status

FITUR LAPORAN:

A. DATE PICKER:
   - Tombol untuk memilih tanggal
   - Default: tanggal hari ini
   - Format tampilan: dd MMMM yyyy (contoh: 15 Desember 2024)
   - Icon kalender untuk visualisasi

B. HERO CARD TOTAL PASIEN:
   - Card besar dengan gradient merah
   - Menampilkan total pasien pada tanggal terpilih
   - Angka besar dan mudah dibaca
   - Icon untuk visualisasi

C. STATISTIK TRIAGE:
   - Card untuk setiap kategori triage (MERAH, KUNING, HIJAU)
   - Setiap card menampilkan:
     * Label kategori dengan warna
     * Jumlah pasien
     * Progress bar persentase
     * Persentase dalam angka
   - Visualisasi yang informatif

D. STATISTIK STATUS:
   - Card untuk setiap status (MENUNGGU, DITANGANI, SELESAI)
   - Setiap card menampilkan:
     * Label status dengan warna
     * Jumlah pasien
     * Progress bar persentase
     * Persentase dalam angka
   - Warna berbeda untuk setiap status

E. EMPTY STATE:
   - Jika tidak ada pasien pada tanggal terpilih
   - Menampilkan pesan informatif
   - Icon untuk visualisasi

F. AUTO-RELOAD:
   - Otomatis reload saat tanggal diubah
   - Loading indicator saat memproses data

CARA KERJA:
1. User buka tab "Laporan" di bottom navigation
2. Halaman laporan muncul dengan data hari ini
3. User klik tombol tanggal untuk memilih tanggal lain
4. Date picker muncul
5. User pilih tanggal
6. Data otomatis reload sesuai tanggal terpilih
7. Statistik ditampilkan dengan visualisasi yang jelas


8. PENCARIAN & FILTER PASIEN
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/dashboard_page.dart

FUNGSI PENCARIAN:
- Mencari pasien berdasarkan nama
- Real-time search (hasil muncul saat mengetik)
- Case-insensitive (tidak membedakan huruf besar/kecil)

FITUR PENCARIAN:
- Search bar dengan icon search
- Placeholder: "Cari pasien..."
- Tombol clear (X) muncul saat ada teks
- Hasil filter langsung terlihat
- Bisa dikombinasikan dengan filter triage

FUNGSI FILTER:
- Filter pasien berdasarkan kategori triage
- Filter chips yang bisa diklik
- Visual feedback untuk filter aktif
- Bisa dikombinasikan dengan search

FITUR FILTER:
- Filter chip "Semua" (menampilkan semua pasien)
- Filter chip "MERAH" (hanya pasien triage merah)
- Filter chip "KUNING" (hanya pasien triage kuning)
- Filter chip "HIJAU" (hanya pasien triage hijau)
- Chip aktif memiliki warna berbeda
- Scroll horizontal jika banyak filter

KOMBINASI SEARCH & FILTER:
- Search dan filter bisa digunakan bersamaan
- Contoh: Search "Budi" + Filter "MERAH" = hanya pasien bernama Budi dengan triage MERAH
- Real-time update saat mengetik atau mengubah filter


9. NOTIFIKASI EMERGENCY
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/dashboard_page.dart

FUNGSI:
- Memberikan peringatan visual jika ada pasien emergency yang belum ditangani
- Quick access ke daftar pasien emergency

FITUR:
- Banner merah yang muncul otomatis di atas dashboard
- Kondisi muncul: Ada pasien dengan triage MERAH dan status MENUNGGU
- Pesan: "Ada pasien emergency yang belum ditangani"
- Icon warning untuk menarik perhatian
- Icon arrow untuk indikasi bisa diklik

FUNGSI KLIK BANNER:
- Saat banner diklik:
  1. Clear semua search query
  2. Set filter ke MERAH
  3. Auto-scroll ke daftar pasien
  4. Menampilkan hanya pasien emergency

VISUAL:
- Background gradient merah
- Text putih bold
- Shadow untuk efek depth
- Border radius untuk tampilan modern
- Margin yang tepat untuk spacing


10. LOGOUT
--------------------------------------------------------------------------------
Lokasi File: lib/features/emergency/presentation/pages/dashboard_page.dart

FUNGSI:
- Keluar dari aplikasi dan kembali ke halaman login
- Membersihkan session (jika ada)

FITUR:
- Tombol logout di AppBar (icon logout)
- Dialog konfirmasi sebelum logout
- Pesan: "Apakah Anda yakin ingin keluar dari aplikasi?"
- Tombol "Batal" untuk membatalkan
- Tombol "Logout" untuk konfirmasi
- Setelah logout, navigasi ke login dengan clear stack
- Tidak bisa kembali dengan back button setelah logout

ALUR KERJA:
1. User klik icon logout di AppBar
2. Dialog konfirmasi muncul
3. User pilih "Batal" atau "Logout"
4. Jika "Logout", aplikasi navigasi ke halaman login
5. Semua route sebelumnya dihapus dari stack


================================================================================
                    FITUR TEKNIS & ARSITEKTUR
================================================================================

1. DATABASE LOKAL (SQLite)
--------------------------------------------------------------------------------
Nama Database: emergency.db
Tabel: patients

Struktur Tabel:
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- nama (TEXT)
- usia (INTEGER)
- jenis_kelamin (TEXT)
- keluhan_utama (TEXT)
- kategori_triage (TEXT) - MERAH/KUNING/HIJAU
- status_penanganan (TEXT) - MENUNGGU/DITANGANI/SELESAI
- petugas (TEXT nullable)
- waktu_kedatangan (TEXT)
- created_at (TEXT)
- updated_at (TEXT)

Fungsi Database:
- insertPatient() - Menambah pasien baru
- getAllPatients() - Mengambil semua pasien
- getPatientById() - Mengambil pasien by ID
- getPatientsByDate() - Mengambil pasien berdasarkan tanggal
- updatePatient() - Update data pasien
- deletePatient() - Hapus pasien (opsional)


2. STATE MANAGEMENT (Provider)
--------------------------------------------------------------------------------
Notifier yang digunakan:
- PatientListNotifier: Mengelola daftar pasien, search, filter
- PatientDetailNotifier: Mengelola detail satu pasien

Fungsi Notifier:
- Load data dari database
- Update state
- Handle error
- Filter dan sort data
- Notify listeners untuk update UI


3. CLEAN ARCHITECTURE
--------------------------------------------------------------------------------
Struktur Folder:
- data/ - Data layer (database, models, repositories)
- domain/ - Business logic (entities, use cases, repositories interface)
- presentation/ - UI layer (pages, providers, widgets)

Keuntungan:
- Separation of concerns
- Easy to test
- Easy to maintain
- Scalable


4. WIDGET REUSABLE
--------------------------------------------------------------------------------
Widget yang bisa digunakan ulang:
- AppLogo - Logo E-IGD
- TriageBadge - Badge untuk kategori triage
- StatusChip - Chip untuk status penanganan
- PatientCard - Card untuk menampilkan pasien
- PrimaryButton - Tombol dengan style konsisten
- EmptyState - Tampilan saat tidak ada data


================================================================================
                        FITUR KEAMANAN & VALIDASI
================================================================================

1. VALIDASI FORM:
   - Semua field wajib divalidasi
   - Pesan error yang jelas
   - Tidak bisa submit jika ada error

2. PROTEKSI DATA:
   - Pasien dengan status SELESAI tidak bisa diubah
   - Tombol edit/update hilang untuk pasien SELESAI
   - Validasi di form dan detail page

3. ERROR HANDLING:
   - Try-catch di semua operasi database
   - Pesan error yang user-friendly
   - Loading state untuk feedback ke user


================================================================================
                        FITUR UI/UX
================================================================================

1. DESAIN MODERN:
   - Material Design 3
   - Gradient colors
   - Rounded corners
   - Shadows untuk depth
   - Smooth animations

2. WARNA TRIAGE:
   - MERAH: #D32F2F (Emergency)
   - KUNING: #F57C00 (Urgent)
   - HIJAU: #388E3C (Non-urgent)

3. WARNA STATUS:
   - MENUNGGU: Orange
   - DITANGANI: Blue
   - SELESAI: Green

4. RESPONSIVE:
   - CustomScrollView untuk mencegah overflow
   - Sliver widgets untuk performa baik
   - Pull to refresh
   - Empty states

5. NAVIGATION:
   - Bottom navigation untuk tab utama
   - Named routes untuk navigasi
   - Back button handling
   - Clear navigation stack saat logout


================================================================================
                        FITUR TAMBAHAN
================================================================================

1. AUTO-SORT:
   - Pasien diurutkan berdasarkan prioritas triage
   - MERAH → KUNING → HIJAU
   - Jika sama, diurutkan berdasarkan waktu (terbaru dulu)

2. AUTO-REFRESH:
   - Dashboard refresh setelah update/delete pasien
   - Detail page refresh setelah update
   - Report page refresh setelah ganti tanggal

3. DATE FORMATTING:
   - Format Indonesia (dd/MM/yyyy)
   - Format waktu (HH:mm)
   - Localization support

4. PULL TO REFRESH:
   - Swipe down untuk refresh data
   - Loading indicator saat refresh
   - Warna sesuai tema

5. EMPTY STATES:
   - Pesan informatif saat tidak ada data
   - Icon untuk visualisasi
   - Konsisten di semua halaman


================================================================================
                        CARA MENGGUNAKAN APLIKASI
================================================================================

1. PERTAMA KALI MEMBUKA:
   - Splash screen muncul
   - Otomatis redirect ke Login

2. LOGIN/REGISTER:
   - Isi email dan password
   - Atau daftar akun baru
   - Klik "Masuk" atau "Daftar"

3. DASHBOARD:
   - Lihat overview semua pasien
   - Cari pasien dengan search bar
   - Filter dengan filter chips
   - Klik card pasien untuk detail

4. TAMBAH PASIEN:
   - Klik tombol "Tambah Pasien" (FAB)
   - Isi form dengan data pasien
   - Pilih kategori triage
   - Klik "Simpan"

5. UPDATE STATUS:
   - Buka detail pasien
   - Klik "Update Status"
   - Pilih status baru
   - Isi petugas (opsional)
   - Klik "Simpan"

6. LAPORAN:
   - Klik tab "Laporan" di bottom navigation
   - Pilih tanggal dengan date picker
   - Lihat statistik pasien

7. LOGOUT:
   - Klik icon logout di AppBar
   - Konfirmasi logout
   - Kembali ke halaman login


================================================================================
                        TEKNOLOGI YANG DIGUNAKAN
================================================================================

1. Flutter SDK (>=3.2.3)
2. Dart Language
3. sqflite (SQLite untuk Flutter)
4. path (Path utilities)
5. provider (State management)
6. intl (Internationalization & Date formatting)
7. flutter_launcher_icons (App icon generator)


================================================================================
                        CATATAN PENTING
================================================================================

1. APLIKASI OFFLINE:
   - Semua data disimpan lokal
   - Tidak memerlukan internet
   - Tidak ada backend/API

2. AUTHENTICATION:
   - Login dan Register saat ini hanya UI
   - Tidak ada validasi backend
   - Tidak ada session management

3. DATA PERSISTENCE:
   - Data tersimpan di SQLite
   - Data tidak hilang saat app ditutup
   - Data bisa dihapus dengan uninstall app

4. PLATFORM:
   - Fokus untuk Android
   - iOS dan Web bisa di-support dengan sedikit modifikasi


================================================================================
                        KESIMPULAN
================================================================================

Aplikasi E-IGD adalah sistem gawat darurat digital yang lengkap dengan fitur:
- Manajemen pasien (CRUD)
- Sistem triage (MERAH/KUNING/HIJAU)
- Tracking status penanganan
- Laporan dan statistik
- Pencarian dan filter
- Notifikasi emergency
- UI/UX modern dan user-friendly

Aplikasi ini dirancang untuk digunakan di lingkungan rumah sakit atau klinik
untuk mengelola pasien gawat darurat secara digital dan efisien.

================================================================================
                        END OF DOCUMENTATION
================================================================================

