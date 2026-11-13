package com.ambatrans.app.bubble

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowInsets
import android.view.WindowManager
import com.ambatrans.app.data.SettingsStore
import kotlin.math.abs

/** Callbacks from the bubble. The service decides what each one does. */
interface BubbleActions {
    /** Short tap: translate the screen, again if a translation is already showing. */
    fun onTap()

    /** Long press: remove the bubble (stops the service). */
    fun onLongPress()
}

/**
 * Floating bubble (F-02): drag, snap to an edge, tap to translate, long press to remove.
 * Must be used from the main thread.
 */
class BubbleController(
    private val context: Context,
    private val store: SettingsStore,
    private val actions: BubbleActions,
) {
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density
    private val touchSlop = TOUCH_SLOP_DP * density

    private var view: BubbleView? = null
    private var params: WindowManager.LayoutParams? = null
    private var snapAnimator: ValueAnimator? = null
    private var overlayActive = false
    private val fadeRunnable = Runnable { if (!loading) view?.fadeTo(BubbleView.FADED_ALPHA) }
    private val longPressRunnable = Runnable {
        if (!moved) {
            longPressed = true
            actions.onLongPress()
        }
    }
    private var loading = false
    private var longPressed = false

    val isShown: Boolean get() = view != null

    fun show() {
        if (view != null) return
        val bubble = BubbleView(context)
        val usable = usableBounds()
        val size = bubble.windowSize
        val layout = baseParams(size, size, focusable = false).apply {
            x = BubbleGeometry.snappedX(store.bubbleEdge, size, usable)
            y = BubbleGeometry.yFor(store.bubbleYFraction, size, usable)
        }
        bubble.overlayActive = overlayActive
        bubble.setOnTouchListener { _, event -> onBubbleTouch(bubble, layout, event) }
        windowManager.addView(bubble, layout)
        view = bubble
        params = layout
        scheduleFade()
    }

    /** Removes the bubble and menu from screen, e.g. while capturing. Position is kept. */
    fun hide() {
        handler.removeCallbacks(fadeRunnable)
        handler.removeCallbacks(longPressRunnable)
        snapAnimator?.cancel()
        view?.let { runCatching { windowManager.removeView(it) } }
        view = null
        params = null
    }

    fun destroy() = hide()

    fun setLoading(loading: Boolean) {
        this.loading = loading
        view?.loading = loading
        if (loading) {
            handler.removeCallbacks(fadeRunnable)
            view?.fadeTo(BubbleView.ACTIVE_ALPHA)
        } else {
            scheduleFade()
        }
    }

    /** Back to resting opacity now, faded after [IDLE_FADE_MS] without interaction. */
    private fun scheduleFade() {
        handler.removeCallbacks(fadeRunnable)
        view?.fadeTo(BubbleView.IDLE_ALPHA)
        handler.postDelayed(fadeRunnable, IDLE_FADE_MS)
    }

    fun setOverlayActive(active: Boolean) {
        overlayActive = active
        view?.overlayActive = active
    }

    private fun onBubbleTouch(bubble: BubbleView, layout: WindowManager.LayoutParams, event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                touchDownX = event.rawX
                touchDownY = event.rawY
                startX = layout.x
                startY = layout.y
                moved = false
                longPressed = false
                snapAnimator?.cancel()
                handler.removeCallbacks(fadeRunnable)
                bubble.fadeTo(BubbleView.ACTIVE_ALPHA)
                handler.postDelayed(longPressRunnable, LONG_PRESS_MS)
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = event.rawX - touchDownX
                val dy = event.rawY - touchDownY
                if (!moved && abs(dx) < touchSlop && abs(dy) < touchSlop) return true
                if (!moved) {
                    moved = true
                    handler.removeCallbacks(longPressRunnable)
                }
                val usable = usableBounds()
                layout.x = BubbleGeometry.clampX(startX + dx.toInt(), bubble.windowSize, usable)
                layout.y = BubbleGeometry.clampY(startY + dy.toInt(), bubble.windowSize, usable)
                windowManager.updateViewLayout(bubble, layout)
            }
            MotionEvent.ACTION_UP -> {
                handler.removeCallbacks(longPressRunnable)
                when {
                    moved -> snapToEdge(bubble, layout)
                    !longPressed -> actions.onTap()
                }
                if (!loading) scheduleFade()
            }
            MotionEvent.ACTION_CANCEL -> {
                handler.removeCallbacks(longPressRunnable)
                if (moved) snapToEdge(bubble, layout)
                if (!loading) scheduleFade()
            }
        }
        return true
    }

    private var touchDownX = 0f
    private var touchDownY = 0f
    private var startX = 0
    private var startY = 0
    private var moved = false

    private fun snapToEdge(bubble: BubbleView, layout: WindowManager.LayoutParams) {
        val usable = usableBounds()
        val size = bubble.windowSize
        val edge = BubbleGeometry.edgeFor(layout.x + size / 2, usable.left + usable.width)
        val targetX = BubbleGeometry.snappedX(edge, size, usable)
        store.set(SettingsStore.KEY_BUBBLE_EDGE, edge)
        store.set(SettingsStore.KEY_BUBBLE_Y_FRACTION, BubbleGeometry.fractionFor(layout.y, size, usable).toDouble())
        snapAnimator = ValueAnimator.ofInt(layout.x, targetX).apply {
            duration = SNAP_MS
            addUpdateListener {
                layout.x = it.animatedValue as Int
                if (bubble.isAttachedToWindow) windowManager.updateViewLayout(bubble, layout)
            }
            start()
        }
    }

    private fun baseParams(width: Int, height: Int, focusable: Boolean): WindowManager.LayoutParams {
        var flags = WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        if (!focusable) flags = flags or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        return WindowManager.LayoutParams(
            width,
            height,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            flags,
            PixelFormat.TRANSLUCENT,
        ).apply { gravity = Gravity.TOP or Gravity.START }
    }

    /** Screen area clear of status bar, navigation bar and cutout, in display coordinates. */
    private fun usableBounds(): Bounds {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val metrics = windowManager.currentWindowMetrics
            val insets = metrics.windowInsets.getInsetsIgnoringVisibility(
                WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout(),
            )
            val b = metrics.bounds
            return Bounds(b.left + insets.left, b.top + insets.top, b.right - insets.right, b.bottom - insets.bottom)
        }
        val res = context.resources
        val display = res.displayMetrics
        return Bounds(
            0,
            systemDimen("status_bar_height"),
            display.widthPixels,
            display.heightPixels - systemDimen("navigation_bar_height"),
        )
    }

    private fun systemDimen(name: String): Int {
        val id = context.resources.getIdentifier(name, "dimen", "android")
        return if (id > 0) context.resources.getDimensionPixelSize(id) else 0
    }

    private companion object {
        const val TOUCH_SLOP_DP = 8f
        const val SNAP_MS = 150L
        const val IDLE_FADE_MS = 2_000L
        const val LONG_PRESS_MS = 450L
    }
}
