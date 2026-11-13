package com.ambatrans.app.overlay

/** Height in px of [text] laid out at a size, plus the height of one line at that size. */
data class TextMeasure(val heightPx: Int, val lineHeightPx: Int)

fun interface Measurer {
    fun measure(text: String, sizeSp: Float, widthPx: Int): TextMeasure
}

/** [maxLines] is [Int.MAX_VALUE] when the text fits without truncation. */
data class Fit(val sizeSp: Float, val maxLines: Int)

/** Picks a label font size: start near 70% of the box height, shrink to 8 sp, then truncate (F-07). */
object FontFitter {
    const val MIN_SP = 8f
    private const val MAX_SP = 30f
    private const val START_FRACTION = 0.7f
    private const val STEP_SP = 1f

    fun fit(text: String, widthPx: Int, heightPx: Int, pxPerSp: Float, measurer: Measurer): Fit {
        var size = (heightPx * START_FRACTION / pxPerSp).coerceIn(MIN_SP, MAX_SP)
        while (true) {
            val measure = measurer.measure(text, size, widthPx)
            if (measure.heightPx <= heightPx) return Fit(size, Int.MAX_VALUE)
            if (size <= MIN_SP) {
                return Fit(MIN_SP, (heightPx / measure.lineHeightPx.coerceAtLeast(1)).coerceAtLeast(1))
            }
            size = (size - STEP_SP).coerceAtLeast(MIN_SP)
        }
    }
}
