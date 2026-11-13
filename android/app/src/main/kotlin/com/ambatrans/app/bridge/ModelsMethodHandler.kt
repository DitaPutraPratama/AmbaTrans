package com.ambatrans.app.bridge

import com.ambatrans.app.ocr.LanguageCatalog
import com.ambatrans.app.translate.ModelDownloadException
import com.ambatrans.app.translate.ModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class ModelsMethodHandler(
    private val manager: ModelManager,
    private val supportedLanguages: () -> List<String>,
    private val scope: CoroutineScope,
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSupportedLanguages" -> result.success(supportedLanguages())
            "getSourceLanguages" -> result.success(LanguageCatalog.sourceLanguages(supportedLanguages()))
            "getStatus" -> scope.launch {
                try {
                    val status = manager.getStatus(call.stringArg("source"), call.stringArg("target"))
                    result.success(mapOf("ready" to status.ready, "missing" to status.missing))
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    result.error(ERROR_MODELS_FAILED, e.message, null)
                }
            }
            "download" -> scope.launch {
                try {
                    manager.download(call.stringArg("source"), call.stringArg("target"))
                    result.success(null)
                } catch (e: ModelDownloadException) {
                    result.error(ERROR_DOWNLOAD_FAILED, e.cause?.message, null)
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    result.error(ERROR_MODELS_FAILED, e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun MethodCall.stringArg(name: String): String = argument<String>(name).orEmpty()

    companion object {
        const val CHANNEL = "com.ambatrans.app/models"
        const val ERROR_MODELS_FAILED = "E_MODELS_FAILED"
        const val ERROR_DOWNLOAD_FAILED = "E_MODEL_DOWNLOAD_FAILED"
    }
}
