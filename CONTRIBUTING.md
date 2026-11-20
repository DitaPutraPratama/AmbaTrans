# Berkontribusi ke AmbaTrans

Terima kasih sudah mau membantu. Laporan bug, ide, dan Pull Request (PR) semuanya diterima.

## Sebelum mulai
- **Bug atau ide:** buka [issue](https://github.com/DitaPutraPratama/AmbaTrans/issues) dulu, pakai template yang tersedia.
- **Perubahan besar** (fitur baru, mengganti library, mengubah alur terjemahan): diskusikan di issue sebelum menulis kode, supaya waktumu tidak terbuang kalau arahnya berbeda.
- **Celah keamanan:** jangan lewat issue publik. Lihat [SECURITY.md](SECURITY.md).

## Menyiapkan proyek
Butuh Flutter (channel stable), Android SDK, dan JDK 17 atau lebih baru (JDK bawaan Android Studio juga bisa).

```bash
flutter pub get
flutter run          # pakai HP asli; overlay dan screen capture tidak andal di emulator
```

Build debug otomatis memakai kunci debug. Kamu tidak butuh keystore rilis.

## Cek sebelum membuka PR
CI menjalankan perintah yang sama untuk setiap PR:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
cd android && ./gradlew testDebugUnitTest ktlintCheck
```

Kalau perubahanmu menyentuh bubble, overlay, atau screen capture, coba juga di HP asli (Android 8.0+) dan tulis hasilnya di PR.

## Aturan kode
- Dart di `lib/`, Kotlin di `android/`. Nama variabel, fungsi, file, dan komentar teknis ditulis dalam **bahasa Inggris**.
- Teks yang tampil ke pengguna ditulis dalam **Bahasa Indonesia**, dikumpulkan di `lib/core/strings.dart` (Flutter) atau `res/values/strings.xml` (Android). Jangan menulis teks UI langsung di widget.
- Pakai logger (`dart:developer` `log` atau `android.util.Log`), bukan `print`. Jangan mencatat teks hasil OCR atau terjemahan di log.
- Logika yang tidak sepele perlu unit test.
- Tampilan sengaja sederhana: tanpa animasi rumit, dan tanpa paket UI baru kecuali alasannya kuat.

## Privasi: aturan yang tidak bisa ditawar
- Screenshot tidak boleh disimpan ke disk, cache, atau galeri. Bitmap hanya ada di memori dan dilepas setelah OCR.
- Tidak ada SDK analytics, crash reporting, atau iklan.
- Tidak ada backend atau akun. Akses jaringan hanya untuk unduhan model ML Kit dan mesin terjemahan online yang dipilih sendiri oleh pengguna dengan API key miliknya.
- Jangan menambahkan AccessibilityService. Fitur ini memicu blokir Play Protect.
- Jangan menurunkan `minSdk` di bawah 26 atau mengubah package ID `com.ambatrans.app`.
- Jangan commit keystore, `key.properties`, atau API key.

## Commit dan PR
- Satu PR untuk satu perubahan. PR kecil lebih cepat direview.
- Buat branch dari `main`, misalnya `fix/overlay-cut-off` atau `feat/region-zoom`.
- Pesan commit memakai [Conventional Commits](https://www.conventionalcommits.org/): `fix(overlay): keep labels inside the screen`. Tipe yang dipakai: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`.
- Untuk perubahan tampilan, sertakan screenshot sebelum dan sesudah.
- Setiap PR direview pemilik repo sebelum di-merge. Versi dan rilis APK juga diurus pemilik, jadi jangan menaikkan versi di `pubspec.yaml`.

Dengan mengirim PR, kamu setuju kontribusimu dirilis di bawah [lisensi MIT](LICENSE) proyek ini.
