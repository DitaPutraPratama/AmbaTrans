package com.ambatrans.app.overlay

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.WindowManager
import com.ambatrans.app.pipeline.ScreenRect

/** Shows [RegionSelectView] in its own full-screen, touchable window while the user picks an area. */
class RegionSelector(private val context: Context) {
    private val windowManager = context.getSystemService(WindowManager::class.java)
    private var view: RegionSelectView? = null

    fun show(onConfirm: (ScreenRect) -> Unit) {
        hide()
        val selector = RegionSelectView(
            context,
            onConfirm = { region ->
                hide()
                onConfirm(region)
            },
            onCancel = ::hide,
        )
        windowManager.addView(selector, params())
        view = selector
    }

    fun hide() {
        // removeView, not removeViewImmediate: this may run inside the view's own touch handling.
        view?.let { runCatching { windowManager.removeView(it) } }
        view = null
    }

    // Focusable (no FLAG_NOT_FOCUSABLE) so Back reaches the selector.
    private fun params() = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
        PixelFormat.TRANSLUCENT,
    ).apply {
        gravity = Gravity.TOP or Gravity.START
        // Same as the overlay, so view coordinates match screenshot pixels.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
    }
}
