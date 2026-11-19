package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect
import com.ambatrans.app.pipeline.TextBlock
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class LabelPlacerTest {
    private val wrapping = Measurer { text, sizeSp, widthPx ->
        val charsPerLine = (widthPx / (sizeSp * 0.5f)).toInt().coerceAtLeast(1)
        val lines = (text.length + charsPerLine - 1) / charsPerLine
        val lineHeight = (sizeSp * 1.2f).toInt()
        TextMeasure(lines * lineHeight, lineHeight)
    }

    private fun place(text: String, box: TextBlock, room: ScreenRect = ScreenRect(0, 0, 1000, 2000)) =
        LabelPlacer.place(
            text,
            box,
            room = room,
            padH = 4,
            padV = 2,
            pxPerSp = 1f,
            measurer = wrapping,
        )

    @Test
    fun `text that fits keeps the original box`() {
        val box = TextBlock("Hi", 100, 500, 400, 560)
        val fit = place("Halo", box)
        assertEquals(LabelFit(100, 500, 300, 60, fit.sizeSp, Int.MAX_VALUE), fit)
    }

    @Test
    fun `text too long for the box grows the label instead of truncating`() {
        val box = TextBlock("x", 100, 500, 300, 530) // 200 x 30
        val fit = place("x".repeat(60), box)
        assertEquals(Int.MAX_VALUE, fit.maxLines)
        assertTrue(fit.width > box.width || fit.height > box.height)
        assertTrue(fit.sizeSp >= FontFitter.MIN_SP)
    }

    @Test
    fun `grown label is centred on the box and stays on screen`() {
        val nearEdge = TextBlock("x", 800, 1950, 990, 1990) // 190 x 40, bottom right
        val fit = place("x".repeat(80), nearEdge)
        assertTrue(fit.left >= 0 && fit.left + fit.width <= 1000)
        assertTrue(fit.top >= 0 && fit.top + fit.height <= 2000)
    }

    @Test
    fun `a long translation stays inside its room and shrinks instead of growing taller`() {
        val box = TextBlock("x", 300, 500, 500, 530) // 200 x 30
        val room = ScreenRect(0, 495, 1000, 535) // neighbours 5 px above and below
        val fit = place("x".repeat(60), box, room)
        assertTrue(fit.left >= room.left && fit.left + fit.width <= room.right)
        assertTrue(fit.top >= room.top && fit.top + fit.height <= room.bottom)
        assertEquals(Int.MAX_VALUE, fit.maxLines)
        assertTrue(fit.width > box.width) // it grew sideways, where there was space
    }

    @Test
    fun `text of the same original size gets the same label size, however many lines it had`() {
        val oneLine = TextBlock("x", 100, 500, 600, 530) // 500 x 30
        val threeLines = TextBlock("x", 100, 600, 600, 690, lineHeight = 30) // 500 x 90
        assertEquals(place("Halo", oneLine).sizeSp, place("Halo dunia", threeLines).sizeSp, 0.001f)
    }

    @Test
    fun `hopeless text falls back to a truncated label at the minimum size`() {
        val box = TextBlock("x", 0, 0, 100, 20)
        val fit = place("x".repeat(20_000), box)
        assertEquals(FontFitter.MIN_SP, fit.sizeSp, 0.001f)
        assertTrue(fit.maxLines != Int.MAX_VALUE)
    }
}
