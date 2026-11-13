package com.ambatrans.app.bridge

import com.ambatrans.app.service.ServiceLauncher
import com.ambatrans.app.service.ServiceStateHolder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ServiceMethodHandler(private val launcher: ServiceLauncher) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> start(result)
            "stop" -> {
                launcher.stop()
                result.success(null)
            }
            "isRunning" -> result.success(ServiceStateHolder.running.value)
            else -> result.notImplemented()
        }
    }

    private fun start(result: MethodChannel.Result) {
        if (!launcher.overlayGranted()) {
            result.error(ERROR_NO_OVERLAY_PERMISSION, "Overlay permission is not granted", null)
            return
        }
        try {
            launcher.start()
            result.success(null)
        } catch (e: RuntimeException) {
            result.error(ERROR_START_FAILED, e.message, null)
        }
    }

    companion object {
        const val CHANNEL = "com.ambatrans.app/service"
        const val ERROR_NO_OVERLAY_PERMISSION = "E_NO_OVERLAY_PERMISSION"
        const val ERROR_START_FAILED = "E_SERVICE_START_FAILED"
    }
}
