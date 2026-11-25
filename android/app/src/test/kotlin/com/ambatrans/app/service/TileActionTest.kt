package com.ambatrans.app.service

import org.junit.Assert.assertEquals
import org.junit.Test

class TileActionTest {
    @Test
    fun `starts the bubble when it is off and the overlay permission is granted`() {
        assertEquals(TileAction.START, TileAction.of(running = false, overlayGranted = true))
    }

    @Test
    fun `opens the app when the overlay permission is missing`() {
        assertEquals(TileAction.OPEN_APP, TileAction.of(running = false, overlayGranted = false))
    }

    @Test
    fun `a running bubble can always be stopped`() {
        assertEquals(TileAction.STOP, TileAction.of(running = true, overlayGranted = true))
        assertEquals(TileAction.STOP, TileAction.of(running = true, overlayGranted = false))
    }
}
