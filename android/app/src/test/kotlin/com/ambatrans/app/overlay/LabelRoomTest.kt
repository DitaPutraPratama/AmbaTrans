package com.ambatrans.app.overlay

import com.ambatrans.app.pipeline.ScreenRect
import com.ambatrans.app.pipeline.TextBlock
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

class LabelRoomTest {
    private val screen = ScreenRect(0, 0, 1000, 2000)

    @Test
    fun `a lone box may use the whole screen`() {
        assertEquals(listOf(screen), LabelRoom.compute(listOf(TextBlock("a", 100, 100, 200, 120)), screen))
    }

    @Test
    fun `stacked lines split the gap between them`() {
        val rooms = LabelRoom.compute(
            listOf(TextBlock("a", 100, 100, 300, 120), TextBlock("b", 150, 130, 400, 150)),
            screen,
        )
        assertEquals(ScreenRect(0, 0, 1000, 125), rooms[0])
        assertEquals(ScreenRect(0, 125, 1000, 2000), rooms[1])
    }

    @Test
    fun `side by side buttons split the space between them`() {
        val rooms = LabelRoom.compute(
            listOf(TextBlock("Bagikan", 100, 500, 300, 540), TextBlock("Simpan", 500, 500, 700, 540)),
            screen,
        )
        assertEquals(ScreenRect(0, 0, 400, 2000), rooms[0])
        assertEquals(ScreenRect(400, 0, 1000, 2000), rooms[1])
    }

    @Test
    fun `rooms of neighbouring lines never overlap`() {
        val lines = (0 until 10).map { TextBlock("l$it", 50 + it * 7, 100 + it * 26, 300 + it * 11, 120 + it * 26) }
        val rooms = LabelRoom.compute(lines, screen)
        for (i in rooms.indices) {
            for (j in i + 1 until rooms.size) {
                val a = rooms[i]
                val b = rooms[j]
                assertFalse("$i/$j", a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom)
            }
        }
    }
}
