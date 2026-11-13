# AmbaTrans

Aplikasi Android untuk **menerjemahkan layar aplikasi apa pun**. Bubble melayang tampil di atas aplikasi lain; ketuk bubble dan terjemahan muncul tepat di atas teks aslinya. Pembacaan teks (OCR) dan terjemahan berjalan di perangkat dan bisa dipakai offline setelah model bahasa diunduh. Tanpa akun, tanpa server, tanpa iklan.

## Unduh

**[Unduh rilis terbaru](../../releases/latest)** → buka bagian **Assets** dan pilih APK:

| File | Untuk |
|---|---|
| `app-arm64-v8a-release.apk` | Hampir semua ponsel Android sekarang (64-bit). **Pilih ini bila ragu.** |
| `app-armeabi-v7a-release.apk` | Ponsel lama 32-bit |
| `app-x86_64-release.apk` | Emulator / perangkat x86 |

Syarat: Android 8.0 (API 26) atau lebih baru.

**Memasang**
1. Unduh APK ke ponsel, lalu ketuk berkasnya.
2. Bila diminta, izinkan **Instal dari sumber tidak dikenal** untuk aplikasi yang dipakai membuka berkas (browser atau pengelola file). Jika Play Protect memperingatkan, pilih **Tetap instal**.
3. Buka AmbaTrans dan ikuti panduan awal: pilih bahasa, unduh model bahasa, beri izin **Tampil di atas aplikasi lain** dan **Notifikasi**.
4. Tekan **Mulai**, buka aplikasi lain, lalu ketuk bubble.

Memperbarui: pasang APK versi baru di atas yang lama; data tetap ada.

## Fitur
- Bubble melayang yang bisa digeser dan menempel ke tepi layar; memudar bila tidak disentuh
- Ketuk bubble untuk menerjemahkan layar; tekan lama untuk menghapus bubble
- Hasil terjemahan tampil per baris teks, tepat di atas teks aslinya
- Pilih bahasa sumber dan tujuan (default Inggris → Indonesia)
- Terjemahan offline lewat Google ML Kit (model diunduh sekali, ±30 MB per bahasa)
- Mode akurat opsional lewat layanan Aksesibilitas (hanya membaca teks dan posisinya di layar)

## Cara memakai
- **Mulai / Berhenti** ada di layar utama. Tombol pengaturan di pojok kanan atas.
- Saat pertama kali menerjemahkan, Android meminta izin tangkap layar; pilih **seluruh layar**.
- Terjemahan hilang saat kamu menyentuh layar di luar bubble. Ketuk bubble lagi untuk menerjemahkan ulang.
- Bagian **Perlu diperhatikan** di layar utama menunjukkan izin atau model yang masih kurang; ketuk untuk membukanya di Pengaturan.

## Izin dan privasi
| Izin | Dipakai untuk |
|---|---|
| Tampil di atas aplikasi lain | Bubble dan hasil terjemahan |
| Notifikasi / layanan latar depan | Menjaga bubble tetap hidup |
| Tangkap layar (diminta sistem) | Mengambil gambar layar untuk dibaca |
| Internet | **Hanya** mengunduh model bahasa ML Kit |
| Aksesibilitas (opsional) | Membaca teks dan posisinya agar hasil lebih akurat; tidak bisa mengetuk atau melakukan gestur |

Screenshot hanya ada di memori dan dibuang setelah dibaca; tidak disimpan ke penyimpanan. Tidak ada analytics, iklan, atau akun.

## Pengembangan

### Persyaratan
- [Flutter](https://docs.flutter.dev/install) stable (Dart 3.14 atau lebih baru)
- Android Studio (membawa JDK 17+ dan Android SDK) atau JDK 17+ dan Android SDK terpisah
- Ponsel Android 8.0+ dengan **USB debugging** aktif. Uji overlay dan tangkap layar di **perangkat fisik**; emulator tidak andal untuk itu.

Pastikan `flutter doctor` tidak melaporkan masalah pada bagian Android.

### Ambil dan jalankan
```bash
git clone <url-repo-ini>
cd <folder-hasil-clone>
flutter pub get
flutter devices          # ponsel harus terdaftar
flutter run              # pasang dan jalankan di ponsel, dengan hot reload
```
Pertama kali, Gradle mengunduh dependensi dan build bisa memakan beberapa menit.

### Tes dan lint
```bash
flutter test                                   # tes Dart
flutter analyze && dart format --set-exit-if-changed .

cd android
./gradlew testDebugUnitTest                    # tes Kotlin
./gradlew ktlintCheck lintDebug                # lint Kotlin dan Android
```
Perintah Gradle butuh `JAVA_HOME`; jika belum diatur, arahkan ke JDK Android Studio, misalnya `export JAVA_HOME=/path/ke/android-studio/jbr`.

### Build APK rilis
```bash
flutter build apk --release --split-per-abi
```
Hasilnya ada di `build/app/outputs/flutter-apk/` (satu APK per arsitektur).

Tanpa konfigurasi tambahan, APK rilis ditandatangani dengan kunci debug. Untuk menandatangani dengan kunci sendiri, buat keystore dan berkas `android/key.properties` (sudah masuk `.gitignore`, jangan di-commit):
```properties
storeFile=/path/ke/keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```
Simpan keystore baik-baik: pembaruan aplikasi hanya bisa dipasang bila ditandatangani dengan kunci yang sama.

### Struktur proyek
```
lib/                      UI Flutter (Home, Onboarding, Pengaturan), tema, channel ke native
  app/  core/  features/
android/app/src/main/kotlin/com/ambatrans/app/
  bubble/   bubble melayang
  capture/  tangkap layar (MediaProjection)
  ocr/      pembacaan teks (ML Kit)
  translate/ terjemahan dan model offline (ML Kit)
  overlay/  tampilan hasil terjemahan
  access/   layanan Aksesibilitas opsional
  pipeline/ alur tangkap → baca → terjemah → tampil
  service/  foreground service
  bridge/   handler MethodChannel / EventChannel
test/                     tes Dart
```

## Lisensi
Font Plus Jakarta Sans memakai lisensi SIL OFL (`assets/fonts/OFL.txt`). Lisensi kode proyek ini belum ditentukan.
