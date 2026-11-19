package com.ambatrans.app.pipeline

import com.ambatrans.app.ocr.joinLines

/**
 * Region mode: all text found inside the user's box is one sentence, e.g. a comic speech bubble whose
 * text OCR split over several lines or blocks. Hyphenated breaks ("ber-" + "main") are rejoined.
 */
object RegionText {
    fun merge(blocks: List<TextBlock>): TextBlock? {
        // ponytail: reading order is top, then left; side-by-side blocks with slightly different tops may
        // swap. Group blocks into rows if that shows up on real screens.
        val ordered = blocks.sortedWith(compareBy<TextBlock> { it.top }.thenBy { it.left })
        val text = joinLines(ordered.map { it.text })
        if (!TextFilter.isTranslatable(text)) return null
        return TextBlock(
            text,
            ordered.minOf { it.left },
            ordered.minOf { it.top },
            ordered.maxOf { it.right },
            ordered.maxOf { it.bottom },
        )
    }
}
