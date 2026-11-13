package com.ambatrans.app.bridge

import com.ambatrans.app.translate.ModelDownloadException
import com.ambatrans.app.translate.ModelManager
import com.ambatrans.app.translate.ModelStatus
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.coEvery
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import org.junit.Test

class ModelsMethodHandlerTest {
    private val manager = mockk<ModelManager>()
    private val result = mockk<MethodChannel.Result>(relaxed = true)
    private val handler =
        ModelsMethodHandler(manager, { listOf("en", "id", "ru") }, CoroutineScope(Dispatchers.Unconfined))
    private val pair = mapOf("source" to "en", "target" to "id")

    @Test
    fun `getSupportedLanguages returns the list`() {
        handler.onMethodCall(MethodCall("getSupportedLanguages", null), result)
        verify { result.success(listOf("en", "id", "ru")) }
    }

    @Test
    fun `getSourceLanguages drops languages OCR cannot read`() {
        handler.onMethodCall(MethodCall("getSourceLanguages", null), result)
        verify { result.success(listOf("en", "id")) }
    }

    @Test
    fun `getStatus maps ready and missing`() {
        coEvery { manager.getStatus("en", "id") } returns ModelStatus(false, listOf("id"))
        handler.onMethodCall(MethodCall("getStatus", pair), result)
        verify { result.success(mapOf("ready" to false, "missing" to listOf("id"))) }
    }

    @Test
    fun `download succeeds with null`() {
        coEvery { manager.download("en", "id") } returns Unit
        handler.onMethodCall(MethodCall("download", pair), result)
        verify { result.success(null) }
    }

    @Test
    fun `download failure becomes E_MODEL_DOWNLOAD_FAILED`() {
        coEvery { manager.download(any(), any()) } throws ModelDownloadException(RuntimeException("offline"))
        handler.onMethodCall(MethodCall("download", pair), result)
        verify { result.error("E_MODEL_DOWNLOAD_FAILED", "offline", null) }
    }

    @Test
    fun `an unexpected ML Kit failure in getStatus is reported, not thrown`() {
        coEvery { manager.getStatus(any(), any()) } throws IllegalStateException("ML Kit not ready")
        handler.onMethodCall(MethodCall("getStatus", pair), result)
        verify { result.error("E_MODELS_FAILED", "ML Kit not ready", null) }
    }

    @Test
    fun `an unexpected failure in download is reported, not thrown`() {
        coEvery { manager.download(any(), any()) } throws IllegalStateException("boom")
        handler.onMethodCall(MethodCall("download", pair), result)
        verify { result.error("E_MODELS_FAILED", "boom", null) }
    }

    @Test
    fun `unknown method is not implemented`() {
        handler.onMethodCall(MethodCall("bogus", null), result)
        verify { result.notImplemented() }
    }
}
