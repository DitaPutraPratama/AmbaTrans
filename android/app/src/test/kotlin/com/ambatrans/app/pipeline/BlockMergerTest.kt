package com.ambatrans.app.pipeline

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BlockMergerTest {
    private val line = TextBlock("HELLO THERE", 100, 100, 300, 120)

    @Test
    fun `a tight, overlapping, same-size block below continues the paragraph`() {
        assertTrue(BlockMerger.continues(line, TextBlock("FRIEND", 150, 126, 250, 146)))
    }

    @Test
    fun `a far, side-by-side or much bigger block does not`() {
        assertFalse(BlockMerger.continues(line, TextBlock("FRIEND", 150, 140, 250, 160))) // gap 20 > 12
        assertFalse(BlockMerger.continues(line, TextBlock("FRIEND", 320, 126, 400, 146))) // no column overlap
        assertFalse(BlockMerger.continues(line, TextBlock("TITLE", 150, 124, 250, 164))) // 2x the text size
    }

    @Test
    fun `paragraphs merge chains and keep unrelated blocks apart`() {
        val result = BlockMerger.paragraphs(
            listOf(
                TextBlock("ber-", 100, 126, 160, 146),
                line,
                TextBlock("main", 100, 152, 170, 172),
                TextBlock("Other", 100, 600, 170, 620),
            ),
        )
        assertEquals(listOf("HELLO THERE bermain", "Other"), result.map { it.text })
        assertEquals(TextBlock("HELLO THERE bermain", 100, 100, 300, 172, lineHeight = 20), result[0])
    }
}
