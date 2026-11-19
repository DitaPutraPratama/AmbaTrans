package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect
import org.junit.Assert.assertEquals
import org.junit.Test

class RegionGeometryTest {
    private val screen = ScreenRect(0, 0, 1000, 2000)
    private val box = ScreenRect(100, 100, 400, 300)

    @Test
    fun `drawing works in any direction and stays on screen`() {
        assertEquals(ScreenRect(100, 50, 300, 200), RegionGeometry.fromPoints(300, 50, 100, 200, screen))
        assertEquals(ScreenRect(0, 0, 50, 60), RegionGeometry.fromPoints(-20, -5, 50, 60, screen))
    }

    @Test
    fun `corner handles are found within the radius`() {
        assertEquals(RegionGeometry.TOP_LEFT, RegionGeometry.cornerAt(box, 110, 95, 20))
        assertEquals(RegionGeometry.BOTTOM_RIGHT, RegionGeometry.cornerAt(box, 400, 300, 20))
        assertEquals(RegionGeometry.NONE, RegionGeometry.cornerAt(box, 250, 200, 20))
    }

    @Test
    fun `resizing moves one corner, keeps the opposite one and the minimum size`() {
        assertEquals(
            ScreenRect(100, 100, 600, 500),
            RegionGeometry.resize(box, RegionGeometry.BOTTOM_RIGHT, 600, 500, 48, screen),
        )
        assertEquals(
            ScreenRect(50, 20, 400, 300),
            RegionGeometry.resize(box, RegionGeometry.TOP_LEFT, 50, 20, 48, screen),
        )
        // Dragged past the opposite corner: stops at the minimum size.
        assertEquals(
            ScreenRect(352, 100, 400, 300),
            RegionGeometry.resize(box, RegionGeometry.TOP_LEFT, 900, 100, 48, screen),
        )
        assertEquals(
            ScreenRect(100, 100, 1000, 300),
            RegionGeometry.resize(box, RegionGeometry.TOP_RIGHT, 5000, 100, 48, screen),
        )
    }

    @Test
    fun `moving keeps the size and stays on screen`() {
        assertEquals(ScreenRect(150, 130, 450, 330), RegionGeometry.move(box, 50, 30, screen))
        assertEquals(ScreenRect(700, 0, 1000, 200), RegionGeometry.move(box, 5000, -500, screen))
    }
}
