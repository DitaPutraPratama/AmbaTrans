# AmbaTrans

Menerjemahkan layar aplikasi apa pun. OCR dan terjemahan jalan di HP lewat Google ML Kit.

## Unduh

Semua versi ada di [Releases](../../releases). Ambil `app-arm64-v8a-release.apk` kecuali HP-mu 32-bit (`armeabi-v7a`). Android 8.0 ke atas.

Kalau Play Protect memblokir: aplikasi ini meminta izin overlay dan tangkap layar, dan Play Protect curiga pada aplikasi di luar Play Store yang meminta itu. Matikan "Pindai aplikasi dengan Play Protect" sebentar (Play Store, ikon profil, Play Protect, gerigi), pasang, lalu nyalakan lagi. Atau pasang dari komputer:

```bash
adb install -r app-arm64-v8a-release.apk
```

## Pakai

Pilih bahasa dan unduh model saat pertama buka, beri izin overlay dan notifikasi, tekan Mulai. Ketuk bubble untuk menerjemahkan layar. Sentuh layar di luar bubble untuk menghapus hasilnya. Tekan lama bubble untuk menutupnya.

Internet hanya dipakai untuk mengunduh model. Screenshot tidak disimpan.

## Jalankan dari source

Butuh Flutter stable (Dart 3.14+), Android SDK, JDK 17+, dan HP dengan USB debugging. Overlay dan tangkap layar diuji di HP, bukan emulator.

```bash
git clone <url-repo>
cd <folder-repo>
flutter pub get
flutter run
```

Tes:

```bash
flutter test
flutter analyze
cd android && ./gradlew testDebugUnitTest ktlintCheck lintDebug   # perlu JAVA_HOME
```

## Rilis

```bash
flutter build apk --release --split-per-abi
```

APK ada di `build/app/outputs/flutter-apk/`. Untuk menerbitkan ke GitHub, naikkan `version:` di `pubspec.yaml` (angka setelah `+` harus naik) lalu jalankan `scripts/release.sh "catatan"`. Perlu `gh` yang sudah login. Satu versi satu release, versi lama tetap ada.

Tanpa `android/key.properties`, APK ditandatangani kunci debug. Pakai satu keystore untuk semua rilis; ganti kunci berarti pemakai harus uninstall dulu.

```properties
storeFile=/path/ke/keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

## Pustaka

- [Flutter](https://github.com/flutter/flutter) dan [material_ui](https://pub.dev/packages/material_ui): BSD-3
- [flutter_riverpod](https://github.com/rrousselGit/riverpod): MIT
- [kotlinx.coroutines](https://github.com/Kotlin/kotlinx.coroutines): Apache-2.0
- [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans): SIL OFL
- [ktlint](https://github.com/pinterest/ktlint): MIT
- [JUnit 4](https://github.com/junit-team/junit4): EPL-1.0
- [MockK](https://github.com/mockk/mockk): Apache-2.0

Daftar paket Dart lengkap ada di `pubspec.lock`.

[Google ML Kit](https://developers.google.com/ml-kit) (Text Recognition, Translation) bukan open source, pakai [syarat layanan Google](https://developers.google.com/ml-kit/terms).

AmbaTrans memakai lisensi [MIT](LICENSE).
