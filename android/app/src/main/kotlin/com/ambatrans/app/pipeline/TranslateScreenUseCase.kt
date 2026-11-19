package com.ambatrans.app.pipeline

import android.graphics.Bitmap
import com.ambatrans.app.capture.NoProjectionException
import com.ambatrans.app.capture.ScreenProtectedException
import com.ambatrans.app.ocr.OcrScript
import com.ambatrans.app.translate.CloudException
import com.ambatrans.app.translate.ModelNotReadyException
import com.ambatrans.app.translate.TranslationFailedException
import kotlinx.coroutines.CancellationException

enum class TranslateError {
    NEEDS_CAPTURE,
    SCREEN_PROTECTED,
    MODELS_MISSING,
    NO_TEXT,
    ALREADY_IN_TARGET,
    FAILED,

    // Online engines (ADR-024)
    API_KEY_MISSING,
    API_KEY_REJECTED,
    QUOTA_EXCEEDED,
    NETWORK,
}

/** What the pipeline needs from the screen: hiding things before capture and showing progress / results. */
interface TranslateUi {
    fun hideForCapture()

    fun showLoading()

    fun showResult(blocks: List<TranslatedBlock>)

    fun showError(error: TranslateError)
}

/**
 * One "translate this screen" run: capture, OCR, filter, translate, show (ARCHITECTURE §7.1).
 * With a region (partial mode) only text inside it is read and it is translated as one sentence.
 * Collaborators are lambdas so the flow is testable without Android or ML Kit.
 */
class TranslateScreenUseCase(
    private val ui: TranslateUi,
    private val languages: () -> Pair<String, String>,
    private val scriptFor: (String) -> OcrScript?,
    private val modelsReady: suspend (source: String, target: String) -> Boolean,
    private val capture: suspend () -> Bitmap,
    private val recognize: suspend (Bitmap, OcrScript, ScreenRect?) -> List<TextBlock>,
    private val translate: suspend (List<TextBlock>, String, String) -> List<TranslatedBlock>,
) {
    suspend fun run(region: ScreenRect? = null) {
        val (source, target) = languages()
        try {
            if (!modelsReady(source, target)) return ui.showError(TranslateError.MODELS_MISSING)
            ui.hideForCapture()
            val bitmap = capture()
            ui.showLoading()
            val blocks = try {
                recognize(bitmap, scriptFor(source) ?: OcrScript.LATIN, region)
            } finally {
                bitmap.recycle() // the screenshot must not outlive OCR (F-04)
            }
            val lines = if (region == null) {
                TextFilter.filter(BlockMerger.paragraphs(blocks))
            } else {
                listOfNotNull(RegionText.merge(blocks))
            }
            if (lines.isEmpty()) return ui.showError(TranslateError.NO_TEXT)
            // Text already in the target language (e.g. the app's own buttons) needs no label.
            val changed = translate(lines, source, target).filterNot {
                TextFilter.isUnchanged(it.block.text, it.translated)
            }
            if (changed.isEmpty()) return ui.showError(TranslateError.ALREADY_IN_TARGET)
            ui.showResult(changed)
        } catch (e: CancellationException) {
            throw e
        } catch (e: NoProjectionException) {
            ui.showError(TranslateError.NEEDS_CAPTURE)
        } catch (e: ScreenProtectedException) {
            ui.showError(TranslateError.SCREEN_PROTECTED)
        } catch (e: ModelNotReadyException) {
            ui.showError(TranslateError.MODELS_MISSING)
        } catch (e: CloudException) {
            ui.showError(e.error)
        } catch (e: TranslationFailedException) {
            ui.showError(TranslateError.FAILED)
        } catch (e: Exception) {
            ui.showError(TranslateError.FAILED)
        }
    }
}
