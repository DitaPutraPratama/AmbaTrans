package com.ambatrans.app.pipeline

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class RegionTextTest {
    @Test
    fun `blocks are joined top to bottom, left to right, rejoining hyphenated words`() {
        val merged = RegionText.merge(
            listOf(
                TextBlock("main di taman.", 0, 50, 120, 70),
                TextBlock("Kami ber-", 0, 10, 80, 30),
                TextBlock("Halo!", 0, 90, 40, 110),
            ),
        )
        assertEquals(TextBlock("Kami bermain di taman. Halo!", 0, 10, 120, 110, lineHeight = 20), merged)
    }

    @Test
    fun `nothing translatable gives null`() {
        assertNull(RegionText.merge(emptyList()))
        assertNull(RegionText.merge(listOf(TextBlock("42", 0, 0, 10, 10))))
    }

    @Test
    fun `clampTo keeps the part inside the image`() {
        assertEquals(ScreenRect(0, 5, 100, 50), ScreenRect(-10, 5, 300, 50).clampTo(100, 200))
        assertNull(ScreenRect(150, 0, 300, 50).clampTo(100, 200))
    }
}
