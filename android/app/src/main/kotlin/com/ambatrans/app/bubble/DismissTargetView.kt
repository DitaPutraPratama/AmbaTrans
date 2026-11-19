package com.ambatrans.app.bubble

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.View
import androidx.core.content.ContextCompat
import com.ambatrans.app.R

/** Round "X" target shown while the bubble is dragged; dropping the bubble on it stops the service. */
class DismissTargetView(context: Context) : View(context) {
    private val density = resources.displayMetrics.density

    /** Window size in px: room for the enlarged (hot) circle. */
    val windowSize: Int = (CIRCLE_DP * HOT_SCALE * density).toInt()

    private val fill = Paint(Paint.ANTI_ALIAS_FLAG)
    private val cross = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 3 * density
        strokeCap = Paint.Cap.ROUND
    }
    private val idleColor = Color.argb(160, 0, 0, 0)
    private val hotColor = ContextCompat.getColor(context, R.color.dismiss_hot)

    var hot = false
        set(value) {
            if (field == value) return
            field = value
            invalidate()
        }

    init {
        contentDescription = context.getString(R.string.dismiss_target_description)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(windowSize, windowSize)
    }

    override fun onDraw(canvas: Canvas) {
        val c = width / 2f
        val r = CIRCLE_DP * density / 2 * (if (hot) HOT_SCALE else 1f)
        fill.color = if (hot) hotColor else idleColor
        canvas.drawCircle(c, c, r, fill)
        val arm = CROSS_DP * density / 2
        canvas.drawLine(c - arm, c - arm, c + arm, c + arm, cross)
        canvas.drawLine(c - arm, c + arm, c + arm, c - arm, cross)
    }

    companion object {
        const val CIRCLE_DP = 64f
        private const val HOT_SCALE = 1.2f
        private const val CROSS_DP = 18f
    }
}
