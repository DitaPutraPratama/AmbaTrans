package com.ambatrans.app.pipeline

/**
 * Region mode: all text found inside the user's box is one sentence, e.g. a comic speech bubble whose
 * text OCR split over several lines or blocks. Hyphenated breaks ("ber-" + "main") are rejoined.
 */
object RegionText {
    // ponytail: reading order is top, then left; side-by-side blocks with slightly different tops may
    // swap. Group blocks into rows if that shows up on real screens.
    fun merge(blocks: List<TextBlock>): TextBlock? {
        if (blocks.isEmpty()) return null
        return BlockMerger.combine(blocks).takeIf { TextFilter.isTranslatable(it.text) }
    }
}
