package com.ambatrans.app.bubble

/** Plain rectangle so geometry stays testable on the JVM (no android.graphics). */
data class Bounds(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top
}

/** Position math for the bubble. All values are in pixels. */
object BubbleGeometry {
    const val EDGE_LEFT = "left"
    const val EDGE_RIGHT = "right"

    fun edgeFor(centerX: Int, screenWidth: Int): String = if (centerX < screenWidth / 2) EDGE_LEFT else EDGE_RIGHT

    fun snappedX(edge: String, size: Int, usable: Bounds): Int =
        if (edge == EDGE_LEFT) usable.left else usable.right - size

    fun yFor(fraction: Float, size: Int, usable: Bounds): Int {
        val range = (usable.height - size).coerceAtLeast(0)
        return usable.top + (fraction.coerceIn(0f, 1f) * range).toInt()
    }

    fun fractionFor(y: Int, size: Int, usable: Bounds): Float {
        val range = usable.height - size
        if (range <= 0) return 0f
        return ((y - usable.top).toFloat() / range).coerceIn(0f, 1f)
    }

    fun clampX(x: Int, size: Int, usable: Bounds): Int =
        x.coerceIn(usable.left, (usable.right - size).coerceAtLeast(usable.left))

    fun clampY(y: Int, size: Int, usable: Bounds): Int =
        y.coerceIn(usable.top, (usable.bottom - size).coerceAtLeast(usable.top))
}
