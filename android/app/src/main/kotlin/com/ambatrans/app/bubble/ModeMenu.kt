package com.ambatrans.app.bubble

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.view.ContextThemeWrapper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import com.ambatrans.app.R
import com.ambatrans.app.data.SettingsStore

/** Long-press menu next to the bubble: translate the whole screen or a part of it. */
class ModeMenu(private val context: Context, private val windowManager: WindowManager) {
    private val density = context.resources.displayMetrics.density
    private var view: View? = null

    val isShown: Boolean get() = view != null

    /** [bubble] is the bubble window in screen pixels; the menu opens on the side away from [edge]. */
    fun show(current: String, bubble: Bounds, edge: String, usable: Bounds, onPick: (String) -> Unit) {
        dismiss()
        val themed = ContextThemeWrapper(context, android.R.style.Theme_DeviceDefault_Light)
        val root = OutsideTouchFrame(themed) { dismiss() }
        root.addView(options(themed, current, onPick))
        root.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED)
        val w = root.measuredWidth
        val h = root.measuredHeight
        val gap = (GAP_DP * density).toInt()
        val onRight = edge == BubbleGeometry.EDGE_RIGHT
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (onRight) bubble.left - w - gap else bubble.right + gap
            y =
                (bubble.top + bubble.height / 2 - h / 2).coerceIn(
                    usable.top,
                    (usable.bottom - h).coerceAtLeast(usable.top),
                )
        }
        windowManager.addView(root, params)
        view = root
        // Grows out of the bubble's side.
        root.pivotX = if (onRight) w.toFloat() else 0f
        root.pivotY = h / 2f
        root.alpha = 0f
        root.scaleX = START_SCALE
        root.scaleY = START_SCALE
        root.animate().alpha(1f).scaleX(1f).scaleY(1f).setDuration(ENTER_MS).start()
    }

    fun dismiss() {
        view?.let { runCatching { windowManager.removeView(it) } }
        view = null
    }

    private fun options(themed: Context, current: String, onPick: (String) -> Unit): View {
        val pad = (PAD_DP * density).toInt()
        return RadioGroup(themed).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad / 2, pad * 2, pad / 2)
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                setStroke(density.toInt().coerceAtLeast(1), BORDER_COLOR)
                cornerRadius = CORNER_DP * density
            }
            listOf(
                SettingsStore.MODE_FULL to R.string.mode_full,
                SettingsStore.MODE_REGION to R.string.mode_region,
            ).forEach { (mode, label) ->
                addView(
                    RadioButton(themed).apply {
                        id = View.generateViewId()
                        text = context.getString(label)
                        isChecked = mode == current
                        setOnClickListener {
                            onPick(mode)
                            dismiss()
                        }
                    },
                )
            }
        }
    }

    /** Closes the menu when the user touches anywhere else. */
    @SuppressLint("ViewConstructor")
    private class OutsideTouchFrame(context: Context, private val onOutside: () -> Unit) : FrameLayout(context) {
        override fun dispatchTouchEvent(event: MotionEvent): Boolean {
            if (event.actionMasked == MotionEvent.ACTION_OUTSIDE) {
                onOutside()
                return true
            }
            return super.dispatchTouchEvent(event)
        }
    }

    private companion object {
        const val GAP_DP = 8f
        const val PAD_DP = 8f
        const val CORNER_DP = 16f
        const val START_SCALE = 0.85f
        const val ENTER_MS = 150L
        val BORDER_COLOR = Color.rgb(0xDD, 0xDD, 0xDD)
    }
}
