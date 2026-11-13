package com.ambatrans.app.bridge

import com.ambatrans.app.translate.ModelDownloadException
import com.ambatrans.app.translate.ModelManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
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
            "getStatus" -> scope.launch {
                val status = manager.getStatus(
                    call.argument<String>("source").orEmpty(),
                    call.argument<String>("target").orEmpty(),
                )
                result.success(mapOf("ready" to status.ready, "missing" to status.missing))
            }
            "download" -> scope.launch {
                try {
                    manager.download(
                        call.argument<String>("source").orEmpty(),
                        call.argument<String>("target").orEmpty(),
                    )
                    result.success(null)
                } catch (e: ModelDownloadException) {
                    result.error(ERROR_DOWNLOAD_FAILED, e.cause?.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.ambatrans.app/models"
        const val ERROR_DOWNLOAD_FAILED = "E_MODEL_DOWNLOAD_FAILED"
    }
}
