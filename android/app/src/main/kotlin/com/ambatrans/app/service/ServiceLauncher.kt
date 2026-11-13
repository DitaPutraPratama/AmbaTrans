package com.ambatrans.app.service

import android.content.Context
import android.provider.Settings

/** Starts and stops [OverlayService] from the app UI. */
class ServiceLauncher(private val context: Context) {
    fun overlayGranted(): Boolean = Settings.canDrawOverlays(context)

    fun start() {
        context.startForegroundService(OverlayService.startIntent(context))
    }

    fun stop() {
        context.stopService(OverlayService.startIntent(context))
    }
}
