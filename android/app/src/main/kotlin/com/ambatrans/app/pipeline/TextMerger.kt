package com.ambatrans.app.pipeline

/** Combines OCR lines with accessibility nodes and drops duplicates of the same text (F-10). */
object TextMerger {
    private const val DUPLICATE_IOU = 0.5f

    /** Accessibility text wins (it is exact); OCR blocks overlapping it by IoU > 0.5 are dropped. */
    fun merge(ocr: List<TextBlock>, tree: List<TextBlock>): List<TextBlock> {
        if (tree.isEmpty()) return ocr
        val uniqueOcr = ocr.filter { line -> tree.none { iou(line, it) > DUPLICATE_IOU } }
        return tree + uniqueOcr
    }

    fun iou(a: TextBlock, b: TextBlock): Float {
        val w = minOf(a.right, b.right) - maxOf(a.left, b.left)
        val h = minOf(a.bottom, b.bottom) - maxOf(a.top, b.top)
        if (w <= 0 || h <= 0) return 0f
        val inter = w.toLong() * h
        val union = a.width.toLong() * a.height + b.width.toLong() * b.height - inter
        return if (union <= 0) 0f else inter.toFloat() / union
    }
}
