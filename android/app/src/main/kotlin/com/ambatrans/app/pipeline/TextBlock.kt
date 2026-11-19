package com.ambatrans.app.pipeline

/**
 * One recognized text unit (a block, see ADR-013) with its box in screen pixels and the average height
 * of its lines. Plain Ints instead of android.graphics.Rect keep the pipeline unit-testable on the JVM.
 */
data class TextBlock(
    val text: String,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val lineHeight: Int = bottom - top,
) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top
}
