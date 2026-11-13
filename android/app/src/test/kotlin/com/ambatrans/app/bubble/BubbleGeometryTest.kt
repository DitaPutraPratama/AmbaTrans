package com.ambatrans.app.bubble

import org.junit.Assert.assertEquals
import org.junit.Test

class BubbleGeometryTest {
    private val usable = Bounds(0, 100, 1000, 2000)

    @Test
    fun `edge follows which half the centre is in`() {
        assertEquals("left", BubbleGeometry.edgeFor(100, 1000))
        assertEquals("right", BubbleGeometry.edgeFor(700, 1000))
        assertEquals("right", BubbleGeometry.edgeFor(500, 1000))
    }

    @Test
    fun `snapped x sits on the chosen edge`() {
        assertEquals(0, BubbleGeometry.snappedX("left", 150, usable))
        assertEquals(850, BubbleGeometry.snappedX("right", 150, usable))
    }

    @Test
    fun `y fraction round-trips and survives a taller screen`() {
        val y = BubbleGeometry.yFor(0.35f, 150, usable)
        assertEquals(0.35f, BubbleGeometry.fractionFor(y, 150, usable), 0.01f)
        val tall = Bounds(0, 0, 1000, 3000)
        assertEquals(0.35f, BubbleGeometry.fractionFor(BubbleGeometry.yFor(0.35f, 150, tall), 150, tall), 0.01f)
    }

    @Test
    fun `y and fraction are clamped`() {
        assertEquals(100, BubbleGeometry.yFor(-1f, 150, usable))
        assertEquals(1850, BubbleGeometry.yFor(2f, 150, usable))
        assertEquals(0f, BubbleGeometry.fractionFor(0, 150, usable), 0f)
        assertEquals(1f, BubbleGeometry.fractionFor(5000, 150, usable), 0f)
    }
}
