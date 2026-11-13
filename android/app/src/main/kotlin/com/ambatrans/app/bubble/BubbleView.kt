package com.ambatrans.app.bubble

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.View
import android.view.animation.LinearInterpolator
import androidx.core.content.ContextCompat
import com.ambatrans.app.R

/** The 56 dp round bubble (S-07): idle, dragging, loading and "overlay active" states. */
class BubbleView(context: Context) : View(context) {
    private val density = resources.displayMetrics.density
    private val circleSize = BUBBLE_DP * density
    private val shadowPad = SHADOW_DP * density

    /** Full window size in px: the circle plus room for its shadow. */
    val windowSize: Int = (circleSize + 2 * shadowPad).toInt()

    private val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = ContextCompat.getColor(context, R.color.bubble_primary)
        setShadowLayer(shadowPad * 0.6f, 0f, density * 2, Color.argb(80, 0, 0, 0))
    }
    private val dot = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = ContextCompat.getColor(context, R.color.bubble_success)
    }
    private val dotRing = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
    private val spinner = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 3 * density
        strokeCap = Paint.Cap.ROUND
    }
    private val icon = ContextCompat.getDrawable(context, R.drawable.ic_stat_translate)!!
    private val arc = RectF()
    private var sweepStart = 0f
    private var spinnerAnimator: ValueAnimator? = null

    var loading = false
        set(value) {
            if (field == value) return
            field = value
            if (value) startSpinner() else stopSpinner()
            invalidate()
        }

    var overlayActive = false
        set(value) {
            field = value
            invalidate()
        }

    /** Full opacity while touched or loading, [IDLE_ALPHA] resting, [FADED_ALPHA] after a quiet spell. */
    fun fadeTo(target: Float) {
        animate().alpha(target).setDuration(FADE_MS).start()
    }

    init {
        setLayerType(LAYER_TYPE_SOFTWARE, null) // setShadowLayer needs software rendering
        alpha = IDLE_ALPHA
        contentDescription = context.getString(R.string.bubble_description)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(windowSize, windowSize)
    }

    override fun onDraw(canvas: Canvas) {
        val c = width / 2f
        val r = circleSize / 2f
        canvas.drawCircle(c, c, r, fill)
        if (loading) {
            val inset = r * 0.45f
            arc.set(c - inset, c - inset, c + inset, c + inset)
            canvas.drawArc(arc, sweepStart, SWEEP_DEGREES, false, spinner)
        } else {
            val half = (ICON_DP * density / 2).toInt()
            icon.setBounds((c - half).toInt(), (c - half).toInt(), (c + half).toInt(), (c + half).toInt())
            icon.draw(canvas)
        }
        if (overlayActive) {
            val dotR = DOT_DP * density / 2
            val dx = c + r * 0.7f
            val dy = c - r * 0.7f
            canvas.drawCircle(dx, dy, dotR + density, dotRing)
            canvas.drawCircle(dx, dy, dotR, dot)
        }
    }

    private fun startSpinner() {
        spinnerAnimator = ValueAnimator.ofFloat(0f, FULL_TURN).apply {
            duration = SPIN_MS
            repeatCount = ValueAnimator.INFINITE
            interpolator = LinearInterpolator()
            addUpdateListener {
                sweepStart = it.animatedValue as Float
                invalidate()
            }
            start()
        }
    }

    private fun stopSpinner() {
        spinnerAnimator?.cancel()
        spinnerAnimator = null
    }

    override fun onDetachedFromWindow() {
        stopSpinner()
        super.onDetachedFromWindow()
    }

    companion object {
        const val IDLE_ALPHA = 0.9f
        const val FADED_ALPHA = 0.35f
        const val ACTIVE_ALPHA = 1f
        private const val FADE_MS = 250L
        private const val BUBBLE_DP = 56f
        private const val SHADOW_DP = 8f
        private const val ICON_DP = 24f
        private const val DOT_DP = 12f
        private const val SWEEP_DEGREES = 270f
        private const val FULL_TURN = 360f
        private const val SPIN_MS = 900L
    }
}
