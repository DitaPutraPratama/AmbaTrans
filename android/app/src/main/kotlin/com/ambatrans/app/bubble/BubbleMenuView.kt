package com.ambatrans.app.bubble

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.ambatrans.app.R

/** Column of white pills (S-08). Closing (outside tap, timeout) is handled by the controller. */
class BubbleMenuView(
    context: Context,
    showClear: Boolean,
    onTranslate: () -> Unit,
    onClear: () -> Unit,
    onStop: () -> Unit,
    private val onOutsideTouch: () -> Unit,
) : LinearLayout(context) {
    private val density = resources.displayMetrics.density

    init {
        orientation = VERTICAL
        addPill(
            R.string.menu_translate,
            R.drawable.ic_stat_translate,
            R.color.menu_blue_bg,
            R.color.menu_blue_icon,
            onTranslate,
        )
        if (showClear) {
            addPill(R.string.menu_clear, R.drawable.ic_menu_delete, R.color.menu_red_bg, R.color.menu_red_icon, onClear)
        }
        addPill(R.string.menu_stop, R.drawable.ic_menu_stop, R.color.menu_grey_bg, R.color.menu_grey_icon, onStop)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_OUTSIDE) onOutsideTouch()
        return super.onTouchEvent(event)
    }

    private fun addPill(label: Int, icon: Int, tileBg: Int, tileIcon: Int, action: () -> Unit) {
        val pill = LinearLayout(context).apply {
            orientation = HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            minimumHeight = (PILL_HEIGHT_DP * density).toInt()
            setPadding((PILL_PAD_DP * density).toInt(), 0, (PILL_END_PAD_DP * density).toInt(), 0)
            background = GradientDrawable().apply {
                setColor(ContextCompat.getColor(context, R.color.menu_surface))
                cornerRadius = PILL_RADIUS_DP * density
            }
            elevation = 4 * density
            contentDescription = context.getString(label)
            isClickable = true
            setOnClickListener { action() }
        }
        val tileSize = (TILE_DP * density).toInt()
        val tile = ImageView(context).apply {
            setImageResource(icon)
            setColorFilter(ContextCompat.getColor(context, tileIcon))
            val pad = (TILE_PAD_DP * density).toInt()
            setPadding(pad, pad, pad, pad)
            background = GradientDrawable().apply {
                setColor(ContextCompat.getColor(context, tileBg))
                cornerRadius = TILE_RADIUS_DP * density
            }
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        pill.addView(tile, LayoutParams(tileSize, tileSize))
        val text = TextView(context).apply {
            setText(label)
            setTextColor(ContextCompat.getColor(context, R.color.menu_text))
            textSize = TEXT_SP
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        pill.addView(
            text,
            LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                marginStart = (TEXT_GAP_DP * density).toInt()
            },
        )
        val params = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        if (childCount > 0) params.topMargin = (PILL_GAP_DP * density).toInt()
        addView(pill, params)
    }

    companion object {
        const val MAX_WIDTH_DP = 240
        private const val PILL_HEIGHT_DP = 52
        private const val PILL_RADIUS_DP = 24f
        private const val PILL_PAD_DP = 8
        private const val PILL_END_PAD_DP = 16
        private const val PILL_GAP_DP = 8
        private const val TILE_DP = 36
        private const val TILE_PAD_DP = 8
        private const val TILE_RADIUS_DP = 12f
        private const val TEXT_GAP_DP = 12
        private const val TEXT_SP = 15f
    }
}
