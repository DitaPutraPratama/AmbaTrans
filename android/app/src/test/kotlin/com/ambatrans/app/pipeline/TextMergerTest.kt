package com.ambatrans.app.pipeline

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class TextMergerTest {
    private val node = TextBlock("Settings", 100, 100, 300, 140)

    @Test
    fun `without accessibility nodes OCR passes through`() {
        val ocr = listOf(TextBlock("a", 0, 0, 10, 10))
        assertEquals(ocr, TextMerger.merge(ocr, emptyList()))
    }

    @Test
    fun `an OCR line on top of a node is dropped as a duplicate`() {
        val dup = TextBlock("Setings", 102, 101, 298, 139)
        val other = TextBlock("Photo caption", 100, 500, 400, 540)
        assertEquals(listOf(node, other), TextMerger.merge(listOf(dup, other), listOf(node)))
    }

    @Test
    fun `iou is 0 for disjoint boxes and 1 for identical ones`() {
        assertEquals(0f, TextMerger.iou(node, TextBlock("x", 500, 500, 600, 600)), 0f)
        assertEquals(1f, TextMerger.iou(node, node.copy(text = "y")), 0.0001f)
    }

    @Test
    fun `small overlap is kept as a separate block`() {
        val edge = TextBlock("edge", 290, 100, 500, 140)
        assertTrue(TextMerger.merge(listOf(edge), listOf(node)).contains(edge))
    }
}
