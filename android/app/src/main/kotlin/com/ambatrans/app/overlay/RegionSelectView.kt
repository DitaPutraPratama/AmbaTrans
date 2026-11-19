package com.ambatrans.app.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.util.TypedValue
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import com.ambatrans.app.R
import com.ambatrans.app.pipeline.ScreenRect
import kotlin.math.abs

/**
 * Full-screen selector for partial mode: dims the screen, the user drags a box, then moves it or resizes it
 * by its corners, and confirms with "Terjemahkan". A tap outside the box, "Batal" or Back cancels.
 */
@SuppressLint("ViewConstructor")
class RegionSelectView(
    context: Context,
    private val onConfirm: (ScreenRect) -> Unit,
    private val onCancel: () -> Unit,
) : View(context) {
    private enum class Drag { NONE, DRAW, MOVE, RESIZE, CONFIRM, CANCEL }

    private val density = resources.displayMetrics.density
    private val touchSlop = 8 * density
    private val minSize = (MIN_BOX_DP * density).toInt()
    private val handleRadius = 8 * density
    private val handleHit = (HANDLE_HIT_DP * density).toInt()

    private val dim = Paint().apply { color = Color.argb(DIM_ALPHA, 0, 0, 0) }
    private val border = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 2 * density
    }
    private val handle = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
    private val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textAlign = Paint.Align.CENTER
        textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 15f, resources.displayMetrics)
        isFakeBoldText = true
    }
    private val outline = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 1.5f * density
        color = Color.WHITE
    }
    private val hint = context.getString(R.string.region_hint)
    private val confirmLabel = context.getString(R.string.region_translate)
    private val cancelLabel = context.getString(R.string.region_cancel)
    private val confirmButton = RectF()
    private val cancelButton = RectF()
    private val shade = Path()

    private var box: ScreenRect? = null
    private var drag = Drag.NONE
    private var corner = RegionGeometry.NONE
    private var startBox: ScreenRect? = null
    private var downX = 0f
    private var downY = 0f
    private var dragged = false

    init {
        isFocusableInTouchMode = true
        contentDescription = hint
        alpha = 0f
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        requestFocus()
        animate().alpha(1f).setDuration(FADE_MS).start()
    }

    private fun bounds() = ScreenRect(0, 0, width, height)

    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        val x = event.x.toInt()
        val y = event.y.toInt()
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> onDown(event.x, event.y)
            MotionEvent.ACTION_MOVE -> {
                if (!dragged && abs(event.x - downX) < touchSlop && abs(event.y - downY) < touchSlop) return true
                dragged = true
                onDrag(x, y)
            }
            MotionEvent.ACTION_UP -> onUp(event.x, event.y)
            MotionEvent.ACTION_CANCEL -> drag = Drag.NONE
        }
        return true
    }

    private fun onDown(x: Float, y: Float) {
        downX = x
        downY = y
        dragged = false
        val b = box
        corner = b?.let { RegionGeometry.cornerAt(it, x.toInt(), y.toInt(), handleHit) } ?: RegionGeometry.NONE
        drag = when {
            b != null && confirmButton.contains(x, y) -> Drag.CONFIRM
            b != null && cancelButton.contains(x, y) -> Drag.CANCEL
            corner != RegionGeometry.NONE -> Drag.RESIZE
            b != null && b.contains(x.toInt(), y.toInt()) -> Drag.MOVE
            else -> Drag.DRAW
        }
        startBox = b
    }

    private fun onDrag(x: Int, y: Int) {
        val start = startBox
        box = when (drag) {
            Drag.DRAW -> RegionGeometry.fromPoints(downX.toInt(), downY.toInt(), x, y, bounds())
            Drag.RESIZE -> start?.let { RegionGeometry.resize(it, corner, x, y, minSize, bounds()) }
            Drag.MOVE -> start?.let { RegionGeometry.move(it, x - downX.toInt(), y - downY.toInt(), bounds()) }
            else -> return
        }
        invalidate()
    }

    private fun onUp(x: Float, y: Float) {
        val b = box
        when {
            drag == Drag.CONFIRM && confirmButton.contains(x, y) && b != null -> confirm(b)
            drag == Drag.CANCEL && cancelButton.contains(x, y) -> onCancel()
            drag == Drag.DRAW && !dragged -> onCancel() // a tap outside the box
            drag == Drag.DRAW && b != null -> {
                // A box smaller than the minimum grows from its top-left corner.
                box = RegionGeometry.resize(b, RegionGeometry.BOTTOM_RIGHT, b.right, b.bottom, minSize, bounds())
                    .let { RegionGeometry.move(it, 0, 0, bounds()) }
                invalidate()
            }
        }
        drag = Drag.NONE
    }

    private fun confirm(b: ScreenRect) {
        val origin = IntArray(2).also { getLocationOnScreen(it) }
        onConfirm(ScreenRect(b.left + origin[0], b.top + origin[1], b.right + origin[0], b.bottom + origin[1]))
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode != KeyEvent.KEYCODE_BACK) return super.dispatchKeyEvent(event)
        if (event.action == KeyEvent.ACTION_UP) onCancel()
        return true
    }

    override fun onDraw(canvas: Canvas) {
        val b = box
        if (b == null) {
            canvas.drawColor(dim.color)
            text.color = Color.WHITE
            canvas.drawText(hint, width / 2f, height / 3f, text)
            return
        }
        shade.reset()
        shade.fillType = Path.FillType.EVEN_ODD
        shade.addRect(0f, 0f, width.toFloat(), height.toFloat(), Path.Direction.CW)
        shade.addRect(b.left.toFloat(), b.top.toFloat(), b.right.toFloat(), b.bottom.toFloat(), Path.Direction.CW)
        canvas.drawPath(shade, dim)
        canvas.drawRect(b.left.toFloat(), b.top.toFloat(), b.right.toFloat(), b.bottom.toFloat(), border)
        listOf(b.left to b.top, b.right to b.top, b.right to b.bottom, b.left to b.bottom).forEach { (cx, cy) ->
            canvas.drawCircle(cx.toFloat(), cy.toFloat(), handleRadius, handle)
        }
        layoutButtons(b)
        drawButton(canvas, confirmButton, confirmLabel, filled = true)
        drawButton(canvas, cancelButton, cancelLabel, filled = false)
    }

    /** Buttons under the box; above it when there is no room; inside its bottom as a last resort. */
    private fun layoutButtons(b: ScreenRect) {
        val w = BUTTON_W_DP * density
        val h = BUTTON_H_DP * density
        val gap = BUTTON_GAP_DP * density
        val margin = SCREEN_MARGIN_DP * density
        val top = when {
            b.bottom + gap + h <= height - margin -> b.bottom + gap
            b.top - gap - h >= margin -> b.top - gap - h
            else -> b.bottom - gap - h
        }
        val total = 2 * w + gap
        val left = ((b.left + b.right) / 2f - total / 2).coerceIn(
            margin,
            (width - margin - total).coerceAtLeast(margin),
        )
        cancelButton.set(left, top, left + w, top + h)
        confirmButton.set(left + w + gap, top, left + total, top + h)
    }

    private fun drawButton(canvas: Canvas, rect: RectF, label: String, filled: Boolean) {
        val radius = rect.height() / 2
        if (filled) {
            canvas.drawRoundRect(rect, radius, radius, handle)
        } else {
            canvas.drawRoundRect(rect, radius, radius, dim)
            canvas.drawRoundRect(rect, radius, radius, outline)
        }
        text.color = if (filled) Color.BLACK else Color.WHITE
        canvas.drawText(label, rect.centerX(), rect.centerY() - (text.ascent() + text.descent()) / 2, text)
    }

    private companion object {
        const val DIM_ALPHA = 120
        const val MIN_BOX_DP = 48f
        const val HANDLE_HIT_DP = 28f
        const val BUTTON_W_DP = 120f
        const val BUTTON_H_DP = 44f
        const val BUTTON_GAP_DP = 12f
        const val SCREEN_MARGIN_DP = 16f
        const val FADE_MS = 150L
    }
}
