package com.ambatrans.app.service

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import com.ambatrans.app.MainActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/** Quick Settings tile that turns the bubble on and off (F-02). */
class AmbaTileService : TileService() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var job: Job? = null
    private val launcher by lazy { ServiceLauncher(applicationContext) }

    override fun onStartListening() {
        job?.cancel()
        job = scope.launch { ServiceStateHolder.running.collect(::render) }
    }

    override fun onStopListening() {
        job?.cancel()
        job = null
    }

    override fun onClick() {
        when (TileAction.of(ServiceStateHolder.running.value, launcher.overlayGranted())) {
            TileAction.STOP -> launcher.stop()
            TileAction.START -> startBubble()
            TileAction.OPEN_APP -> openApp()
        }
    }

    private fun startBubble() {
        try {
            launcher.start()
        } catch (e: RuntimeException) {
            // Android 12+ or the OEM may refuse a background start; from Home it is always allowed.
            Log.w(TAG, "Bubble could not be started from the tile", e)
            openApp()
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // The Intent overload throws on Android 14+.
            startActivityAndCollapse(PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    private fun render(running: Boolean) {
        val tile = qsTile ?: return
        tile.state = if (running) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.updateTile()
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    private companion object {
        const val TAG = "AmbaTileService"
    }
}

/** What a tap on the tile does. */
enum class TileAction {
    START,
    STOP,
    OPEN_APP,
    ;

    companion object {
        fun of(running: Boolean, overlayGranted: Boolean): TileAction = when {
            running -> STOP
            overlayGranted -> START
            else -> OPEN_APP
        }
    }
}
