package com.ambatrans.app.bridge

import com.ambatrans.app.service.ServiceLauncher
import com.ambatrans.app.service.ServiceStateHolder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.After
import org.junit.Test

class ServiceMethodHandlerTest {
    private val launcher = mockk<ServiceLauncher>(relaxed = true)
    private val result = mockk<MethodChannel.Result>(relaxed = true)
    private val handler = ServiceMethodHandler(launcher)

    @After
    fun reset() = ServiceStateHolder.set(false)

    @Test
    fun `start without overlay permission fails with E_NO_OVERLAY_PERMISSION`() {
        every { launcher.overlayGranted() } returns false
        handler.onMethodCall(MethodCall("start", null), result)
        verify(exactly = 0) { launcher.start() }
        verify { result.error("E_NO_OVERLAY_PERMISSION", any(), null) }
    }

    @Test
    fun `start with permission launches the service`() {
        every { launcher.overlayGranted() } returns true
        handler.onMethodCall(MethodCall("start", null), result)
        verify { launcher.start() }
        verify { result.success(null) }
    }

    @Test
    fun `a failing launch becomes E_SERVICE_START_FAILED`() {
        every { launcher.overlayGranted() } returns true
        every { launcher.start() } throws IllegalStateException("not allowed")
        handler.onMethodCall(MethodCall("start", null), result)
        verify { result.error("E_SERVICE_START_FAILED", "not allowed", null) }
    }

    @Test
    fun `stop stops the service`() {
        handler.onMethodCall(MethodCall("stop", null), result)
        verify { launcher.stop() }
        verify { result.success(null) }
    }

    @Test
    fun `isRunning reflects the state holder`() {
        handler.onMethodCall(MethodCall("isRunning", null), result)
        verify { result.success(false) }
        ServiceStateHolder.set(true)
        handler.onMethodCall(MethodCall("isRunning", null), result)
        verify { result.success(true) }
    }
}
