package com.ambatrans.app.pipeline

import android.graphics.Bitmap
import com.ambatrans.app.capture.NoProjectionException
import com.ambatrans.app.capture.ScreenProtectedException
import com.ambatrans.app.ocr.OcrScript
import com.ambatrans.app.translate.ModelNotReadyException
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class TranslateScreenUseCaseTest {
    private class FakeUi : TranslateUi {
        val events = mutableListOf<String>()
        var result: List<TranslatedBlock>? = null
        var error: TranslateError? = null

        override fun hideForCapture() {
            events += "hide"
        }

        override fun showLoading() {
            events += "loading"
        }

        override fun showResult(blocks: List<TranslatedBlock>) {
            events += "result"
            result = blocks
        }

        override fun showError(error: TranslateError) {
            events += "error"
            this.error = error
        }
    }

    private val bitmap: Bitmap = mockk(relaxed = true)
    private val ui = FakeUi()
    private var scriptUsed: OcrScript? = null

    private fun useCase(
        ready: Boolean = true,
        source: String = "en",
        capture: suspend () -> Bitmap = { bitmap },
        lines: List<TextBlock> = listOf(TextBlock("Hello world", 0, 0, 100, 20)),
        translate: suspend (List<TextBlock>, String, String) -> List<TranslatedBlock> = { b, _, _ ->
            b.map { TranslatedBlock(it, "Halo dunia") }
        },
    ) = TranslateScreenUseCase(
        ui = ui,
        languages = { source to "id" },
        scriptFor = { if (it == "ja") OcrScript.JAPANESE else OcrScript.LATIN },
        modelsReady = { _, _ -> ready },
        capture = capture,
        recognize = { _, script ->
            scriptUsed = script
            lines
        },
        translate = translate,
    )

    @Test
    fun `happy path hides, loads, then shows the translated blocks`() = runBlocking {
        useCase().run()
        assertEquals(listOf("hide", "loading", "result"), ui.events)
        assertEquals("Halo dunia", ui.result!!.single().translated)
        verify { bitmap.recycle() }
    }

    @Test
    fun `OCR uses the script of the source language`() = runBlocking {
        useCase(source = "ja").run()
        assertEquals(OcrScript.JAPANESE, scriptUsed)
    }

    @Test
    fun `missing models stop before capture`() = runBlocking {
        var captured = false
        useCase(ready = false, capture = {
            captured = true
            bitmap
        }).run()
        assertEquals(TranslateError.MODELS_MISSING, ui.error)
        assertTrue(!captured)
    }

    @Test
    fun `nothing translatable reports no text and still recycles the bitmap`() = runBlocking {
        useCase(lines = listOf(TextBlock("12345", 0, 0, 100, 20))).run()
        assertEquals(TranslateError.NO_TEXT, ui.error)
        verify { bitmap.recycle() }
    }

    @Test
    fun `capture failures map to their errors`() = runBlocking {
        useCase(capture = { throw NoProjectionException() }).run()
        assertEquals(TranslateError.NEEDS_CAPTURE, ui.error)
        useCase(capture = { throw ScreenProtectedException() }).run()
        assertEquals(TranslateError.SCREEN_PROTECTED, ui.error)
    }

    @Test
    fun `translation errors map to their errors`() = runBlocking {
        useCase(translate = { _, _, _ -> throw ModelNotReadyException() }).run()
        assertEquals(TranslateError.MODELS_MISSING, ui.error)
        useCase(translate = { _, _, _ -> throw IllegalStateException("boom") }).run()
        assertEquals(TranslateError.FAILED, ui.error)
    }
}
