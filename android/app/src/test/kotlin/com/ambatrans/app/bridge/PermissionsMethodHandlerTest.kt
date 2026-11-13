package com.ambatrans.app.bridge

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Test

class PermissionsMethodHandlerTest {
    private val permissions = mockk<AndroidPermissions>(relaxed = true)
    private val result = mockk<MethodChannel.Result>(relaxed = true)
    private val handler = PermissionsMethodHandler(permissions)

    @Test
    fun `getStatus reports all three permissions`() {
        every { permissions.overlayGranted() } returns true
        every { permissions.notificationsGranted() } returns false
        every { permissions.accessibilityEnabled() } returns true
        handler.onMethodCall(MethodCall("getStatus", null), result)
        verify {
            result.success(
                mapOf(
                    "overlay" to true,
                    "notifications" to false,
                    "accessibility" to true,
                    "capture" to false,
                ),
            )
        }
    }

    @Test
    fun `open settings methods call through and succeed`() {
        handler.onMethodCall(MethodCall("openOverlaySettings", null), result)
        handler.onMethodCall(MethodCall("openAccessibilitySettings", null), result)
        verify { permissions.openOverlaySettings() }
        verify { permissions.openAccessibilitySettings() }
        verify(exactly = 2) { result.success(null) }
    }

    @Test
    fun `openBatterySettings calls through and succeeds`() {
        handler.onMethodCall(MethodCall("openBatterySettings", null), result)
        verify { permissions.openBatterySettings() }
        verify { result.success(null) }
    }

    @Test
    fun `requestNotifications answers when the callback fires`() {
        val callback = slot<(Boolean) -> Unit>()
        every { permissions.requestNotifications(capture(callback)) } returns Unit
        handler.onMethodCall(MethodCall("requestNotifications", null), result)
        verify(exactly = 0) { result.success(any()) }
        callback.captured(true)
        verify { result.success(true) }
    }

    @Test
    fun `unknown method is not implemented`() {
        handler.onMethodCall(MethodCall("bogus", null), result)
        verify { result.notImplemented() }
    }
}
