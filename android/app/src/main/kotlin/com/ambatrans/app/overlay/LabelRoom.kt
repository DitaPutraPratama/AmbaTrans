package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect
import com.ambatrans.app.pipeline.TextBlock

/**
 * Space each label may grow into: from its box up to halfway towards the nearest neighbouring box on every
 * side, so a longer translation never covers the label next to it.
 */
object LabelRoom {
    // ponytail: neighbours above/below are found within the label's horizontal room, not the neighbour's own;
    // two labels that both widen sideways past each other's box can still touch. Fine for stacked text.
    fun compute(boxes: List<TextBlock>, screen: ScreenRect): List<ScreenRect> =
        boxes.indices.map { i -> roomFor(boxes[i], boxes.filterIndexed { j, _ -> j != i }, screen) }

    private fun roomFor(box: TextBlock, others: List<TextBlock>, screen: ScreenRect): ScreenRect {
        // Same row: boxes that share some height with this one.
        val row = others.filter { it.top < box.bottom && it.bottom > box.top }
        val left = row.filter { it.right <= box.left }.maxOfOrNull { (it.right + box.left) / 2 } ?: screen.left
        val right = row.filter { it.left >= box.right }.minOfOrNull { (box.right + it.left) / 2 } ?: screen.right
        // Above and below, within that horizontal room.
        val column = others.filter { it.left < right && it.right > left }
        val top = column.filter { it.bottom <= box.top }.maxOfOrNull { (it.bottom + box.top) / 2 } ?: screen.top
        val bottom = column.filter { it.top >= box.bottom }.minOfOrNull { (box.bottom + it.top) / 2 } ?: screen.bottom
        return ScreenRect(
            minOf(left, box.left),
            minOf(top, box.top),
            maxOf(right, box.right),
            maxOf(bottom, box.bottom),
        )
    }
}
