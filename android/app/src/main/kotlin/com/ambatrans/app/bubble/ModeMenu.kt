package com.ambatrans.app.bubble

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.RippleDrawable
import android.view.ContextThemeWrapper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
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

    /** One card per mode, stacked with a gap; the active one gets a blue outline. */
    private fun options(themed: Context, current: String, onPick: (String) -> Unit): View {
        val gap = (GAP_DP * density).toInt()
        return LinearLayout(themed).apply {
            orientation = LinearLayout.VERTICAL
            val shadowRoom = (SHADOW_ROOM_DP * density).toInt()
            setPadding(shadowRoom, shadowRoom, shadowRoom, shadowRoom)
            listOf(
                Triple(SettingsStore.MODE_FULL, R.string.mode_full, R.drawable.ic_mode_full),
                Triple(SettingsStore.MODE_REGION, R.string.mode_region, R.drawable.ic_mode_region),
            ).forEachIndexed { index, (mode, label, icon) ->
                val card = card(themed, context.getString(label), icon, selected = mode == current) {
                    onPick(mode)
                    dismiss()
                }
                addView(
                    card,
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    )
                        .apply { if (index > 0) topMargin = gap },
                )
            }
        }
    }

    private fun card(themed: Context, label: String, icon: Int, selected: Boolean, onClick: () -> Unit): View {
        val accent = ContextCompat.getColor(context, R.color.menu_selected)
        val shape = GradientDrawable().apply {
            setColor(Color.WHITE)
            cornerRadius = CORNER_DP * density
            if (selected) {
                setStroke((SELECTED_STROKE_DP * density).toInt(), accent)
            } else {
                setStroke(density.toInt().coerceAtLeast(1), BORDER_COLOR)
            }
        }
        val padH = (CARD_PAD_H_DP * density).toInt()
        val padV = (CARD_PAD_V_DP * density).toInt()
        return LinearLayout(themed).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(padH, padV, padH * 2, padV)
            background = RippleDrawable(ColorStateList.valueOf(RIPPLE_COLOR), shape, null)
            elevation = ELEVATION_DP * density
            isSelected = selected
            contentDescription = label
            setOnClickListener { onClick() }
            addView(
                ImageView(themed).apply {
                    setImageResource(icon)
                    imageTintList = ColorStateList.valueOf(if (selected) accent else TEXT_COLOR)
                    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
                },
                LinearLayout.LayoutParams((ICON_DP * density).toInt(), (ICON_DP * density).toInt()),
            )
            addView(
                TextView(themed).apply {
                    text = label
                    textSize = LABEL_SP
                    setTextColor(if (selected) accent else TEXT_COLOR)
                    if (selected) setTypeface(typeface, Typeface.BOLD)
                    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
                },
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                )
                    .apply { marginStart = padH },
            )
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
        const val SHADOW_ROOM_DP = 6f
        const val CORNER_DP = 16f
        const val SELECTED_STROKE_DP = 2f
        const val CARD_PAD_H_DP = 14f
        const val CARD_PAD_V_DP = 12f
        const val ELEVATION_DP = 3f
        const val ICON_DP = 22f
        const val LABEL_SP = 15f
        const val START_SCALE = 0.85f
        const val ENTER_MS = 150L
        val BORDER_COLOR = Color.rgb(0xDD, 0xDD, 0xDD)
        val TEXT_COLOR = Color.rgb(0x1F, 0x1F, 0x1F)
        val RIPPLE_COLOR = Color.argb(0x33, 0x00, 0x47, 0xBB)
    }
}
