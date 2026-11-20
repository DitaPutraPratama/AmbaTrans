package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect
import com.ambatrans.app.pipeline.TextBlock

/** Final label rectangle (screen px) and text settings. */
data class LabelFit(val left: Int, val top: Int, val width: Int, val height: Int, val sizeSp: Float, val maxLines: Int)

/**
 * Chooses a label size and rectangle. The original OCR box is used when the translation fits at a readable
 * size; otherwise the label grows (wider first, then taller) around the box centre, but never out of [room]
 * (see [LabelRoom]): when the room is too small the text shrinks, and only as a last resort is it cut.
 */
object LabelPlacer {
    private val widthFactors = floatArrayOf(1.3f, 1.7f, 2.2f)
    private const val GROWN_HEIGHT_FACTOR = 2
    private const val LAST_RESORT_HEIGHT_FACTOR = 3
    private const val COMFORT_FRACTION = 0.85f
    private const val READABLE_SP = 16f

    /** [scale] is the user's text size setting (1 = normal); it scales the minimum and the readable size. */
    @Suppress("LongParameterList")
    fun place(
        text: String,
        box: TextBlock,
        room: ScreenRect,
        padH: Int,
        padV: Int,
        pxPerSp: Float,
        measurer: Measurer,
        scale: Float = 1f,
    ): LabelFit {
        val minSp = FontFitter.MIN_SP * scale
        // The size comes from one line of the original text, not the whole block: a two-line paragraph must
        // not get letters twice as big as a one-line text of the same size.
        val lineSpace = (box.lineHeight.coerceAtMost(box.height) - 2 * padV).coerceAtLeast(1)

        fun fitIn(width: Int, height: Int) = FontFitter.fit(
            text = text,
            widthPx = (width - 2 * padH).coerceAtLeast(1),
            heightPx = (height - 2 * padV).coerceAtLeast(1),
            pxPerSp = pxPerSp,
            measurer = measurer,
            startHeightPx = lineSpace,
            minSp = minSp,
        )

        // Text counts as comfortable when it keeps most of its natural size, but never needs more than READABLE_SP.
        val startSize = FontFitter.startSize(lineSpace, pxPerSp, minSp)
        val comfortable = minOf(startSize * COMFORT_FRACTION, READABLE_SP * scale).coerceAtLeast(minSp)

        val original = fitIn(box.width, box.height)
        if (original.maxLines == Int.MAX_VALUE && original.sizeSp >= comfortable) {
            return rect(box, box.width, box.height, original, room)
        }

        var best: LabelFit? = original.takeIf { it.maxLines == Int.MAX_VALUE }
            ?.let { rect(box, box.width, box.height, it, room) }
        val maxWidth = room.width.coerceAtLeast(box.width)
        val grownHeight = (box.height * GROWN_HEIGHT_FACTOR).coerceAtMost(room.height).coerceAtLeast(box.height)
        val widths = widthFactors.map { (box.width * it).toInt().coerceAtMost(maxWidth) } + maxWidth
        for (width in widths.distinct()) {
            val fit = fitIn(width, grownHeight)
            if (fit.maxLines != Int.MAX_VALUE) continue
            val used = measurer.measure(text, fit.sizeSp, (width - 2 * padH).coerceAtLeast(1)).heightPx + 2 * padV
            val candidate = rect(box, width, used.coerceIn(box.height, grownHeight), fit, room)
            if (best == null || candidate.sizeSp > best.sizeSp) best = candidate
            if (candidate.sizeSp >= comfortable) break
        }
        best?.let { return it }
        val height = (box.height * LAST_RESORT_HEIGHT_FACTOR).coerceAtMost(room.height).coerceAtLeast(box.height)
        return rect(box, maxWidth, height, fitIn(maxWidth, height), room)
    }

    /** Centred on the box, then pushed inside [room]. */
    private fun rect(box: TextBlock, width: Int, height: Int, fit: Fit, room: ScreenRect): LabelFit {
        val centerX = (box.left + box.right) / 2
        val centerY = (box.top + box.bottom) / 2
        val left = (centerX - width / 2).coerceIn(room.left, (room.right - width).coerceAtLeast(room.left))
        val top = (centerY - height / 2).coerceIn(room.top, (room.bottom - height).coerceAtLeast(room.top))
        return LabelFit(left, top, width, height, fit.sizeSp, fit.maxLines)
    }
}
