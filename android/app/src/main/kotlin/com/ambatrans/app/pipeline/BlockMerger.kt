package com.ambatrans.app.pipeline

import com.ambatrans.app.ocr.joinLines

/**
 * ML Kit sometimes splits one paragraph (e.g. a comic speech bubble) into a block per line. This joins
 * blocks stacked tightly on top of each other back into one sentence.
 */
object BlockMerger {
    // ponytail: geometry only; two separate texts stacked this tightly (a title right above its subtitle)
    // are merged too. Add a punctuation or font check if real screens show that.
    private const val MAX_GAP_LINES = 0.6
    private const val MAX_OVERLAP_LINES = 0.5
    private const val MAX_SIZE_RATIO = 1.5

    fun paragraphs(blocks: List<TextBlock>): List<TextBlock> {
        val groups = mutableListOf<MutableList<TextBlock>>()
        for (block in blocks.sortedBy { it.top }) {
            val group = groups.firstOrNull { continues(it.last(), block) }
            if (group != null) group += block else groups += mutableListOf(block)
        }
        return groups.map { if (it.size == 1) it.single() else combine(it) }
    }

    /** True when [below] reads as the next line of [above]: similar text size, small gap, overlapping columns. */
    fun continues(above: TextBlock, below: TextBlock): Boolean {
        val small = minOf(above.lineHeight, below.lineHeight).coerceAtLeast(1)
        val big = maxOf(above.lineHeight, below.lineHeight)
        if (big > small * MAX_SIZE_RATIO) return false
        val gap = below.top - above.bottom
        if (gap > small * MAX_GAP_LINES || gap < -small * MAX_OVERLAP_LINES) return false
        return minOf(above.right, below.right) > maxOf(above.left, below.left)
    }

    /** One block from [blocks] in reading order (top, then left); hyphenated breaks are rejoined. */
    fun combine(blocks: List<TextBlock>): TextBlock {
        val ordered = blocks.sortedWith(compareBy<TextBlock> { it.top }.thenBy { it.left })
        return TextBlock(
            joinLines(ordered.map { it.text }),
            ordered.minOf { it.left },
            ordered.minOf { it.top },
            ordered.maxOf { it.right },
            ordered.maxOf { it.bottom },
            lineHeight = ordered.sumOf { it.lineHeight } / ordered.size,
        )
    }
}
