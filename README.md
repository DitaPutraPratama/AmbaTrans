<div align="center">
<img src="android/app/src/main/res/drawable-nodpi/splash_logo.png" width="200" alt="Logo AmbaTrans">
<h1>AmbaTrans</h1>
Terjemahkan teks di layar aplikasi apa pun, langsung di atas teks aslinya.<br>
Untuk komik, game, dan aplikasi yang tidak punya pilihan bahasa Indonesia. Offline, tanpa akun, gratis.
<br>
<br>
<a href="https://github.com/DitaPutraPratama/AmbaTrans/releases/latest"><img src="https://img.shields.io/github/v/release/DitaPutraPratama/AmbaTrans" alt="Versi terbaru"></a>
<a href="https://github.com/DitaPutraPratama/AmbaTrans/releases"><img src="https://img.shields.io/github/downloads/DitaPutraPratama/AmbaTrans/total" alt="Total unduhan"></a>
<a href="LICENSE"><img src="https://img.shields.io/github/license/DitaPutraPratama/AmbaTrans" alt="Lisensi"></a>
<img src="https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white" alt="Android 8.0+">
<h4>Unduh</h4>
<a href="https://github.com/DitaPutraPratama/AmbaTrans/releases/latest"><img src="https://img.shields.io/badge/Unduh_APK-GitHub_Releases-181717?style=for-the-badge&logo=github" alt="Unduh APK dari GitHub Releases"></a>
</div>

