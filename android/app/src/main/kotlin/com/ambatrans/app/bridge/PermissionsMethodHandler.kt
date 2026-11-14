package com.ambatrans.app.bridge

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PermissionsMethodHandler(
    private val permissions: AndroidPermissions,
    private val captureReady: () -> Boolean = { false },
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(
                mapOf(
                    "overlay" to permissions.overlayGranted(),
                    "notifications" to permissions.notificationsGranted(),
                    "capture" to captureReady(),
                ),
            )
            "openOverlaySettings" -> {
                permissions.openOverlaySettings()
                result.success(null)
            }
            "requestCapture" -> {
                permissions.requestCapture()
                result.success(null)
            }
            "openBatterySettings" -> {
                permissions.openBatterySettings()
                result.success(null)
            }
            "requestNotifications" -> permissions.requestNotifications { result.success(it) }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.ambatrans.app/permissions"
    }
}
