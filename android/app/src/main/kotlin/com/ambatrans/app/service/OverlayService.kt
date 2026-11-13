package com.ambatrans.app.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/** Foreground service that keeps the bubble alive. Bubble, capture and overlay are attached in later tasks. */
class OverlayService : Service() {
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
        ServiceStateHolder.set(true)
        // Not sticky: if the system kills the service, Home must show "Tidak aktif" instead of a silent restart.
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        ServiceStateHolder.set(false)
        super.onDestroy()
    }

    companion object {
        private const val ACTION_STOP = "com.ambatrans.app.action.STOP"

        fun startIntent(context: Context) = Intent(context, OverlayService::class.java)

        fun stopIntent(context: Context) = Intent(context, OverlayService::class.java).setAction(ACTION_STOP)
    }
}