> Tidak ada di Play Store. AmbaTrans dibagikan sebagai APK di halaman [Releases](https://github.com/DitaPutraPratama/AmbaTrans/releases).

## Fitur ✨

- Bubble melayang di atas aplikasi apa pun: ketuk sekali, terjemahan muncul tepat di atas teks asli
- Mode **Sebagian layar**: tarik kotak di area yang mau diterjemahkan, geser atau ubah ukurannya lewat sudut kotak, lalu tekan Terjemahkan. Teks di dalam kotak diterjemahkan sebagai satu kalimat, pas untuk gelembung komik (BARU)
- Tekan lama bubble untuk memilih mode Seluruh layar atau Sebagian layar. Pilihan tetap tersimpan walaupun AmbaTrans dimatikan (BARU)
- Satu gelembung teks yang terbaca per baris digabung jadi satu kalimat, termasuk kata yang terputus tanda sambung seperti "ber-main" (BARU)
- Atur warna teks, warna latar, dan opasitas latar terjemahan, lengkap dengan pratinjau (BARU)
- Seret bubble ke tanda X di bawah layar untuk mematikan AmbaTrans (BARU)
- Notifikasi "AmbaTrans aktif" boleh dimatikan, bubble tetap jalan (BARU)
- Membaca teks dan menerjemahkan sepenuhnya di HP dengan Google ML Kit, tanpa server dan tanpa akun
- Membaca huruf Latin, Mandarin, Jepang, Korea, dan Devanagari (Hindi, Marathi)
- Pilih bahasa asal dan bahasa tujuan; model bahasa cukup diunduh sekali
- Halaman tetap bisa di-scroll; sentuh layar di mana saja untuk menghapus terjemahan

> **Catatan**
> Terjemahan memakai model offline Google ML Kit, jadi hasilnya bisa kaku, terutama untuk bahasa gaul atau teks bergaya. Huruf yang sangat kecil, miring, atau bertumpuk dengan gambar bisa salah baca. Kalau menemukan masalah, buat [issue](https://github.com/DitaPutraPratama/AmbaTrans/issues).

## Unduh dan pasang

1. Buka [rilis terbaru](https://github.com/DitaPutraPratama/AmbaTrans/releases/latest) dan pilih APK yang cocok:
   - `AmbaTrans-<versi>-arm64-v8a.apk`: untuk hampir semua HP Android sekarang. Kalau ragu, ambil yang ini.
   - `AmbaTrans-<versi>-armeabi-v7a.apk`: untuk HP lama (32-bit).
2. Buka file APK itu dan izinkan pemasangan dari sumber tidak dikenal kalau diminta.

Butuh Android 8.0 atau lebih baru. Untuk memastikan file tidak rusak, cocokkan hash-nya dengan `SHA256SUMS.txt` di halaman rilis.

### Kalau diblokir Play Protect

Play Protect sering mencurigai aplikasi di luar Play Store yang meminta izin tampil di atas aplikasi lain dan izin merekam layar. AmbaTrans butuh dua izin itu untuk bubble dan untuk membaca layar.

Cara melewatinya: buka Play Store, ketuk ikon profil, pilih Play Protect, ketuk ikon gerigi, lalu matikan "Pindai aplikasi dengan Play Protect". Pasang APK-nya, lalu nyalakan lagi pengaturan tadi.

Kalau punya komputer, bisa juga lewat kabel USB:

```bash
adb install -r AmbaTrans-<versi>-arm64-v8a.apk
```

## Cara pakai

1. Buka AmbaTrans. Pilih bahasa asal dan bahasa tujuan, lalu unduh model bahasanya. Hanya di langkah ini aplikasi butuh internet.
2. Beri izin "Tampil di atas aplikasi lain". Izin notifikasi boleh dilewati.
3. Tekan **Mulai**. Bubble muncul di pinggir layar.
4. Buka aplikasi yang mau diterjemahkan, lalu ketuk bubble. Saat pertama kali, Android bertanya apakah AmbaTrans boleh merekam layar. Pilih izinkan.
5. Terjemahan muncul di atas teks asli. Sentuh layar di mana saja untuk menghapusnya, lalu ketuk bubble lagi untuk halaman berikutnya.

| Gerakan pada bubble | Hasilnya |
|---|---|
| Ketuk | Terjemahkan (seluruh layar, atau buka kotak pilihan di mode Sebagian) |
| Tekan lama | Pilih mode: Seluruh layar / Sebagian layar |
| Seret | Pindahkan bubble; bubble menempel ke pinggir kiri atau kanan |
| Seret ke tanda X di bawah | Matikan AmbaTrans |

Di mode Sebagian, tekan **Batal**, tombol Kembali, atau ketuk di luar kotak untuk membatalkan.

Bahasa, warna terjemahan, dan izin bisa diubah kapan saja di **Pengaturan**.

## Privasi

- Tidak ada akun, iklan, pelacak, atau server. Satu-satunya akses internet adalah unduhan model bahasa ML Kit.
- Tangkapan layar hanya ada di memori sampai teksnya selesai dibaca, lalu dibuang. Tidak ada yang disimpan ke galeri atau penyimpanan.
- Pengaturan disimpan di HP saja.
- Beberapa aplikasi melarang layarnya direkam, misalnya aplikasi bank dan streaming. Di aplikasi seperti itu AmbaTrans menampilkan "Layar ini tidak dapat ditangkap".

## FAQ

#### 1. Bubble hilang sendiri setelah beberapa lama?
Sebagian merek HP mematikan aplikasi di latar belakang untuk menghemat baterai. Izinkan AmbaTrans berjalan tanpa batasan baterai. Pintasannya ada di Pengaturan → Lanjutan.

#### 2. Teks satu gelembung terpecah jadi beberapa terjemahan?
Pakai mode Sebagian: tekan lama bubble, pilih Sebagian layar, lalu kotakkan gelembungnya. Semua teks di dalam kotak diterjemahkan sebagai satu kalimat.

#### 3. Terjemahan menutupi gambar terlalu pekat atau terlalu tipis?
Atur warna dan opasitas latarnya di Pengaturan → Tampilan terjemahan. Opasitas maksimal dibatasi Android supaya layar di bawahnya tetap bisa disentuh.

#### 4. Ada bagian kalimat yang tidak ikut diterjemahkan?
Itu keterbatasan model terjemahan offline ML Kit. Coba mode Sebagian supaya kalimatnya terbaca utuh.

## Untuk pengembang

AmbaTrans dibuat dengan Flutter untuk layar aplikasinya (Home, Onboarding, Pengaturan) dan Kotlin untuk bagian yang berjalan di atas aplikasi lain: bubble, perekaman layar, OCR, terjemahan, dan overlay.

Kebutuhan: Flutter stable (Dart 3.14+), Android SDK, JDK 17+, dan HP Android dengan USB debugging. Bubble dan perekaman layar tidak berjalan baik di emulator, jadi pakai HP sungguhan.

```bash
git clone https://github.com/DitaPutraPratama/AmbaTrans.git
cd AmbaTrans
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
- [Material Icons](https://github.com/google/material-design-icons) (ikon mode): Apache-2.0
- [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans): SIL OFL
- [ktlint](https://github.com/pinterest/ktlint): MIT
- [JUnit 4](https://github.com/junit-team/junit4): EPL-1.0
- [MockK](https://github.com/mockk/mockk): Apache-2.0

Daftar paket Dart lengkap ada di `pubspec.lock`.

[Google ML Kit](https://developers.google.com/ml-kit) (Text Recognition, Translation) bukan open source dan memakai [syarat layanan Google](https://developers.google.com/ml-kit/terms).

## Lisensi

[MIT](LICENSE).
