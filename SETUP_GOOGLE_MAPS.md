# Setup Google Maps API Key

Untuk menggunakan fitur Layanan Ambulans dengan Google Maps, Anda perlu membuat Google Maps API Key.

## Langkah-langkah Setup

### 1. Buat Project di Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Login dengan akun Google Anda
3. Klik "Select a project" → "New Project"
4. Isi nama project (contoh: "E-IGD Maps")
5. Klik "Create"

### 2. Enable Google Maps SDK

1. Di Google Cloud Console, pilih project yang baru dibuat
2. Buka menu "APIs & Services" → "Library"
3. Cari "Maps SDK for Android"
4. Klik dan pilih "Enable"
5. (Opsional) Cari "Geocoding API" dan enable juga untuk fitur reverse geocoding

### 3. Buat API Key

1. Buka "APIs & Services" → "Credentials"
2. Klik "Create Credentials" → "API Key"
3. Copy API Key yang dibuat

### 4. Restrict API Key (Recommended untuk Production)

1. Klik pada API Key yang baru dibuat
2. Di bagian "Application restrictions":
   - Pilih "Android apps"
   - Klik "Add an item"
   - Masukkan package name: `com.example.myapp`
   - Masukkan SHA-1 certificate fingerprint (untuk debug, jalankan: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
3. Di bagian "API restrictions":
   - Pilih "Restrict key"
   - Pilih "Maps SDK for Android" dan "Geocoding API"
4. Klik "Save"

### 5. Tambahkan API Key ke Aplikasi

1. Buka file: `android/app/src/main/AndroidManifest.xml`
2. Cari baris:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
   ```
3. Ganti `YOUR_GOOGLE_MAPS_API_KEY_HERE` dengan API Key Anda

### 6. Test Aplikasi

1. Jalankan `flutter clean`
2. Jalankan `flutter pub get`
3. Build dan run aplikasi
4. Test fitur Layanan Ambulans

## Catatan Penting

- **Free Tier**: Google Maps menyediakan $200 credit gratis per bulan
- **Billing**: Perlu setup billing account, tapi ada free tier yang cukup untuk development
- **Quota**: Perhatikan quota penggunaan untuk menghindari biaya tak terduga
- **Security**: Selalu restrict API Key untuk production

## Troubleshooting

### Error: "API key not valid"
- Pastikan API Key sudah di-copy dengan benar
- Pastikan Maps SDK for Android sudah di-enable
- Pastikan package name di AndroidManifest sesuai dengan yang di-restrict

### Error: "This IP, site or mobile application is not authorized"
- Pastikan API Key restriction sudah di-set dengan benar
- Untuk Android, pastikan SHA-1 fingerprint sudah ditambahkan

### Maps tidak muncul
- Pastikan internet connection aktif
- Pastikan permission location sudah diberikan
- Check logcat untuk error detail

## Alternatif (Tanpa Google Maps API Key)

Jika tidak ingin menggunakan Google Maps (berbayar), bisa menggunakan:
- OpenStreetMap dengan library `flutter_map` (gratis)
- Atau hanya input alamat manual tanpa peta

