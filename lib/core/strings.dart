/// All user-facing Flutter text (Bahasa Indonesia). Source: docs/DESIGN.md §8.
abstract final class Strings {
  static const appName = 'AmbaTrans';

  // Generic
  static const close = 'Tutup';
  static const back = 'Kembali';
  static const retry = 'Coba lagi';
  static const loading = 'memuat';
  static const from = 'Dari';
  static const to = 'Ke';

  // Home
  static const greeting = 'Halo,';
  static const heroLabel = 'Layanan terjemahan layar';
  static const statusActive = 'Aktif';
  static const statusInactive = 'Tidak aktif';
  static const start = 'Mulai';
  static const stop = 'Berhenti';
  static const completePermissions = 'Lengkapi izin';
  static const tileOverlay = 'Izin tampil';
  static const tileNotifications = 'Notifikasi';
  static const tileModels = 'Model bahasa';
  static const tileAccurate = 'Mode akurat';
  static const tileReady = 'siap';
  static const tileNeedsAction = 'perlu tindakan, ketuk untuk memperbaiki';
  static const problemOverlay =
      'Izin "Tampil di atas aplikasi lain" belum diberikan';
  static const problemNotifications = 'Izin notifikasi belum diberikan';
  static const problemModels = 'Model bahasa belum diunduh';
  static const problemStoppedBySystem =
      'Layanan berhenti. Tekan Mulai untuk mengaktifkan lagi.';
  static const needsAttention = 'Perlu diperhatikan';
  static const allReady = 'Semua siap. Buka aplikasi lain dan ketuk bubble.';
  static const startFailed = 'Gagal memulai layanan. Coba lagi.';

  // Settings
  static const settingsTitle = 'Pengaturan';
  static const sourceLanguage = 'Bahasa sumber';
  static const targetLanguage = 'Bahasa tujuan';
  static const offlineModel = 'Model offline';
  static const readyOffline = 'Siap offline';
  static const notDownloaded = 'Belum diunduh';
  static const download = 'Unduh';
  static const accurateMode = 'Mode akurat (Aksesibilitas)';
  static const autoDetect = 'Deteksi otomatis';

  static const languageSection = 'Bahasa';
  static const sourceSheetSubtitle = 'Bahasa teks di layar';
  static const targetSheetSubtitle = 'Bahasa hasil terjemahan';
  static const searchLanguageHint = 'Cari bahasa';
  static const languageNotFound = 'Bahasa tidak ditemukan';
  static const alreadyChosenAsTarget = 'Sudah dipilih sebagai bahasa tujuan';
  static const alreadyChosenAsSource = 'Sudah dipilih sebagai bahasa sumber';
  static const settingsSaveFailed = 'Pengaturan tidak dapat disimpan';

  // Onboarding
  static String stepOf(int step, int total) => 'Langkah $step dari $total';
  static const next = 'Lanjut';
  static const allow = 'Izinkan';
  static const openSettings = 'Buka pengaturan';
  static const permissionGranted = 'Izin diberikan';
  static const onboardingLanguageTitle = 'Pilih bahasa';
  static const onboardingLanguageBody =
      'Pilih bahasa teks yang ingin diterjemahkan dan bahasa hasil terjemahannya.';
  static const overlayTitle = 'Tampil di atas aplikasi lain';
  static const overlayBody =
      'AmbaTrans memerlukan izin ini agar bubble terjemahan dapat muncul di atas aplikasi apa pun. Aktifkan lalu kembali ke sini.';
  static const notificationsTitle = 'Notifikasi';
  static const notificationsBody =
      'Notifikasi menandakan AmbaTrans aktif dan memudahkan Anda menghentikannya kapan saja.';
  static const readyTitle = 'Siap digunakan';
  static const readyBody =
      'Semua langkah selesai. Buka aplikasi lain dan ketuk bubble untuk menerjemahkan layar.';
  static const startApp = 'Mulai AmbaTrans';

  // Validation
  static const sameLanguage = 'Bahasa sumber dan tujuan tidak boleh sama';

  // Model download
  static String downloadModelBody(String languages, int megabytes) =>
      '$languages, ±$megabytes MB. Cukup sekali, setelah itu bisa dipakai offline.';
  static const downloadFailed =
      'Gagal mengunduh. Periksa koneksi internet lalu coba lagi.';
  static const downloadModelTitle = 'Unduh model bahasa';
  static const downloading = 'Mengunduh model…';
  static const later = 'Nanti saja';
}
