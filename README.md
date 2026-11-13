# AmbaTrans

Menerjemahkan layar aplikasi apa pun lewat bubble melayang. Baca teks (OCR) dan terjemahan berjalan di perangkat, offline setelah model bahasa diunduh (Google ML Kit). Tanpa akun, server, atau iklan.

## Unduh

Semua versi ada di halaman [Releases](../../releases), versi lama tetap tersedia di sana.

Pilih `app-arm64-v8a-release.apk` untuk hampir semua HP (64-bit). `armeabi-v7a` untuk HP 32-bit lama. Butuh Android 8.0 atau lebih baru. Izinkan "instal dari sumber tidak dikenal" saat diminta.

### Diblokir Play Protect?

Muncul pesan "Aplikasi diblokir untuk melindungi perangkat Anda". Ini wajar: Play Protect memblokir aplikasi di luar Play Store yang meminta izin sensitif (Aksesibilitas, tampil di atas aplikasi lain, tangkap layar), dan AmbaTrans memakai ketiganya. Kode sumbernya terbuka di repo ini.

Cara memasang:

1. Matikan sementara: Play Store → ikon profil → Play Protect → ikon gerigi → matikan "Pindai aplikasi dengan Play Protect". Pasang APK, lalu nyalakan lagi.
2. Jika masih diblokir, pasang lewat kabel dari komputer (USB debugging aktif):
   ```bash
   adb install -r app-arm64-v8a-release.apk
   ```

## Pakai

1. Buka aplikasi, pilih bahasa, unduh model, beri izin tampil di atas aplikasi lain dan notifikasi.
2. Tekan Mulai, buka aplikasi lain.
3. Ketuk bubble untuk menerjemahkan layar. Sentuh layar di luar bubble untuk menghapus terjemahan. Tekan lama bubble untuk menutupnya.

Internet hanya dipakai untuk mengunduh model bahasa. Screenshot tidak disimpan.

## Pustaka yang dipakai

| Pustaka | Dipakai untuk | Lisensi |
|---|---|---|
| [Flutter](https://github.com/flutter/flutter) | UI | BSD-3-Clause |
| [material_ui](https://pub.dev/packages/material_ui) | Komponen Material | BSD-3-Clause |
| [flutter_riverpod](https://github.com/rrousselGit/riverpod) | State management | MIT |
| [kotlinx.coroutines](https://github.com/Kotlin/kotlinx.coroutines) | Coroutine di sisi Android | Apache-2.0 |
| [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans) | Font | SIL OFL 1.1 |
| [ktlint](https://github.com/pinterest/ktlint) (plugin Gradle) | Lint Kotlin, hanya saat development | MIT |
| [JUnit 4](https://junit.org/junit4/) dan [MockK](https://github.com/mockk/mockk) | Tes Kotlin, hanya saat development | EPL-1.0 dan Apache-2.0 |

[Google ML Kit](https://developers.google.com/ml-kit) (Text Recognition dan Translation) dipakai untuk OCR dan terjemahan di perangkat. ML Kit bukan open source; pemakaiannya mengikuti [syarat layanan ML Kit](https://developers.google.com/ml-kit/terms).

Daftar lengkap paket Dart ada di `pubspec.lock`.

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
