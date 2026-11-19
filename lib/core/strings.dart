/// All user-facing Flutter text (Bahasa Indonesia). Source: docs/DESIGN.md §8.
abstract final class Strings {
  static const appName = 'AmbaTrans';
  static const appTagline = 'Amba Translate';

  // Generic
  static const close = 'Tutup';
  static const back = 'Kembali';
  static const retry = 'Coba lagi';
  static const loading = 'memuat';
  static const from = 'Dari';
  static const to = 'Ke';

  // Home
  static const heroLabel = 'Terjemahan layar';
  static const statusActive = 'Aktif';
  static const statusInactive = 'Tidak aktif';
  static const start = 'Mulai';
  static const stop = 'Berhenti';
  static const completePermissions = 'Lengkapi izin';
  static const problemOverlay =
      'Izin "Tampil di atas aplikasi lain" belum diberikan';
  static const problemCapture = 'Izin tangkap layar belum diberikan';
  static const problemModels = 'Model bahasa belum diunduh';
  static const problemStoppedBySystem = 'Layanan berhenti. Ketuk untuk mulai.';
  static const needsAttention = 'Perlu diperhatikan';
  static const allReady = 'Semua siap.';
  static const startFailed = 'Gagal memulai layanan.';

  // Settings
  static const settingsTitle = 'Pengaturan';
  static const sourceLanguage = 'Bahasa sumber';
  static const targetLanguage = 'Bahasa tujuan';
  static const offlineModel = 'Model offline';
  static const readyOffline = 'Siap offline';
  static const notDownloaded = 'Belum diunduh';
  static const download = 'Unduh';
  static const tipsTitle = 'Agar bubble tidak mati';
  static const tipsBody = 'Izinkan AmbaTrans tanpa batasan baterai.';
  static const tipsAction = 'Buka pengaturan baterai';
  static const cancel = 'Batal';
  static const autoDetect = 'Deteksi otomatis';

  static const languageSection = 'Bahasa';
  static const advancedSection = 'Lanjutan';
  static const permissionsSection = 'Izin';
  static const sourceSheetSubtitle = 'Bahasa teks di layar';
  static const targetSheetSubtitle = 'Bahasa hasil terjemahan';
  static const searchLanguageHint = 'Cari bahasa';
  static const languageNotFound = 'Bahasa tidak ditemukan';
  static const alreadyChosenAsTarget = 'Sudah dipilih sebagai bahasa tujuan';
  static const alreadyChosenAsSource = 'Sudah dipilih sebagai bahasa sumber';
  static const settingsSaveFailed = 'Pengaturan tidak dapat disimpan';
  static const overlayColorSection = 'Tampilan terjemahan';
  static const overlayTextColor = 'Warna teks';
  static const overlayBgColor = 'Warna latar';
  static const overlayBgOpacity = 'Opasitas latar';
  static String percent(int value) => '$value%';
  static const overlayPreview = 'Contoh teks terjemahan';
  static const colorWhite = 'Putih';
  static const colorBlack = 'Hitam';
  static const colorGrey = 'Abu-abu';
  static const colorYellow = 'Kuning';
  static const colorBlue = 'Biru';
  static const colorGreen = 'Hijau';
  static const colorRed = 'Merah';
  static const colorPurple = 'Ungu';

  // Onboarding
  static String stepOf(int step, int total) => 'Langkah $step dari $total';
  static const next = 'Lanjut';
  static const allow = 'Izinkan';
  static const openSettings = 'Buka pengaturan';
  static const permissionGranted = 'Izin diberikan';
  static const onboardingLanguageTitle = 'Pilih bahasa';
  static const onboardingLanguageBody = 'Pilih bahasa asal dan tujuan.';
  static const overlayTitle = 'Tampil di atas aplikasi lain';
  static const overlayBody = 'Agar bubble tampil di atas aplikasi lain.';
  static const notificationsTitle = 'Notifikasi';
  static const notificationsBody =
      'Tanda bahwa layanan aktif. Boleh dimatikan; bubble tetap jalan.';
  static const readyTitle = 'Siap digunakan';
  static const readyBody = 'Buka aplikasi lain, lalu ketuk bubble.';
  static const startApp = 'Mulai AmbaTrans';

  // Validation
  static const sameLanguage = 'Bahasa sumber dan tujuan tidak boleh sama';

  // Model download
  static String downloadModelBody(String languages, int megabytes) =>
      '$languages, ±$megabytes MB.';
  static const downloadFailed = 'Gagal. Periksa internet.';
  static const downloadModelTitle = 'Unduh model bahasa';
  static String downloading(int seconds) => 'Mengunduh… $seconds dtk';
  static const later = 'Nanti saja';

  // Translation engine (ADR-024)
  static const engineSection = 'Mesin terjemahan';
  static const engine = 'Mesin';
  static const engineSheetSubtitle = 'Dipakai saat menerjemahkan';
  static const groupOffline = 'Offline';
  static const groupFree = 'Gratis · perlu API key';
  static const groupPaid = 'Berbayar · perlu API key';
  static const engineMlkitBody = 'Tanpa internet, perlu unduh model';
  static const engineDeeplBody = 'Terjemahan natural';
  static const engineGroqBody = 'AI cepat';
  static const engineGeminiBody = 'AI dari Google';
  static const engineCerebrasBody = 'AI sangat cepat';
  static const engineMistralBody = 'AI dari Eropa';
  static const engineOpenaiBody = 'Model ChatGPT';
  static const engineDeepseekBody = 'AI murah';
  static const apiKeyHint = 'Tempel API key';
  static const modelHint = 'Nama model';
  static const showKey = 'Tampilkan API key';
  static const hideKey = 'Sembunyikan API key';
  static const editKey = 'Ubah key';
  static const editKeyAndModel = 'Ubah key & model';
  static const getApiKey = 'Dapatkan API key';
  static const modelList = 'Daftar model';
  static String sentTo(String service) => 'Teks layar dikirim ke $service.';
  static const save = 'Simpan';
  static const apiKeyRequired = 'Isi API key dulu';
  static const modelRequired = 'Isi nama model dulu';
}
