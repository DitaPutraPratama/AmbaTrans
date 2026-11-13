package com.ambatrans.app.bridge

import com.ambatrans.app.data.InvalidSettingException
import com.ambatrans.app.data.SettingsStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.Test

class SettingsMethodHandlerTest {
    private val store = mockk<SettingsStore>()
    private val result = mockk<MethodChannel.Result>(relaxed = true)
    private val handler = SettingsMethodHandler(store)

    @Test
    fun `getAll returns the store map`() {
        val all = mapOf<String, Any>("source_lang" to "en")
        every { store.getAll() } returns all
        handler.onMethodCall(MethodCall("getAll", null), result)
        verify { result.success(all) }
    }

    @Test
    fun `set forwards key and value`() {
        every { store.set(any(), any()) } returns Unit
        handler.onMethodCall(MethodCall("set", mapOf("key" to "bubble_edge", "value" to "left")), result)
        verify { store.set("bubble_edge", "left") }
        verify { result.success(null) }
    }

    @Test
    fun `invalid value becomes E_INVALID_VALUE`() {
        every { store.set(any(), any()) } throws InvalidSettingException("nope")
        handler.onMethodCall(MethodCall("set", mapOf("key" to "source_lang", "value" to "id")), result)
        verify { result.error("E_INVALID_VALUE", "nope", null) }
    }

    @Test
    fun `unknown method is not implemented`() {
        handler.onMethodCall(MethodCall("bogus", null), result)
        verify { result.notImplemented() }
    }
}
