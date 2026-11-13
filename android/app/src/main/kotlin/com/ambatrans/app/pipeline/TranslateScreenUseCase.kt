package com.ambatrans.app.pipeline

import android.graphics.Bitmap
import com.ambatrans.app.capture.NoProjectionException
import com.ambatrans.app.capture.ScreenProtectedException
import com.ambatrans.app.ocr.OcrScript
import com.ambatrans.app.translate.ModelNotReadyException
import com.ambatrans.app.translate.TranslationFailedException
import kotlinx.coroutines.CancellationException

enum class TranslateError { NEEDS_CAPTURE, SCREEN_PROTECTED, MODELS_MISSING, NO_TEXT, FAILED }

/** What the pipeline needs from the screen: hiding things before capture and showing progress / results. */
interface TranslateUi {
    fun hideForCapture()

    fun showLoading()

    fun showResult(blocks: List<TranslatedBlock>)

    fun showError(error: TranslateError)
}

/**
 * One "translate this screen" run: capture, OCR, filter, translate, show (ARCHITECTURE §7.1).
 * Collaborators are lambdas so the flow is testable without Android or ML Kit.
 */
class TranslateScreenUseCase(
    private val ui: TranslateUi,
    private val languages: () -> Pair<String, String>,
    private val scriptFor: (String) -> OcrScript?,
    private val modelsReady: suspend (source: String, target: String) -> Boolean,
    private val capture: suspend () -> Bitmap,
    private val recognize: suspend (Bitmap, OcrScript) -> List<TextBlock>,
    private val translate: suspend (List<TextBlock>, String, String) -> List<TranslatedBlock>,
    /** Accessibility text nodes (F-10); empty when accurate mode is off or the service is disabled. */
    private val extraBlocks: () -> List<TextBlock> = { emptyList() },
) {
    suspend fun run() {
        val (source, target) = languages()
        try {
            if (!modelsReady(source, target)) return ui.showError(TranslateError.MODELS_MISSING)
            ui.hideForCapture()
            val bitmap = capture()
            ui.showLoading()
            val blocks = try {
                recognize(bitmap, scriptFor(source) ?: OcrScript.LATIN)
            } finally {
                bitmap.recycle() // the screenshot must not outlive OCR (F-04)
            }
            val lines = TextFilter.filter(TextMerger.merge(blocks, extraBlocks()))
            if (lines.isEmpty()) return ui.showError(TranslateError.NO_TEXT)
            ui.showResult(translate(lines, source, target))
        } catch (e: CancellationException) {
            throw e
        } catch (e: NoProjectionException) {
            ui.showError(TranslateError.NEEDS_CAPTURE)
        } catch (e: ScreenProtectedException) {
            ui.showError(TranslateError.SCREEN_PROTECTED)
        } catch (e: ModelNotReadyException) {
            ui.showError(TranslateError.MODELS_MISSING)
        } catch (e: TranslationFailedException) {
            ui.showError(TranslateError.FAILED)
        } catch (e: Exception) {
            ui.showError(TranslateError.FAILED)
        }
    }
}
