package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect

/** Box math for the region selector: draw, resize by a corner, move. All values in pixels. */
object RegionGeometry {
    const val NONE = -1
    const val TOP_LEFT = 0
    const val TOP_RIGHT = 1
    const val BOTTOM_RIGHT = 2
    const val BOTTOM_LEFT = 3

    /** The box spanned by two points, clamped to [bounds]. */
    fun fromPoints(x1: Int, y1: Int, x2: Int, y2: Int, bounds: ScreenRect): ScreenRect {
        val ax = x1.coerceIn(bounds.left, bounds.right)
        val bx = x2.coerceIn(bounds.left, bounds.right)
        val ay = y1.coerceIn(bounds.top, bounds.bottom)
        val by = y2.coerceIn(bounds.top, bounds.bottom)
        return ScreenRect(minOf(ax, bx), minOf(ay, by), maxOf(ax, bx), maxOf(ay, by))
    }

    /** Which corner handle is within [radius] of (x, y), or [NONE]. */
    fun cornerAt(r: ScreenRect, x: Int, y: Int, radius: Int): Int {
        val corners = listOf(r.left to r.top, r.right to r.top, r.right to r.bottom, r.left to r.bottom)
        return corners.indexOfFirst { (cx, cy) ->
            val dx = (x - cx).toLong()
            val dy = (y - cy).toLong()
            dx * dx + dy * dy <= radius.toLong() * radius
        }
    }

    /** Moves [corner] to (x, y) inside [bounds]; the opposite corner stays, the box keeps [minSize]. */
    fun resize(r: ScreenRect, corner: Int, x: Int, y: Int, minSize: Int, bounds: ScreenRect): ScreenRect {
        val cx = x.coerceIn(bounds.left, bounds.right)
        val cy = y.coerceIn(bounds.top, bounds.bottom)
        val leftSide = corner == TOP_LEFT || corner == BOTTOM_LEFT
        val topSide = corner == TOP_LEFT || corner == TOP_RIGHT
        return ScreenRect(
            left = if (leftSide) minOf(cx, r.right - minSize) else r.left,
            top = if (topSide) minOf(cy, r.bottom - minSize) else r.top,
            right = if (leftSide) r.right else maxOf(cx, r.left + minSize),
            bottom = if (topSide) r.bottom else maxOf(cy, r.top + minSize),
        )
    }

    /** Shifts the box by (dx, dy), keeping its size and staying inside [bounds]. */
    fun move(r: ScreenRect, dx: Int, dy: Int, bounds: ScreenRect): ScreenRect {
        val left = (r.left + dx).coerceIn(bounds.left, (bounds.right - r.width).coerceAtLeast(bounds.left))
        val top = (r.top + dy).coerceIn(bounds.top, (bounds.bottom - r.height).coerceAtLeast(bounds.top))
        return ScreenRect(left, top, left + r.width, top + r.height)
    }
}
