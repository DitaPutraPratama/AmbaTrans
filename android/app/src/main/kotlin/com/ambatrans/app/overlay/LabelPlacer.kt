package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.TextBlock

/** Final label rectangle (screen px) and text settings. */
data class LabelFit(val left: Int, val top: Int, val width: Int, val height: Int, val sizeSp: Float, val maxLines: Int)

/**
 * Chooses a label size and rectangle. The original OCR box is used when the translation fits at a readable
 * size; otherwise the label grows (wider first, then taller) around the box centre instead of cutting letters.
 */
object LabelPlacer {
    private val widthFactors = floatArrayOf(1.3f, 1.7f, 2.2f)
    private const val GROWN_HEIGHT_FACTOR = 2
    private const val LAST_RESORT_HEIGHT_FACTOR = 3
    private const val COMFORT_FRACTION = 0.85f
    private const val READABLE_SP = 14f

    @Suppress("LongParameterList")
    fun place(
        text: String,
        box: TextBlock,
        screenWidth: Int,
        screenHeight: Int,
        padH: Int,
        padV: Int,
        pxPerSp: Float,
        measurer: Measurer,
    ): LabelFit {
        fun fitIn(width: Int, height: Int) = FontFitter.fit(
            text = text,
            widthPx = (width - 2 * padH).coerceAtLeast(1),
            heightPx = (height - 2 * padV).coerceAtLeast(1),
            pxPerSp = pxPerSp,
            measurer = measurer,
            startHeightPx = (box.height - 2 * padV).coerceAtLeast(1),
        )

        // Text counts as comfortable when it keeps most of its natural size, but never needs more than READABLE_SP.
        val startSize = FontFitter.startSize((box.height - 2 * padV).coerceAtLeast(1), pxPerSp)
        val comfortable = minOf(startSize * COMFORT_FRACTION, READABLE_SP).coerceAtLeast(FontFitter.MIN_SP)

        val original = fitIn(box.width, box.height)
        if (original.maxLines == Int.MAX_VALUE && original.sizeSp >= comfortable) {
            return rect(box, box.width, box.height, original, screenWidth, screenHeight)
        }

        var best: LabelFit? = original.takeIf { it.maxLines == Int.MAX_VALUE }
            ?.let { rect(box, box.width, box.height, it, screenWidth, screenHeight) }
        val maxWidth = (screenWidth - 2 * padH).coerceAtLeast(box.width)
        val widths = widthFactors.map { (box.width * it).toInt().coerceAtMost(maxWidth) } + maxWidth
        for (width in widths) {
            val fit = fitIn(width, box.height * GROWN_HEIGHT_FACTOR)
            if (fit.maxLines != Int.MAX_VALUE) continue
            val used = measurer.measure(text, fit.sizeSp, (width - 2 * padH).coerceAtLeast(1)).heightPx + 2 * padV
            val candidate = rect(box, width, used.coerceAtLeast(box.height), fit, screenWidth, screenHeight)
            if (best == null || candidate.sizeSp > best.sizeSp) best = candidate
            if (candidate.sizeSp >= comfortable) break
        }
        best?.let { return it }
        val height = box.height * LAST_RESORT_HEIGHT_FACTOR
        return rect(box, maxWidth, height, fitIn(maxWidth, height), screenWidth, screenHeight)
    }

    private fun rect(box: TextBlock, width: Int, height: Int, fit: Fit, screenWidth: Int, screenHeight: Int): LabelFit {
        val centerX = (box.left + box.right) / 2
        val centerY = (box.top + box.bottom) / 2
        val left = (centerX - width / 2).coerceIn(0, (screenWidth - width).coerceAtLeast(0))
        val top = (centerY - height / 2).coerceIn(0, (screenHeight - height).coerceAtLeast(0))
        return LabelFit(left, top, width, height, fit.sizeSp, fit.maxLines)
    }
}
