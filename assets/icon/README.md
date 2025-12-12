# Icon Aplikasi E-IGD

## Cara Setup Icon Aplikasi

1. Buat atau siapkan file icon dengan ukuran **1024x1024 pixels** (PNG format)
2. Simpan file tersebut dengan nama `app_icon.png` di folder ini
3. Icon harus memiliki desain logo E-IGD:
   - Huruf "E" dalam kotak putih dengan background merah
   - Atau logo E-IGD sesuai branding

4. Setelah file icon siap, jalankan command:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

5. Rebuild aplikasi:
   ```bash
   flutter clean
   flutter build apk
   ```

## Catatan
- Icon akan otomatis di-generate untuk berbagai ukuran (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Background adaptive icon menggunakan warna merah E-IGD (#D32F2F)
- Icon akan muncul setelah aplikasi diinstall di device

