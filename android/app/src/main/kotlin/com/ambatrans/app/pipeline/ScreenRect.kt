package com.ambatrans.app.pipeline

/** Rectangle in screen pixels (plain Ints so it stays testable on the JVM). */
data class ScreenRect(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top

    fun contains(x: Int, y: Int): Boolean = x in left..right && y in top..bottom

    /** The part inside a [width] x [height] image, or null when nothing is left. */
    fun clampTo(width: Int, height: Int): ScreenRect? {
        val r =
            ScreenRect(
                left.coerceIn(0, width),
                top.coerceIn(0, height),
                right.coerceIn(0, width),
                bottom.coerceIn(0, height),
            )
        return if (r.width > 0 && r.height > 0) r else null
    }
}
