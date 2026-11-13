# AmbaTrans

Menerjemahkan layar aplikasi apa pun lewat bubble melayang. Baca teks (OCR) dan terjemahan berjalan di perangkat, offline setelah model bahasa diunduh (Google ML Kit). Tanpa akun, server, atau iklan.

## Unduh

Semua versi ada di halaman [Releases](../../releases), versi lama tetap tersedia di sana.

Pilih `app-arm64-v8a-release.apk` untuk hampir semua HP (64-bit). `armeabi-v7a` untuk HP 32-bit lama. Butuh Android 8.0 atau lebih baru. Izinkan "instal dari sumber tidak dikenal" saat diminta.

## Pakai

1. Buka aplikasi, pilih bahasa, unduh model, beri izin tampil di atas aplikasi lain dan notifikasi.
2. Tekan Mulai, buka aplikasi lain.
3. Ketuk bubble untuk menerjemahkan layar. Sentuh layar di luar bubble untuk menghapus terjemahan. Tekan lama bubble untuk menutupnya.

Internet hanya dipakai untuk mengunduh model bahasa. Screenshot tidak disimpan.

## Jalankan dari source

Butuh Flutter stable (Dart 3.14+), Android SDK, JDK 17+, dan HP Android dengan USB debugging. Uji di HP, bukan emulator.

```bash
git clone <url-repo>
cd <folder-repo>
flutter pub get
flutter run
```

Tes dan lint:

```bash
flutter test
flutter analyze
cd android && ./gradlew testDebugUnitTest ktlintCheck lintDebug   # butuh JAVA_HOME
```

## Build dan rilis

```bash
flutter build apk --release --split-per-abi    # hasil: build/app/outputs/flutter-apk/
```

Naikkan `version:` di `pubspec.yaml` (angka setelah `+` harus naik), lalu:

```bash
scripts/release.sh "catatan rilis"             # build + buat GitHub release (butuh gh)
```

Tiap versi jadi satu release, jadi versi lama tetap bisa diunduh.

APK ditandatangani dengan kunci debug kecuali ada `android/key.properties` (jangan di-commit):

```properties
storeFile=/path/ke/keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Pakai kunci yang sama untuk semua rilis, kalau tidak pembaruan tidak bisa dipasang di atas versi lama.
