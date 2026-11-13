package com.ambatrans.app.overlay

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import com.ambatrans.app.pipeline.TranslatedBlock

/**
 * Draws translated labels in one full-screen, touch-transparent overlay window (S-09).
 * Window alpha is 0.8: Android 12+ only forwards touches through overlays at or below that opacity.
 */
class OverlayRenderer(private val context: Context) {
    private val windowManager = context.getSystemService(WindowManager::class.java)
    private val density = context.resources.displayMetrics.density
    private var root: FrameLayout? = null

    val isShowing: Boolean get() = root != null

    /** Replaces any previous overlay with [blocks]. */
    fun show(blocks: List<TranslatedBlock>) {
        hide()
        val container = FrameLayout(context)
        blocks.forEach { container.addView(label(it)) }
        windowManager.addView(container, windowParams())
        root = container
    }

    fun hide() {
        root?.let { runCatching { windowManager.removeViewImmediate(it) } }
        root = null
    }

    private fun windowParams() = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
        PixelFormat.TRANSLUCENT,
    ).apply {
        gravity = Gravity.TOP or Gravity.START
        alpha = WINDOW_ALPHA
        // Draw under the notch so label coordinates match screenshot pixels (S-2 verifies on device).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
    }

    private fun label(item: TranslatedBlock): View {
        val block = item.block
        val padH = (PAD_H_DP * density).toInt()
        val padV = (PAD_V_DP * density).toInt()
        val screen = context.resources.displayMetrics
        val fit = LabelPlacer.place(
            text = item.translated,
            box = block,
            screenWidth = screen.widthPixels,
            screenHeight = screen.heightPixels,
            padH = padH,
            padV = padV,
            pxPerSp = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 1f, screen),
            measurer = ::measure,
        )
        return TextView(context).apply {
            text = item.translated
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, fit.sizeSp)
            maxLines = fit.maxLines
            ellipsize = TextUtils.TruncateAt.END
            gravity = Gravity.CENTER_VERTICAL
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(LABEL_COLOR)
                cornerRadius = CORNER_DP * density
            }
            layoutParams = FrameLayout.LayoutParams(fit.width, fit.height).apply {
                leftMargin = fit.left
                topMargin = fit.top
            }
        }
    }

    private fun measure(text: String, sizeSp: Float, widthPx: Int): TextMeasure {
        val paint = TextPaint().apply {
            textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sizeSp, context.resources.displayMetrics)
        }
        val layout = StaticLayout.Builder.obtain(text, 0, text.length, paint, widthPx).setIncludePad(false).build()
        val lineHeight = if (layout.lineCount > 0) layout.getLineBottom(0) - layout.getLineTop(0) else 1
        return TextMeasure(layout.height, lineHeight)
    }

    companion object {
        private const val WINDOW_ALPHA = 0.8f
        private const val LABEL_COLOR = 0xFF424242.toInt()
        private const val PAD_H_DP = 4f
        private const val PAD_V_DP = 2f
        private const val CORNER_DP = 4f
    }
}
