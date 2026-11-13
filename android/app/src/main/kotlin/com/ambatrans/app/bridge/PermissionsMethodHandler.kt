package com.ambatrans.app.bridge

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PermissionsMethodHandler(private val permissions: AndroidPermissions) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(
                mapOf(
                    "overlay" to permissions.overlayGranted(),
                    "notifications" to permissions.notificationsGranted(),
                    "accessibility" to permissions.accessibilityEnabled(),
                ),
            )
            "openOverlaySettings" -> {
                permissions.openOverlaySettings()
                result.success(null)
            }
            "openBatterySettings" -> {
                permissions.openBatterySettings()
                result.success(null)
            }
            "openAccessibilitySettings" -> {
                permissions.openAccessibilitySettings()
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
