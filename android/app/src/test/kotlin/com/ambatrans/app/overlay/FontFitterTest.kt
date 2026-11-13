package com.ambatrans.app.overlay

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FontFitterTest {
    // Each character is 0.5 * size wide; lines wrap by width; line height = 1.2 * size.
    private val wrapping = Measurer { text, sizeSp, widthPx ->
        val charsPerLine = (widthPx / (sizeSp * 0.5f)).toInt().coerceAtLeast(1)
        val lines = (text.length + charsPerLine - 1) / charsPerLine
        val lineHeight = (sizeSp * 1.2f).toInt()
        TextMeasure(lines * lineHeight, lineHeight)
    }

    @Test
    fun `short text keeps the starting size of 70 percent of the box height`() {
        val fit = FontFitter.fit("Hi", widthPx = 200, heightPx = 40, pxPerSp = 1f, measurer = wrapping)
        assertEquals(28f, fit.sizeSp, 0.001f)
        assertEquals(Int.MAX_VALUE, fit.maxLines)
    }

    @Test
    fun `long text shrinks until it fits`() {
        val text = "x".repeat(40)
        val fit = FontFitter.fit(text, widthPx = 200, heightPx = 40, pxPerSp = 1f, measurer = wrapping)
        assertTrue(fit.sizeSp < 28f)
        assertTrue(fit.sizeSp >= FontFitter.MIN_SP)
        assertEquals(Int.MAX_VALUE, fit.maxLines)
        assertTrue(wrapping.measure(text, fit.sizeSp, 200).heightPx <= 40)
    }

    @Test
    fun `never goes below the minimum size and truncates with a line limit`() {
        val text = "x".repeat(2000)
        val fit = FontFitter.fit(text, widthPx = 100, heightPx = 30, pxPerSp = 1f, measurer = wrapping)
        assertEquals(FontFitter.MIN_SP, fit.sizeSp, 0.001f)
        // 30 px box / (10 * 1.2 = 12 px line) = 2 lines
        assertEquals(2, fit.maxLines)
    }

    @Test
    fun `at least one line even when the box is smaller than a line`() {
        val fit = FontFitter.fit("x".repeat(500), widthPx = 50, heightPx = 4, pxPerSp = 1f, measurer = wrapping)
        assertEquals(FontFitter.MIN_SP, fit.sizeSp, 0.001f)
        assertEquals(1, fit.maxLines)
    }

    @Test
    fun `starting size is capped for very tall boxes`() {
        val fit = FontFitter.fit("Hi", widthPx = 500, heightPx = 400, pxPerSp = 1f, measurer = wrapping)
        assertEquals(30f, fit.sizeSp, 0.001f)
    }

    @Test
    fun `starting size accounts for pixels per sp`() {
        val fit = FontFitter.fit("Hi", widthPx = 500, heightPx = 100, pxPerSp = 2f, measurer = wrapping)
        assertEquals(30f.coerceAtMost(100 * 0.7f / 2f), fit.sizeSp, 0.001f)
    }
}
