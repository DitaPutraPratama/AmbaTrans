# AmbaTrans

Aplikasi Android untuk menerjemahkan teks di layar, di aplikasi apa pun. Cocok untuk komik, game, atau aplikasi yang tidak punya pilihan bahasa Indonesia.

Sebuah bubble kecil melayang di atas aplikasi lain. Ketuk bubble itu, lalu AmbaTrans memotret layar, membaca teksnya, menerjemahkan, dan menempelkan hasilnya tepat di atas teks asli. Semua proses jalan di HP. Tidak perlu akun, dan tidak ada data yang dikirim ke server.

## Unduh dan pasang

1. Buka halaman [Releases](../../releases) dan unduh file yang berakhiran `arm64-v8a.apk`, misalnya `AmbaTrans-1.0.0-arm64-v8a.apk`. Kalau HP-mu 32-bit, ambil yang berakhiran `armeabi-v7a.apk`.
2. Buka file APK itu dan izinkan pemasangan dari sumber tidak dikenal kalau diminta.

Butuh Android 8.0 atau lebih baru.

### Kalau diblokir Play Protect

Play Protect sering mencurigai aplikasi di luar Play Store yang meminta izin tampil di atas aplikasi lain dan izin merekam layar. AmbaTrans butuh dua izin itu untuk bubble dan untuk membaca layar.

Cara melewatinya: buka Play Store, ketuk ikon profil, pilih Play Protect, ketuk ikon gerigi, lalu matikan "Pindai aplikasi dengan Play Protect". Pasang APK-nya, lalu nyalakan lagi pengaturan tadi.

Kalau punya komputer, bisa juga lewat kabel USB:

```bash
adb install -r AmbaTrans-1.0.0-arm64-v8a.apk
```

## Cara pakai

1. Buka AmbaTrans. Pilih bahasa asal dan bahasa tujuan, lalu unduh model bahasanya. Ini satu-satunya saat aplikasi butuh internet.
2. Beri izin "Tampil di atas aplikasi lain" dan izin notifikasi.
3. Tekan Mulai. Bubble muncul di pinggir layar.
4. Buka aplikasi yang mau diterjemahkan, lalu ketuk bubble. Saat pertama kali, Android akan bertanya apakah AmbaTrans boleh merekam layar. Pilih izinkan.
5. Terjemahan muncul di atas teks asli. Sentuh layar di mana saja untuk menghapusnya, lalu ketuk bubble lagi untuk halaman berikutnya.

Tekan lama bubble untuk menutupnya. Bahasa bisa diganti kapan saja di Pengaturan.

## Yang perlu diketahui

- Terjemahannya memakai model Google ML Kit yang berjalan offline. Hasilnya bisa kaku, terutama untuk bahasa gaul atau teks bergaya.
- Teks dibaca dari gambar layar. Huruf yang sangat kecil, miring, atau bertumpuk dengan gambar bisa salah baca.
- Huruf yang bisa dibaca: Latin, Mandarin, Jepang, Korea, dan Devanagari (Hindi, Marathi).
- Beberapa aplikasi melarang layarnya direkam, misalnya aplikasi bank dan streaming. Di aplikasi seperti itu AmbaTrans menampilkan pesan "Layar ini tidak dapat ditangkap".
- Tangkapan layar hanya disimpan di memori sampai teksnya selesai dibaca, lalu dibuang. Tidak ada yang tersimpan ke galeri atau penyimpanan.
- Kalau bubble hilang sendiri setelah beberapa lama, izinkan AmbaTrans berjalan tanpa batasan baterai. Pintasannya ada di Pengaturan.

## Untuk pengembang

AmbaTrans dibuat dengan Flutter untuk layar aplikasinya (Home, Onboarding, Pengaturan) dan Kotlin untuk bagian yang berjalan di atas aplikasi lain: bubble, perekaman layar, OCR, terjemahan, dan overlay.

Kebutuhan: Flutter stable (Dart 3.14+), Android SDK, JDK 17+, dan HP Android dengan USB debugging. Bubble dan perekaman layar tidak berjalan baik di emulator, jadi pakai HP sungguhan.

```bash
git clone <url-repo>
cd <folder-repo>
flutter pub get
flutter run
```

Menjalankan tes:

```bash
flutter analyze
flutter test
cd android && ./gradlew testDebugUnitTest ktlintCheck lintDebug   # perlu JAVA_HOME
```

Membuat APK rilis:

```bash
flutter build apk --release --split-per-abi
```

Hasilnya ada di `build/app/outputs/flutter-apk/`. Sebelum merilis versi baru, naikkan `version:` di `pubspec.yaml`. Angka setelah `+` harus lebih besar dari rilis sebelumnya, kalau tidak HP akan menolak update.

APK rilis perlu ditandatangani dengan kunci milikmu sendiri. Buat file `android/key.properties` (jangan di-commit):

```properties
storeFile=/path/ke/keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Tanpa file itu, APK ditandatangani kunci debug. Play Protect lebih curiga pada APK seperti itu, dan pemakai tidak bisa update ke versi yang ditandatangani kunci lain tanpa uninstall dulu. Pakai satu keystore yang sama untuk semua rilis dan simpan cadangannya.

## Pustaka

- [Flutter](https://github.com/flutter/flutter) dan [material_ui](https://pub.dev/packages/material_ui): BSD-3
- [flutter_riverpod](https://github.com/rrousselGit/riverpod): MIT
- [kotlinx.coroutines](https://github.com/Kotlin/kotlinx.coroutines): Apache-2.0
- [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans): SIL OFL
- [ktlint](https://github.com/pinterest/ktlint): MIT
- [JUnit 4](https://github.com/junit-team/junit4): EPL-1.0
- [MockK](https://github.com/mockk/mockk): Apache-2.0

Daftar paket Dart lengkap ada di `pubspec.lock`.

[Google ML Kit](https://developers.google.com/ml-kit) (Text Recognition, Translation) bukan open source dan memakai [syarat layanan Google](https://developers.google.com/ml-kit/terms).

## Lisensi

[MIT](LICENSE).
