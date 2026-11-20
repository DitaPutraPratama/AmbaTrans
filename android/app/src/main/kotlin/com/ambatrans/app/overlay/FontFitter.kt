package com.ambatrans.app.overlay

/** Height in px of [text] laid out at a size, plus the height of one line at that size. */
data class TextMeasure(val heightPx: Int, val lineHeightPx: Int)

fun interface Measurer {
    fun measure(text: String, sizeSp: Float, widthPx: Int): TextMeasure
}

/** [maxLines] is [Int.MAX_VALUE] when the text fits without truncation. */
data class Fit(val sizeSp: Float, val maxLines: Int)

/** Picks a label font size: start near 70% of the box height, shrink to [MIN_SP], then truncate (F-07). */
object FontFitter {
    const val MIN_SP = 12f
    private const val MAX_SP = 30f
    private const val START_FRACTION = 0.7f
    private const val STEP_SP = 1f

    /** Size the text would get if it fit without shrinking. */
    fun startSize(heightPx: Int, pxPerSp: Float, minSp: Float = MIN_SP): Float =
        (heightPx * START_FRACTION / pxPerSp).coerceIn(minSp, MAX_SP.coerceAtLeast(minSp))

    /**
     * [startHeightPx] sets the starting size when [heightPx] is a grown budget larger than the original box.
     * [minSp] is the smallest size before the text is cut (the user's text size setting scales it).
     */
    fun fit(
        text: String,
        widthPx: Int,
        heightPx: Int,
        pxPerSp: Float,
        measurer: Measurer,
        startHeightPx: Int = heightPx,
        minSp: Float = MIN_SP,
    ): Fit {
        var size = startSize(startHeightPx, pxPerSp, minSp)
        while (true) {
            val measure = measurer.measure(text, size, widthPx)
            if (measure.heightPx <= heightPx) return Fit(size, Int.MAX_VALUE)
            if (size <= minSp) {
                return Fit(minSp, (heightPx / measure.lineHeightPx.coerceAtLeast(1)).coerceAtLeast(1))
            }
            size = (size - STEP_SP).coerceAtLeast(minSp)
        }
    }
}
