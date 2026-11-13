# AmbaTrans

Aplikasi Android untuk **menerjemahkan layar aplikasi apa pun**. Floating bubble tampil di atas aplikasi lain; ketuk bubble, pilih **"Terjemahkan layar ini"**, dan terjemahan muncul tepat di atas teks aslinya. Seluruh proses (OCR dan terjemahan) berjalan di perangkat dan bisa dipakai offline setelah model bahasa diunduh. Tanpa akun, tanpa server, tanpa iklan.

> **Status:** tahap dokumentasi selesai; kode belum dimulai. Mulai dari `docs/TASKS.md` (T-001). Dibuat untuk pemakaian sendiri dan dibagikan gratis sebagai APK.

## Fitur
- Floating bubble + menu aksi di atas aplikasi lain
- Tangkap layar → baca teks (OCR) → terjemahkan → overlay per blok teks
- Pilih bahasa sumber dan tujuan (default: Inggris → Indonesia)
- Terjemahan offline lewat ML Kit (model diunduh sekali, ±30 MB per bahasa)
- Mode akurat opsional lewat layanan Aksesibilitas (hanya membaca teks dan posisinya)

Rincian lengkap dan acceptance criteria ada di `docs/PRD.md`.

## Persyaratan
- Ponsel: Android 8.0+ (API 26+), arm64. Uji overlay dan screen capture di **perangkat fisik** (emulator hanya untuk UI Flutter).
- Komputer pengembangan: Ubuntu 20.04 LTS atau lebih baru (64-bit), minimal 4 core CPU, 8 GB RAM, 11 GB disk kosong (disarankan 8 core, 16 GB RAM, 60 GB disk).
- Perangkat lunak: Flutter SDK (stable), Android Studio versi lengkap (2024.1.1 Koala atau lebih baru), Android SDK, dan kabel USB. JDK memakai bawaan Android Studio; pasang JDK terpisah hanya jika `flutter doctor` memintanya.

## Menyiapkan lingkungan di Ubuntu
1. **Paket sistem**
   ```bash
   sudo apt-get update -y && sudo apt-get upgrade -y
   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
   sudo apt-get install libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64
   ```
   Jika `flutter doctor` menyarankan versi paket lain, ikuti sarannya.
2. **Android Studio** — unduh versi Linux dari <https://developer.android.com/studio>, ekstrak, jalankan `bin/studio.sh`, ikuti wizard. Di **Tools → SDK Manager** pasang:
   - SDK Platforms: Android API 35.0.2 (sesuai panduan Flutter saat ini)
   - SDK Tools: Android SDK Command-line Tools, Build-Tools, Platform-Tools (Emulator opsional)
3. **Flutter SDK** — unduh bundel stable `.tar.xz` dari <https://docs.flutter.dev/install/archive>, lalu:
   ```bash
   mkdir -p ~/development
   tar -xf ~/Downloads/<berkas-flutter>.tar.xz -C ~/development/
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
   ```
   Buka terminal baru (di Ubuntu terminal biasa membaca `~/.bashrc`).
4. **Lisensi dan pengecekan**
   ```bash
   flutter doctor --android-licenses
   flutter doctor
   ```
   Peringatan Chrome dan Linux toolchain boleh diabaikan (kita hanya membangun untuk Android).
5. **Perangkat fisik** — aktifkan *Opsi pengembang* (ketuk "Nomor versi/MIUI/OS" 7 kali) → **USB debugging**, sambungkan kabel, setujui dialog "Izinkan debugging USB", lalu cek `flutter devices`.
   - Xiaomi/Redmi/POCO: aktifkan juga "Instal via USB" dan "USB debugging (Pengaturan keamanan)" di Opsi pengembang.
   - Jika perangkat tidak terdeteksi (`no permissions`): `sudo apt install android-sdk-platform-tools-common`, cabut dan colok ulang kabel.
6. **Editor** — Android Studio dengan plugin Flutter dan Dart, atau VS Code 1.86+ dengan ekstensi Flutter.

## Instalasi (pengembangan)
```bash
flutter pub get
```

## Menjalankan
```bash
flutter run                      # perangkat fisik Android
flutter test                     # test Dart
cd android && ./gradlew testDebugUnitTest   # test Kotlin
flutter analyze && dart format --set-exit-if-changed .   # lint
```

## Build APK
```bash
flutter build apk --release --split-per-abi
```
Penandatanganan memakai keystore lokal (lihat `.env.example`; jangan commit keystore).

## Memasang APK
1. Unduh APK (arm64) ke ponsel dan izinkan instal dari sumber tidak dikenal untuk aplikasi yang dipakai membukanya.
2. Buka AmbaTrans dan ikuti onboarding: pilih bahasa, beri izin "Tampil di atas aplikasi lain" dan notifikasi.
3. Tekan **Mulai**, buka aplikasi lain, lalu ketuk bubble.
4. Saat pertama kali menerjemahkan, setujui dialog tangkap layar dan pilih **seluruh layar**.

## Privasi
Screenshot dan hasil OCR tidak disimpan. Satu-satunya trafik jaringan adalah unduhan model bahasa oleh ML Kit. Tidak ada analytics atau iklan.

## Dokumentasi
| Dokumen | Isi |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Panduan kerja untuk Claude Code |
| [`docs/PRD.md`](docs/PRD.md) | Produk, fitur, acceptance criteria, risiko |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Arsitektur, komponen, kontrak channel, testing |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Penyimpanan lokal (preferensi) |
| [`docs/API.md`](docs/API.md) | Penjelasan bahwa tidak ada API jaringan |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Layar, token desain, komponen UI |
| [`docs/TASKS.md`](docs/TASKS.md) | Daftar tugas T-001 … T-045 |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Status, pengukuran, checklist uji, log sesi |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Catatan keputusan (ADR) |
