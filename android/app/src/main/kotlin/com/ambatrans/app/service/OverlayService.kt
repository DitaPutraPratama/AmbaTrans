package com.ambatrans.app.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.widget.Toast
import com.ambatrans.app.R
import com.ambatrans.app.bubble.BubbleActions
import com.ambatrans.app.bubble.BubbleController
import com.ambatrans.app.capture.CaptureConsentActivity
import com.ambatrans.app.capture.CaptureManager
import com.ambatrans.app.data.SettingsStore
import com.ambatrans.app.ocr.LanguageCatalog
import com.ambatrans.app.ocr.OcrEngine
import com.ambatrans.app.ocr.RecognizerProvider
import com.ambatrans.app.overlay.OverlayRenderer
import com.ambatrans.app.pipeline.TranslateError
import com.ambatrans.app.pipeline.TranslateScreenUseCase
import com.ambatrans.app.pipeline.TranslateUi
import com.ambatrans.app.pipeline.TranslatedBlock
import com.ambatrans.app.translate.ModelManager
import com.ambatrans.app.translate.TranslationEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/** Foreground service that owns the bubble and runs "translate this screen" (F-02 to F-07). */
class OverlayService :
    Service(),
    BubbleActions,
    TranslateUi {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var job: Job? = null
    private var bubble: BubbleController? = null
    private var pendingTranslate = false
    private val capture by lazy { CaptureManager(this) }
    private val renderer by lazy { OverlayRenderer(this, ::onScreenTouched) }
    private val recognizers by lazy { RecognizerProvider() }
    private val models by lazy { ModelManager.create() }
    private val translator by lazy { TranslationEngine.create(models) }
    private val ocr by lazy { OcrEngine(recognizers) }
    private val store by lazy { SettingsStore(getSharedPreferences(SettingsStore.PREFS_NAME, MODE_PRIVATE)) }
    private val useCase by lazy {
        TranslateScreenUseCase(
            ui = this,
            languages = { store.sourceLang to store.targetLang },
            scriptFor = LanguageCatalog::scriptFor,
            modelsReady = { source, target -> models.getStatus(source, target).ready },
            capture = capture::captureBitmap,
            recognize = ocr::recognize,
            translate = translator::translateAll,
        )
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_PROJECTION_GRANTED -> onProjectionGranted(intent)
            ACTION_PROJECTION_DENIED -> {
                pendingTranslate = false
                toast(R.string.toast_capture_needed)
            }
            else -> {
                enterForeground(withProjection = false)
                showBubble()
                ServiceStateHolder.set(true)
            }
        }
        // Not sticky: if the system kills the service, Home must show "Tidak aktif" instead of a silent restart.
        return START_NOT_STICKY
    }

    private fun enterForeground(withProjection: Boolean) {
        val notification = NotificationFactory.create(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            var types = ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            if (withProjection) types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            startForeground(NotificationFactory.NOTIFICATION_ID, notification, types)
        } else if (withProjection && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NotificationFactory.NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            )
        } else {
            startForeground(NotificationFactory.NOTIFICATION_ID, notification)
        }
    }

    private fun showBubble() {
        if (bubble?.isShown == true) return
        // Without the permission the service still runs; Home already asks for it.
        if (!Settings.canDrawOverlays(this)) return
        bubble = BubbleController(this, store, this).also { it.show() }
    }

    private fun onProjectionGranted(intent: Intent) {
        enterForeground(withProjection = true) // must precede getMediaProjection on Android 14+
        val manager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val data = intent.getParcelableExtraCompat<Intent>(EXTRA_DATA)
        val projection = data?.let { manager.getMediaProjection(intent.getIntExtra(EXTRA_RESULT_CODE, 0), it) }
        if (projection == null) {
            pendingTranslate = false
            return toast(R.string.toast_capture_needed)
        }
        capture.start(projection) {
            ServiceStateHolder.setCaptureReady(false)
            scope.launch { stopTranslation() }
        }
        ServiceStateHolder.setCaptureReady(true)
        if (pendingTranslate) startTranslation()
    }

    // BubbleActions

    override fun onTap() = startTranslation()

    override fun onLongPress() {
        stopSelf()
    }

    /** Any touch outside the bubble ends the translation; a running job is left alone. */
    private fun onScreenTouched() {
        if (job?.isActive == true) return
        renderer.hide()
        bubble?.setOverlayActive(false)
    }

    private fun startTranslation() {
        if (!capture.hasSession) {
            pendingTranslate = true
            startActivity(
                Intent(this, CaptureConsentActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            return
        }
        pendingTranslate = false
        job?.cancel()
        renderer.hide()
        bubble?.setOverlayActive(false)
        job = scope.launch { useCase.run() }
    }

    private fun stopTranslation() {
        pendingTranslate = false
        job?.cancel()
        job = null
        renderer.hide()
        bubble?.apply {
            setLoading(false)
            setOverlayActive(false)
            show()
        }
    }

    // TranslateUi

    override fun hideForCapture() {
        renderer.hide()
        bubble?.hide()
    }

    override fun showLoading() {
        bubble?.apply {
            show()
            setLoading(true)
        }
    }

    override fun showResult(blocks: List<TranslatedBlock>) {
        renderer.show(blocks)
        bubble?.apply {
            show()
            setLoading(false)
            setOverlayActive(true)
        }
    }

    override fun showError(error: TranslateError) {
        bubble?.apply {
            show()
            setLoading(false)
        }
        toast(
            when (error) {
                TranslateError.NEEDS_CAPTURE -> R.string.toast_capture_needed
                TranslateError.SCREEN_PROTECTED -> R.string.toast_screen_protected
                TranslateError.MODELS_MISSING -> R.string.toast_models_missing
                TranslateError.NO_TEXT -> R.string.toast_no_text
                TranslateError.FAILED -> R.string.toast_failed
            },
        )
        if (error == TranslateError.NEEDS_CAPTURE) {
            capture.release()
            ServiceStateHolder.setCaptureReady(false)
        }
    }

    private fun toast(message: Int) = Toast.makeText(this, message, Toast.LENGTH_SHORT).show()

    override fun onDestroy() {
        scope.cancel()
        renderer.hide()
        bubble?.destroy()
        bubble = null
        capture.release()
        ServiceStateHolder.setCaptureReady(false)
        translator.close()
        recognizers.close()
        ServiceStateHolder.set(false)
        super.onDestroy()
    }

    companion object {
        private const val ACTION_STOP = "com.ambatrans.app.action.STOP"
        private const val ACTION_PROJECTION_GRANTED = "com.ambatrans.app.action.PROJECTION_GRANTED"
        private const val ACTION_PROJECTION_DENIED = "com.ambatrans.app.action.PROJECTION_DENIED"
        private const val EXTRA_RESULT_CODE = "result_code"
        private const val EXTRA_DATA = "data"

        fun startIntent(context: Context) = Intent(context, OverlayService::class.java)

        fun stopIntent(context: Context) = Intent(context, OverlayService::class.java).setAction(ACTION_STOP)

        fun projectionGrantedIntent(context: Context, resultCode: Int, data: Intent) =
            Intent(context, OverlayService::class.java)
                .setAction(ACTION_PROJECTION_GRANTED)
                .putExtra(EXTRA_RESULT_CODE, resultCode)
                .putExtra(EXTRA_DATA, data)

        fun projectionDeniedIntent(context: Context) =
            Intent(context, OverlayService::class.java).setAction(ACTION_PROJECTION_DENIED)
    }
}

@Suppress("DEPRECATION")
private inline fun <reified T : android.os.Parcelable> Intent.getParcelableExtraCompat(name: String): T? =
    if (Build.VERSION.SDK_INT >=
        Build.VERSION_CODES.TIRAMISU
    ) {
        getParcelableExtra(name, T::class.java)
    } else {
        getParcelableExtra(name)
    }
