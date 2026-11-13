package com.ambatrans.app.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.widget.Toast
import com.ambatrans.app.R
import com.ambatrans.app.bubble.BubbleActions
import com.ambatrans.app.bubble.BubbleController
import com.ambatrans.app.data.SettingsStore

/** Foreground service that owns the bubble. Capture and overlay are attached in later tasks. */
class OverlayService :
    Service(),
    BubbleActions {
    private var bubble: BubbleController? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        val notification = NotificationFactory.create(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NotificationFactory.NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NotificationFactory.NOTIFICATION_ID, notification)
        }
        showBubble()
        ServiceStateHolder.set(true)
        // Not sticky: if the system kills the service, Home must show "Tidak aktif" instead of a silent restart.
        return START_NOT_STICKY
    }

    private fun showBubble() {
        if (bubble?.isShown == true) return
        // Without the permission the service still runs; Home already asks for it.
        if (!Settings.canDrawOverlays(this)) return
        val store = SettingsStore(getSharedPreferences(SettingsStore.PREFS_NAME, MODE_PRIVATE))
        bubble = BubbleController(this, store, this).also { it.show() }
    }

    override fun onTranslate() {
        // The capture, OCR and translate pipeline arrives with T-026.
        Toast.makeText(this, R.string.toast_translate_unavailable, Toast.LENGTH_SHORT).show()
    }

    override fun onClearTranslation() {
        bubble?.setOverlayActive(false)
    }

    override fun onStop() {
        stopSelf()
    }

    override fun onDestroy() {
        bubble?.destroy()
        bubble = null
        ServiceStateHolder.set(false)
        super.onDestroy()
    }

    companion object {
        private const val ACTION_STOP = "com.ambatrans.app.action.STOP"

        fun startIntent(context: Context) = Intent(context, OverlayService::class.java)

        fun stopIntent(context: Context) = Intent(context, OverlayService::class.java).setAction(ACTION_STOP)
    }
}
