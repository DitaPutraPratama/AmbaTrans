package com.ambatrans.app.capture

import android.content.Context
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.DisplayMetrics
import android.view.WindowManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext

class NoProjectionException : Exception("Screen capture was not granted")

class ScreenProtectedException : Exception("The screen came back fully black (FLAG_SECURE or DRM)")

/**
 * Keeps one MediaProjection session with a single VirtualDisplay + ImageReader and hands out screenshots
 * as in-memory bitmaps (F-04). Nothing is ever written to disk. Android 14+ forbids a second VirtualDisplay on
 * the same projection, hence one display for the whole session.
 */
class CaptureManager(private val context: Context) {
    private var projection: MediaProjection? = null
    private var reader: ImageReader? = null
    private var display: VirtualDisplay? = null
    private var thread: HandlerThread? = null
    private var width = 0
    private var height = 0

    val hasSession: Boolean get() = projection != null

    fun start(newProjection: MediaProjection, onEnded: () -> Unit) {
        release()
        val metrics = screenSize()
        width = metrics.first
        height = metrics.second
        val worker = HandlerThread("ambatrans-capture").also { it.start() }
        val handler = Handler(worker.looper)
        // Required before createVirtualDisplay on Android 14+; also fires when the user ends sharing.
        newProjection.registerCallback(
            object : MediaProjection.Callback() {
                override fun onStop() {
                    release()
                    onEnded()
                }
            },
            handler,
        )
        val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        display = newProjection.createVirtualDisplay(
            "AmbaTrans",
            width,
            height,
            context.resources.displayMetrics.densityDpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader.surface,
            null,
            handler,
        )
        projection = newProjection
        reader = imageReader
        thread = worker
    }

    /** Latest screen frame as a bitmap the caller must recycle. */
    suspend fun captureBitmap(): Bitmap {
        val imageReader = reader ?: throw NoProjectionException()
        delay(FRAME_SETTLE_MS) // let the compositor drop the bubble / old overlay from the mirror
        var image = imageReader.acquireLatestImage()
        var waited = 0L
        while (image == null && waited < FRAME_TIMEOUT_MS) {
            delay(POLL_MS)
            waited += POLL_MS
            image = imageReader.acquireLatestImage()
        }
        image ?: throw NoProjectionException()
        return withContext(Dispatchers.Default) {
            image.use {
                val plane = it.planes[0]
                val rowPixels = plane.rowStride / plane.pixelStride
                val padded = Bitmap.createBitmap(rowPixels, height, Bitmap.Config.ARGB_8888)
                padded.copyPixelsFromBuffer(plane.buffer)
                val cropped = if (rowPixels == width) padded else Bitmap.createBitmap(padded, 0, 0, width, height)
                if (cropped !== padded) padded.recycle()
                if (isBlack(cropped)) {
                    cropped.recycle()
                    throw ScreenProtectedException()
                }
                cropped
            }
        }
    }

    fun release() {
        display?.release()
        display = null
        reader?.close()
        reader = null
        projection?.let { runCatching { it.stop() } }
        projection = null
        thread?.quitSafely()
        thread = null
    }

    private fun isBlack(bitmap: Bitmap): Boolean {
        for (iy in 1..SAMPLES) {
            for (ix in 1..SAMPLES) {
                val pixel = bitmap.getPixel(bitmap.width * ix / (SAMPLES + 1), bitmap.height * iy / (SAMPLES + 1))
                if (pixel and RGB_MASK != 0) return false
            }
        }
        return true
    }

    private fun screenSize(): Pair<Int, Int> {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = wm.currentWindowMetrics.bounds
            return bounds.width() to bounds.height()
        }
        val metrics = DisplayMetrics()
        @Suppress("DEPRECATION")
        wm.defaultDisplay.getRealMetrics(metrics)
        return metrics.widthPixels to metrics.heightPixels
    }

    private companion object {
        const val FRAME_SETTLE_MS = 150L
        const val FRAME_TIMEOUT_MS = 1_000L
        const val POLL_MS = 50L
        const val SAMPLES = 8
        const val RGB_MASK = 0x00FFFFFF
    }
}
