package com.ambatrans.app.bubble

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.WindowInsets
import android.view.WindowManager
import com.ambatrans.app.data.SettingsStore
import kotlin.math.abs

/** Callbacks from the bubble. The service decides what each one does. */
interface BubbleActions {
    /** Short tap: translate the screen, again if a translation is already showing. */
    fun onTap()

    /** Long press, or drop on the dismiss target: remove the bubble (stops the service). */
    fun onRemove()
}

/**
 * Floating bubble (F-02): drag, snap to an edge, tap to translate, long press or drop on the "X" to remove.
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
    private var dismissTarget: DismissTargetView? = null
    private var params: WindowManager.LayoutParams? = null
    private var snapAnimator: ValueAnimator? = null
    private var overlayActive = false
    private val fadeRunnable = Runnable { if (!loading) view?.fadeTo(BubbleView.FADED_ALPHA) }
    private val longPressRunnable = Runnable {
        if (!moved) {
            longPressed = true
            actions.onRemove()
        }
    }
    private var loading = false
    private var longPressed = false

    val isShown: Boolean get() = view != null

    fun show() {
        if (view != null) return
        addDismissTarget() // before the bubble, so the bubble is drawn above it
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
        dismissTarget?.let { runCatching { windowManager.removeView(it) } }
        dismissTarget = null
    }

    /** Added hidden (GONE windows are skipped by touch-occlusion checks); shown only while dragging. */
    private fun addDismissTarget() {
        val target = DismissTargetView(context, (DISMISS_GAP_DP * density).toInt())
        val layout = baseParams(usableBounds().width, target.areaHeight, focusable = false).apply {
            flags = flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        }
        windowManager.addView(target, layout)
        dismissTarget = target
    }

    private fun showDismissTarget() {
        val target = dismissTarget ?: return
        val layout = target.layoutParams as WindowManager.LayoutParams
        val usable = usableBounds() // re-read: the screen may have rotated
        layout.x = usable.left
        layout.y = usable.bottom - target.areaHeight
        layout.width = usable.width
        windowManager.updateViewLayout(target, layout)
        target.appear()
    }

    private fun hideDismissTarget() {
        dismissTarget?.disappear()
    }

    private fun setDismissHot(bubble: BubbleView, hot: Boolean) {
        val target = dismissTarget ?: return
        if (target.hot == hot) return
        target.hot = hot
        if (hot) bubble.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
    }

    private fun dismissCenter(usable: Bounds) = BubbleGeometry.dismissCenter(usable, (DISMISS_GAP_DP * density).toInt())

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
                    showDismissTarget()
                }
                moveBubble(bubble, layout, dx, dy)
            }
            MotionEvent.ACTION_UP -> {
                handler.removeCallbacks(longPressRunnable)
                val dismiss = dismissTarget?.hot == true
                hideDismissTarget()
                when {
                    dismiss -> {
                        actions.onRemove()
                        return true
                    }
                    moved -> snapToEdge(bubble, layout)
                    !longPressed -> actions.onTap()
                }
                if (!loading) scheduleFade()
            }
            MotionEvent.ACTION_CANCEL -> {
                handler.removeCallbacks(longPressRunnable)
                hideDismissTarget()
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

    /** Follows the finger; near the dismiss target the bubble sticks to it. */
    private fun moveBubble(bubble: BubbleView, layout: WindowManager.LayoutParams, dx: Float, dy: Float) {
        val usable = usableBounds()
        val size = bubble.windowSize
        layout.x = BubbleGeometry.clampX(startX + dx.toInt(), size, usable)
        layout.y = BubbleGeometry.clampY(startY + dy.toInt(), size, usable)
        val (cx, cy) = dismissCenter(usable)
        val hot = BubbleGeometry.isNear(
            layout.x + size / 2,
            layout.y + size / 2,
            cx,
            cy,
            (DISMISS_RADIUS_DP * density).toInt(),
        )
        if (hot) {
            layout.x = cx - size / 2
            layout.y = cy - size / 2
        }
        setDismissHot(bubble, hot)
        windowManager.updateViewLayout(bubble, layout)
    }

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
        const val DISMISS_GAP_DP = 72f
        const val DISMISS_RADIUS_DP = 64f
    }
}
