package com.ambatrans.app.bubble

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.view.View
import androidx.core.content.ContextCompat
import com.ambatrans.app.R

/**
 * Bottom strip shown while the bubble is dragged: a dark gradient with a round "X" target.
 * Dropping the bubble on the X stops the service. The X centre sits [bottomGapPx] above the strip's bottom.
 */
@SuppressLint("ViewConstructor")
class DismissTargetView(context: Context, private val bottomGapPx: Int) : View(context) {
    private val density = resources.displayMetrics.density
    private val slidePx = SLIDE_DP * density

    /** Strip height in px; the window is as wide as the usable screen. */
    val areaHeight: Int = (AREA_DP * density).toInt()

    private val shade = Paint()
    private val fill = Paint(Paint.ANTI_ALIAS_FLAG)
    private val cross = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 3 * density
        strokeCap = Paint.Cap.ROUND
    }
    private val idleColor = Color.argb(160, 0, 0, 0)
    private val hotColor = ContextCompat.getColor(context, R.color.dismiss_hot)
    private var showing = false

    var hot = false
        set(value) {
            if (field == value) return
            field = value
            invalidate()
        }

    init {
        visibility = GONE
        contentDescription = context.getString(R.string.dismiss_target_description)
    }

    /** Slides up and fades in. */
    fun appear() {
        showing = true
        hot = false
        if (visibility != VISIBLE) {
            alpha = 0f
            translationY = slidePx
            visibility = VISIBLE
        }
        animate().alpha(1f).translationY(0f).setDuration(ENTER_MS).withEndAction(null).start()
    }

    /** Slides down and fades out, then goes GONE (GONE windows do not count for touch occlusion). */
    fun disappear() {
        showing = false
        hot = false
        animate().alpha(0f).translationY(slidePx).setDuration(EXIT_MS).withEndAction {
            // A newer appear() cancels this animation, which still runs the end action.
            if (!showing) visibility = GONE
        }.start()
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        shade.shader = LinearGradient(0f, 0f, 0f, h.toFloat(), Color.TRANSPARENT, SHADE_COLOR, Shader.TileMode.CLAMP)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), shade)
        val cx = width / 2f
        val cy = height - bottomGapPx.toFloat()
        val r = CIRCLE_DP * density / 2 * (if (hot) HOT_SCALE else 1f)
        fill.color = if (hot) hotColor else idleColor
        canvas.drawCircle(cx, cy, r, fill)
        val arm = CROSS_DP * density / 2
        canvas.drawLine(cx - arm, cy - arm, cx + arm, cy + arm, cross)
        canvas.drawLine(cx - arm, cy + arm, cx + arm, cy - arm, cross)
    }

    private companion object {
        const val AREA_DP = 200f
        const val CIRCLE_DP = 64f
        const val HOT_SCALE = 1.2f
        const val CROSS_DP = 18f
        const val SLIDE_DP = 48f
        const val ENTER_MS = 200L
        const val EXIT_MS = 150L
        val SHADE_COLOR = Color.argb(150, 0, 0, 0)
    }
}
